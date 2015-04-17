//
//  RtmpStreamer.m
//  Streaming
//
//  Created by Radu Dan on 10/19/11.
//  Copyright (c) 2011 Medina Software. All rights reserved.
//

#import "Recorder.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#include <signal.h>

#import "TrialManager.m"
#import "VideoSessionManager.h"

#import "RTMPReachability.h"

#import "AACEncoder.h"

static Recorder *recorder = nil;

@interface Recorder ()
{
    AVCaptureVideoOrientation referenceOrientation;
    
    Video_Orientation streamingOrientation;
    
    BOOL isPortrait;
    BOOL saveVideoToCameraRoll;
    BOOL waitingForVideoToBeSaved;
    BOOL autoAdaptToNetwork;
    BOOL waitingToProperlyStop;
    BOOL didStartSending;
    BOOL sessionJustStarted;
    BOOL muteSound;
    
    CGFloat theAudioRate;
    CGFloat theVideoRate;
    
    NSInteger framesPerSecond;
    NSInteger kFrameInterval;
    
    VideoResolution theVideoResolution;
    
    NSMutableArray *encodersQueue;
    
    double BUFFER_LENGTH;
    
    BOOL dropFrames;
    int frameDroppingFrequency;
    int frameCounter;
    
    BOOL allowsVideoResolutionChanges;
    BOOL sessionWasRunnig;
    
    id adaptiveManager;
    id saveVideoManager;
    
    RTMPReachability *_reachability;
    
    NSThread *currentThread;
    
    AACEncoder *audioEncoder;
    
    Encoder *audioExtraDataEncoder;
    Demuxer *audioExtraDataDemuxer;
    
    AVCodecContext *audioCodecContext;
    
    dispatch_queue_t movieWritingQueue;
}

@property (readwrite) AVCaptureVideoOrientation referenceOrientation;
@property (nonatomic, copy) void (^changeCameraCompletionBlock)(BOOL);
@property (nonatomic, retain) NSString *videoProfile;

@end

@implementation Recorder

@synthesize referenceOrientation;
@synthesize theVideoRate;
@synthesize theVideoResolution;
@synthesize dropFrames;
@synthesize allowsVideoResolutionChanges;
@synthesize changePreset;
@synthesize framesPerSecond;
@synthesize frameDroppingFrequency;

void SigPipeHandler(int s);

void SigPipeHandler(int s)
{
    // do your handling
    NSLog(@"SigPipeHandler");
    
    if (recorder.delegate && ! recorder.noInternet) {
        if (recorder.rtmp) {
            recorder.rtmp.abortIsRequested = NO;
        }
        [recorder.delegate streamingStateChanged: StreamingState_NoServerConnection withMessage: @"No server connection."];
        [recorder stop];
    }
}

- (id)init {
    
    if ([TrialManager checkTrial]) {
        
        if (self = [super init]) {
         
            NSLog(@"initialize");
            
            recorder = self;
            
            signal(SIGPIPE, SigPipeHandler);
            
            state = STATE_STOPPED;
            
            ready = YES;
            sendVideo = YES;
            
            previewOutput = nil;
            
            encoders = [[NSLock alloc] init];
            worker = [[NSLock alloc] init];
            stream = [[NSConditionLock alloc] initWithCondition:0];
            
            type = LIVE_RECORDER;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReachabilityChanged:) name:kVKReachabilityChangedNotification object:nil];
            [self initReachability];
        }
        
        return self;
    }
    else {
        
        [[[[UIAlertView alloc] initWithTitle:@"iOS-RTMP Library"
                                     message:@"Your trial session has expired."
                                    delegate:nil
                           cancelButtonTitle:@"Dismiss"
                           otherButtonTitles:nil] autorelease] show];
        
        return nil;
    }
}

//rtmp://username:password@wowzaserver/app/streamname
- (NSString *)rtmpPathFromServer:(NSString *)server user:(NSString *)username andPass:(NSString *)password
{
    NSArray *components = [server componentsSeparatedByString: @"://"];
    
    if (components.count != 2) {
        return nil;
    }
    
    NSString *protocol = [[components objectAtIndex: 0] lowercaseString];
    NSString *pathTail = [components objectAtIndex: 1];
    
    if ( ! [protocol isEqualToString: @"rtmp"] && ! [protocol isEqualToString: @"rtmps"] && ! [protocol isEqualToString: @"rtmpt"]) {
        return nil;
    }
    
    if (username == nil || password == nil) {
        return server;
    }
    else {
        
        NSString *finalPath = [NSString stringWithFormat: @"%@://%@:%@@%@", protocol, username, password, pathTail];
        
        NSLog(@"RTMP path = %@", finalPath);
        
        return finalPath;
    }
}

- (id)           initWithServer: (NSString *)server
                       username: (NSString *)username
                       password: (NSString *)password
                        preview: (UIView *)preview
                           mute: (BOOL)mute
               callbackListener: (id<StreamingCallbackListener>)callbackListener
               usingFrontCamera: (bool)front usingTorch:(bool)torch
               videoWithQuality: (VideoResolution)videoResolution
                      audioRate: (double)audioRate
                andVideoBitRate: (NSInteger)videoBitRate
               keyFrameInterval: (NSInteger)keyframeInterval
                framesPerSecond: (NSInteger)fps
                   andShowVideo: (bool)showVideo
          saveVideoToCameraRoll: (bool)saveVideo
             autoAdaptToNetwork: (bool)autoAdapt
    allowVideoResolutionChanges: (bool)allowChanges
                   bufferLength: (double)bufferLength
              validOrientations: (Video_Orientation)orientation
             previewOrientation: (Video_Orientation)previewOrientation
{
    
    if (self = [self init]) {
        
        /*
         * Create capture session
         */
        session = [[AVCaptureSession alloc] init];
        
        /*
         * Create audio connection
         */
        AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeAudio] error:nil];
        
        if (audioIn == nil) {
            [[[[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
                                         message:@"This app requires access to your device's Microphone.\n\nPlease enable Microphone access for this app in Settings / Privacy / Microphone"
                                        delegate:nil
                               cancelButtonTitle:@"Dismiss"
                               otherButtonTitles:nil] autorelease] show];
            
            if (_delegate) {
                [_delegate streamingStateChanged: StreamingState_Error withMessage: @"The library requires access to your device's microphone."];
            }
            
            [session release];
            
            return nil;
        }
        
        if ([session canAddInput:audioIn])
            [session addInput:audioIn];
        audioInput = audioIn;
        [audioIn release];
        
        dispatch_queue_t sampleQueue = dispatch_queue_create("com.agilio.rtmp_samples", NULL);
        
        AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
        [audioOut setSampleBufferDelegate:self queue: sampleQueue];
        
        if ([session canAddOutput:audioOut])
            [session addOutput:audioOut];
        audioOutput = audioOut;
        [audioOut release];
        
        /*
         * Create video connection
         */
        
        for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            
            if (device.position == AVCaptureDevicePositionFront) {
                frontVideoDevice = [device retain];
            } else {
                rearVideoDevice = [device retain];
            }
        }
        
        AVCaptureDevice *device = front ? frontVideoDevice : rearVideoDevice;
        
        if ( ! device || ! [device supportsAVCaptureSessionPreset: [self sessionPresetForResolution: videoResolution]]) {
            
            if (_delegate) {
                [_delegate streamingStateChanged: StreamingState_Error withMessage: [NSString stringWithFormat: @"This device doesn't support the selected video preset: %@", [self sessionPresetForResolution: videoResolution]]];
            }
            
            [frontVideoDevice release];
            [rearVideoDevice release];
            [session release];
            
            return nil;
        }
        
        AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];

        if ([session canAddInput:videoIn])
            [session addInput:videoIn];
        videoInput = videoIn;
        [videoIn release];
        
        AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
        
        [videoOut setAlwaysDiscardsLateVideoFrames:YES];
        //[videoOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        [videoOut setSampleBufferDelegate:self queue:sampleQueue];
        
        if ([session canAddOutput:videoOut])
            [session addOutput:videoOut];
        videoOutput = videoOut;
        [videoOut release];
        
        dispatch_release(sampleQueue);
        
        streamingOrientation = orientation;
        
        if (streamingOrientation != Orientation_All) {
            [[videoOutput connectionWithMediaType: AVMediaTypeVideo] setVideoOrientation: [self captureOrientationFromVideoOrientation: streamingOrientation]];
        }
        else {
            [[videoOutput connectionWithMediaType: AVMediaTypeVideo] setVideoOrientation: [self captureOrientationFromVideoOrientation: streamingOrientation]];
        }
        
        _delegate = callbackListener;
        destination = [[self rtmpPathFromServer: server user: username andPass: password] retain];
        
        if ( ! destination) {
            
            if (_delegate) {
                [_delegate streamingStateChanged: StreamingState_Error withMessage: @"Invalid rtmp configuration."];
            }
            
            return nil;
        }
        
        sendVideo = showVideo;
        kFrameInterval = keyframeInterval;
        saveVideoToCameraRoll = saveVideo;
        theVideoResolution = videoResolution;
        theVideoRate = videoBitRate;
        theAudioRate = audioRate;
        autoAdaptToNetwork = autoAdapt;
        allowsVideoResolutionChanges = allowChanges;
        
        BUFFER_LENGTH = bufferLength > 0 ? bufferLength : kDefaultBufferLength;
        
        encodersQueue = [[NSMutableArray alloc] init];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

        [notificationCenter addObserver: self
                               selector: @selector(savingFileStateChanged:)
                                   name: @"com.agilio.eu.saveFileState"
                                 object: nil];
        
        [notificationCenter addObserver: self
                               selector: @selector(applicationDidEnterBackground)
                                   name: UIApplicationDidEnterBackgroundNotification
                                 object: nil];
        
        [notificationCenter addObserver: self
                               selector: @selector(applicationDidEnterForeground)
                                   name: UIApplicationDidBecomeActiveNotification
                                 object: nil];
        
        
        if (! [VideoSessionManager setPreset: videoResolution forSession: session]) {
            
            theVideoResolution = VideoResolution_192x144;
            theVideoRate = MaximumBitrate_192x144;
            
            if (_delegate) {
                [_delegate streamingStateChanged: StreamingState_Warning withMessage: [NSString stringWithFormat: @"This version of the library does not support this video resolution. 192x144 at %d bitrate will be considered.", MaximumBitrate_192x144]];
            }
        }
        
        
        if (videoResolution > VideoResolution_640x480) {
            saveVideoToCameraRoll = NO;
        }
        
        self.referenceOrientation = [self captureOrientationFromVideoOrientation: orientation];
        
        if (streamingOrientation == Orientation_All) {
            [self setOutputOrientation: [[UIDevice currentDevice] orientation]];
        }
        
        if (previewOrientation == Orientation_All) {
            previewOrientation = Orientation_Portrait;
        }
        
        switch (streamingOrientation) {
            case Orientation_LandscapeLeft:
            case Orientation_LandscapeRight:
                isPortrait = NO;
                break;
            case Orientation_Portrait:
            case Orientation_PortraitUpsideDown:
                isPortrait = YES;
                break;
            default:
                break;
        }
        
        // Add preview layer.
        if (preview) {
            previewOutput = [[AVCaptureVideoPreviewLayer alloc] initWithSession: session];
            [previewOutput setFrame:[preview bounds]];
            
            [[preview layer] insertSublayer: previewOutput atIndex: 0];
            //[[preview layer] addSublayer:previewOutput];
            [previewOutput setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.9) {
                
                if ([[previewOutput connection] isVideoOrientationSupported]) {
                    
                    [[previewOutput connection] setVideoOrientation: [self captureOrientationFromVideoOrientation: previewOrientation]];
                }
            } else {
                if ([previewOutput isOrientationSupported]) {
                    [previewOutput setOrientation: [self captureOrientationFromVideoOrientation: previewOrientation]];
                }
            }
        }
        
        
        // Setup notifications.
        NSNotificationCenter *notify = [NSNotificationCenter defaultCenter];
        [notify addObserver:self
                   selector:@selector(onStreamError:)
                       name:AVCaptureSessionRuntimeErrorNotification
                     object:session];

        [notify addObserver:self
                   selector:@selector(onStreamStart)
                       name:AVCaptureSessionDidStartRunningNotification
                     object:session];
        
        [notify addObserver:self
                   selector:@selector(onStreamStop)
                       name:AVCaptureSessionDidStopRunningNotification
                     object:session];

        framesPerSecond = fps;
        
        [self useTorch:torch];
        muteSound = mute;
        
        [session beginConfiguration];
        [self setFrameRate: (int32_t)fps];
        [session commitConfiguration];
        
        if (autoAdapt) {
            
            Class networkAdaptiveClass = NSClassFromString(@"NetworkAdaptiveManager");
            
            if (networkAdaptiveClass) {
                // class exists
                adaptiveManager = [[networkAdaptiveClass alloc] init];
                [adaptiveManager setValue: self forKey: @"recorder"];
                [adaptiveManager performSelector: NSSelectorFromString(@"initializeManager") withObject: nil];
            } else {
                
                if (_delegate) {
                    [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"This version of the library does not include network auto-adaptive feature."];
                }
                // class doesn't exist
            }
            

        }
        
        if (saveVideoToCameraRoll) {
            
            Class saveVideoClass = NSClassFromString(@"SaveVideoManager");
            
            if (saveVideoClass) {
                saveVideoManager = [[saveVideoClass alloc] init];
            }
            else {
                
                saveVideoToCameraRoll = NO;
                
                if (_delegate) {
                    [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"This version of the library does not include the saving video feature."];
                }
            }
            

        }
        
        movieWritingQueue = dispatch_queue_create("Movie Writing Queue", DISPATCH_QUEUE_SERIAL);
        
        //audioEncoder = [[AACEncoder alloc] initWithAudioRate: theAudioRate];
        
        // Start session.
        [session startRunning];
        
        audioExtraDataEncoder = [[Encoder alloc] initWithFilename: @"extradataFile.mov"
                                                       andQuality: theVideoResolution
                                                         andAudio: theAudioRate
                                                  andVideoBitRate: theVideoRate
                                                       isPortrait: isPortrait
                                                 keyFrameInterval: kFrameInterval
                                                  didChangePreset: self.changePreset
                                                     videoProfile: self.videoProfile];
        [audioExtraDataEncoder startEncoding];
        
        state = STATE_COLLECTIONG_EXTRA_DATA;
    }

    return self;
}

- (void)detach
{
    [NSThread detachNewThreadSelector: @selector(getExtradata) toTarget: self withObject: nil];
}

- (void)getExtradata
{
    @autoreleasepool {
        state = STATE_PROCESSING_EXTRA_DATA;
        
        [audioExtraDataEncoder finishEncoding];
        
        [NSThread sleepForTimeInterval: 0.1];
        
        av_register_all();
        
        audioExtraDataDemuxer = [[Demuxer alloc] initWithFilename: audioExtraDataEncoder.filename hasAudio: YES hasVideo: NO];
        
        if (!saveVideoManager) {
            [session beginConfiguration];
            [session removeInput: audioInput];
            [session removeOutput: audioOutput];
            [session commitConfiguration];
        }
        
        audioCodecContext = [audioExtraDataDemuxer audioCodec];
        
        [audioExtraDataEncoder release];
        
        state = STATE_STOPPED;
        
        [self performSelectorOnMainThread: @selector(notifySessionReady) withObject: nil waitUntilDone: NO];
    }
}

- (void)notifySessionReady
{
    if (_delegate) {
        [_delegate streamingStateChanged: StreamingState_Ready withMessage: @"Streamer is ready."];
    }
}

#pragma mark -
#pragma mark Setup Encoders

- (void)setupEncoders
{
    if (streamingOrientation == Orientation_All) {
        [session beginConfiguration];
        [[videoOutput connectionWithMediaType: AVMediaTypeVideo] setVideoOrientation: self.referenceOrientation];
        [session commitConfiguration];
    }
    
    if (saveVideoManager) {
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt: theVideoResolution], @"quality",
                                 [NSNumber numberWithFloat: theAudioRate], @"audioRate",
                                 [NSNumber numberWithFloat: theVideoRate], @"videoRate",
                                 [NSNumber numberWithBool: isPortrait], @"portrait",
                                 [NSNumber numberWithInteger: kFrameInterval], @"keyframeInterval",
                                 nil];
        
        [saveVideoManager performSelector: NSSelectorFromString(@"createEncoderWithOptions:") withObject: options];
    }
    
    [self setupEncodersQueue];
}

- (void)setupEncodersQueue
{
    @synchronized(encodersQueue){
        
        @synchronized(encodersQueue) {
            [encodersQueue removeAllObjects];
        }
        
        if (frontEncoder) {
            [frontEncoder release];
            frontEncoder = Nil;
        }

        /*
        if (didStartSending) {
            
            didStartSending = NO;
            
            if (rearEncoder) {
                [rearEncoder release];
                rearEncoder = Nil;
            }
        }
         */
        
        
        Encoder *encoder1 = [[Encoder alloc] initWithFilename: [NSString stringWithFormat: @"encoder1_%d.mov", (int)[[NSDate date] timeIntervalSince1970]]
                                                   andQuality: theVideoResolution
                                                    andAudio: theAudioRate
                                              andVideoBitRate: theVideoRate
                                                   isPortrait: isPortrait
                                             keyFrameInterval: kFrameInterval
                                              didChangePreset: self.changePreset
                                                 videoProfile: self.videoProfile];
        
        Encoder *encoder2 = [[Encoder alloc] initWithFilename: [NSString stringWithFormat: @"encoder2_%d.mov", (int)[[NSDate date] timeIntervalSince1970]]
                                                   andQuality: theVideoResolution
                                                     andAudio: theAudioRate
                                              andVideoBitRate: theVideoRate
                                                   isPortrait: isPortrait
                                             keyFrameInterval: kFrameInterval
                                              didChangePreset: self.changePreset
                                                 videoProfile: self.videoProfile];
        
        Encoder *encoder3 = [[Encoder alloc] initWithFilename: [NSString stringWithFormat: @"encoder3_%d.mov", (int)[[NSDate date] timeIntervalSince1970]]
                                                   andQuality: theVideoResolution
                                                     andAudio: theAudioRate
                                              andVideoBitRate: theVideoRate
                                                   isPortrait: isPortrait
                                             keyFrameInterval: kFrameInterval
                                              didChangePreset: self.changePreset
                                                 videoProfile: self.videoProfile];
        
        rearEncoder = encoder1;
        
        @synchronized(encodersQueue){
            [encodersQueue addObject: encoder1];
            [encodersQueue addObject: encoder2];
            [encodersQueue addObject: encoder3];
            
            [encoder1 release];
            [encoder2 release];
            [encoder3 release];
        }
        
        NSLog(@"");
        
        if (! audioEncoder) {
            audioEncoder = [[AACEncoder alloc] initWithAudioRate: theAudioRate];
            [audioEncoder mute: muteSound];
        }
    }
}

- (void)addEncoderToQueue
{
    @autoreleasepool {
        
        NSString *prefixString = @"MyFilename";
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        NSString *uniqueFileName = [NSString stringWithFormat:@"%@%@.mov", prefixString, (NSString *)uuidString];
        CFRelease(uuidString);
        
        Encoder *encoder = [[Encoder alloc] initWithFilename: uniqueFileName
                                                  andQuality: theVideoResolution
                                                    andAudio: theAudioRate
                                             andVideoBitRate: theVideoRate
                                                  isPortrait: isPortrait
                                            keyFrameInterval: kFrameInterval
                                             didChangePreset: self.changePreset
                                                videoProfile: self.videoProfile];
        changePreset = NO;
        
        @synchronized(encodersQueue){
            [encodersQueue addObject: encoder];
            [encoder release];
        }
    }
}

#pragma mark -
#pragma mark Frame Rate

- (void)setFrameRate:(int32_t)fr
{
    //[encoders lock];
    
    //[session beginConfiguration];
    
    //videoOutput.minFrameDuration = CMTimeMake(1, frameRate);
	
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        NSArray *supportedFrameRateRanges = [[[(AVCaptureDeviceInput*)videoInput device] activeFormat] videoSupportedFrameRateRanges];
        
        if (supportedFrameRateRanges.count > 0) {
            AVFrameRateRange *frameRateRange = [supportedFrameRateRanges objectAtIndex: 0];
            
            if (frameRateRange.minFrameRate <= fr && frameRateRange.maxFrameRate >= fr) {
                
                [[(AVCaptureDeviceInput*)videoInput device] lockForConfiguration: NULL];
                
                [[(AVCaptureDeviceInput*)videoInput device] setActiveVideoMinFrameDuration: CMTimeMake(1, fr)];
                [[(AVCaptureDeviceInput*)videoInput device] setActiveVideoMaxFrameDuration: CMTimeMake(1, fr)];
                
                [[(AVCaptureDeviceInput*)videoInput device] unlockForConfiguration];
            }
            else {
                
                if (_delegate) {
                    [_delegate streamingStateChanged: StreamingState_Warning withMessage: [NSString stringWithFormat: @"The frame rate (%ld) is out of the supported frame rate range for this device [%d..%d]", (long)fr, (int)frameRateRange.minFrameRate, (int)frameRateRange.maxFrameRate]];
                }
            }
            
//            if (CMTIME_COMPARE_INLINE(frameRateRange.minFrameDuration, <=, CMTimeMake(1, fr))) {
//                [[(AVCaptureDeviceInput*)videoInput device] setActiveVideoMinFrameDuration: CMTimeMake(1, fr)];
//            }
//
//            if (CMTIME_COMPARE_INLINE(frameRateRange.maxFrameDuration, >=, CMTimeMake(1, fr))) {
//                [[(AVCaptureDeviceInput*)videoInput device] setActiveVideoMaxFrameDuration: CMTimeMake(1, fr)];
//            }
        }
    }
    else {
        AVCaptureConnection *conn = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
        
        if (conn.supportsVideoMinFrameDuration)
            conn.videoMinFrameDuration = CMTimeMake(1, fr);
        if (conn.supportsVideoMaxFrameDuration)
            conn.videoMaxFrameDuration = CMTimeMake(1, fr);
    }
	
    //[session commitConfiguration];
    
    //[encoders unlock];
}

#pragma mark -
#pragma mark Orientation Setups

- (void)setOutputOrientation:(UIDeviceOrientation)orientation
{
    if (streamingOrientation == Orientation_All) {
        
        switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
                self.referenceOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                self.referenceOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortrait:
                self.referenceOrientation = AVCaptureVideoOrientationPortrait;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                self.referenceOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
                
            default:
                break;
        }
        
        isPortrait = UIDeviceOrientationIsPortrait(orientation) ? YES : NO;
    }
}

- (void)deviceOrientationDidChange
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if ( UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation) ) {
        
        if (state == STATE_STOPPED && streamingOrientation == Orientation_All) {
            
            [self setOutputOrientation: orientation];
        }
    }
}

- (AVCaptureVideoOrientation)captureOrientationFromVideoOrientation:(Video_Orientation)videoOrientation
{
    AVCaptureVideoOrientation orientation;
    
    switch (videoOrientation) {
        case Orientation_LandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case Orientation_LandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case Orientation_Portrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case Orientation_PortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    
    return orientation;
}

#pragma mark -

- (void)dealloc {
    
    [self destroyReachability];
    
    // Teardown encoders.
    if (frontEncoder) {
        [frontEncoder release];
    }
    
    if (encodersQueue) {
        [encodersQueue release];
    }

    // Teardown synchronization objects.
    [encoders release];
    [worker release];
    [stream release];

    [adaptiveManager release];
    [saveVideoManager release];
    
    [audioExtraDataDemuxer release];
    
    [_videoProfile release];
    
    [super dealloc];
}

- (void)endSession
{
    if (saveVideoManager) {
        [session removeInput: audioInput];
        [session removeOutput: audioOutput];
    }
    
    [session stopRunning];

    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    if (previewOutput) {
        NSLog(@"remove preview");
        [previewOutput removeFromSuperlayer];
        [previewOutput release];
    }
    
    [frontVideoDevice release];
    [rearVideoDevice release];
    
    [session release];
    session = nil;
    
    if (movieWritingQueue) {
		dispatch_release(movieWritingQueue);
		movieWritingQueue = NULL;
	}
}

#pragma mark -
#pragma mark Workers

- (void)startTheAudioEncoder
{
    [audioEncoder start];
}

/// The heart of it all, combines the demuxer, encoder and the
/// streamer to send data to the destination server.
- (void)workerThread {
    
    @autoreleasepool {
        
        nlog2(DBGLog, @"Recorder::Worker::Starting...");
        
        [worker lock];
        
        //Streamer *rtmp = nil;
        
        BOOL didCatchError;
        
        @try {
            
            nlog2(DBGLog, @"Recorder::Worker::Sleeping...");
            
            state = STATE_PLAYING;
            [NSThread detachNewThreadSelector: @selector(startTheAudioEncoder) toTarget:self withObject:nil];
            
            [NSThread sleepForTimeInterval:BUFFER_LENGTH];
            
            [encoders lock];
            
            Encoder *firstEncoder;
            
            @synchronized(encodersQueue) {
                firstEncoder = [encodersQueue objectAtIndex: 0];
            }
            
            @synchronized(encodersQueue) {
                rearEncoder = [encodersQueue objectAtIndex: 1];//retain
            }
            
            [rearEncoder startEncoding];
            
            [encoders unlock];
            
            [NSThread detachNewThreadSelector: @selector(finishEncoding)
                                     toTarget: firstEncoder
                                   withObject: nil];
            
            [NSThread sleepForTimeInterval:BUFFER_LENGTH];
            
            BOOL newSessionPreset;
            
            while (state == STATE_PLAYING && ! _noInternet) {
                
                didStartSending = YES;
                
                nlog2(DBGLog, @"Recorder::Worker::Swapping buffers...");
                
                [encoders lock];
                
                NSDate *date;
                
                
                if (frontEncoder) {
                    [frontEncoder release];
                    frontEncoder = Nil;
                }
                
                @synchronized(encodersQueue) {
                    frontEncoder = [[encodersQueue objectAtIndex: 0] retain];
                    [encodersQueue removeObjectAtIndex: 0];
                }
                
                Encoder *midleEncoder;
                
                @synchronized(encodersQueue) {
                    midleEncoder = [encodersQueue objectAtIndex: 0];
                }
                
                [NSThread detachNewThreadSelector: @selector(finishEncoding)
                                         toTarget: midleEncoder
                                       withObject: nil];
                
                @synchronized(encodersQueue) {
                    rearEncoder = [encodersQueue objectAtIndex: 1];// retain];
                }
                
                [rearEncoder startEncoding];
                
                date = [NSDate date];
                
                if ([frontEncoder didChangePreset]) {
                    NSLog(@"we have a preset change ladies and gentleman!!!!!!");
                    newSessionPreset = YES;
                    [self changeSessionPreset: [frontEncoder resolution]];
                }
                else {
                    newSessionPreset = NO;
                }
                
                [encoders unlock];
                
                [NSThread detachNewThreadSelector:@selector(addEncoderToQueue)
                                         toTarget:self
                                       withObject:nil];
                
                nlog2(DBGLog, @"Recorder::Worker::Buffers swapped.");
                
                Demuxer *mov = nil;
                
                // Sleep until the next buffer is finished
                double delay;
                
                if (frontEncoder.notReadyForDealloc) {
                    NSLog(@"goto finally");
                    goto finally;
                }
                
                @try {
                    mov = [[Demuxer alloc] initWithFilename:[frontEncoder filename] hasAudio: NO hasVideo: YES];
                    mov.timeQueue = [frontEncoder getTimeQueue];
                    
                    // While there are frames to read and we still have time to send this buffer.
                    while ([_rtmp writePacket:mov andSendVideo:sendVideo date: date newSize: newSessionPreset audioCodecContext: audioCodecContext]);
                }
                @finally {
                    
                    if (mov) {
                        [mov release];
                    }
                }
                
            finally:
                
                delay = -[date timeIntervalSinceNow];
                
                if (BUFFER_LENGTH - delay > 0) {
                    NSLog(@"Worker::Sleeping... %f",BUFFER_LENGTH - delay);
                    //nlog2(DBGLog, @"Worker::Sleeping... %f", BUFFER_LENGTH - delay);
                    [NSThread sleepForTimeInterval: BUFFER_LENGTH - delay];
                }
            }
            
        } @catch (NSException *exception) {
            nlog(DBGLog, @"Recorder::Worker::%@ %@.", [exception name], [exception reason]);
            
            if (_delegate) {
                [_delegate streamingStateChanged: StreamingState_Error withMessage: [NSString stringWithFormat:  @"Error: %@.", [exception reason]]];
            }
            
            didCatchError = YES;
            //state = STATE_STOPPED;
            
            /*
            if (_delegate) {
                [_delegate streamingStateChanged: StreamingState_Stopped withMessage: @"Stopped due to error."];
            }
             */
        } @finally {
            
            if (_noInternet) {
                didCatchError = YES;
            }
            
            [encoders lock];
            
            [rearEncoder finishEncoding];
            
            if (saveVideoManager) {
                [saveVideoManager performSelector: NSSelectorFromString(@"closeFile") withObject: nil];
            }
            
            [encoders unlock];
            
            nlog2(DBGLog, @"Recorder::Worker::Stopped.");
            
            [_rtmp release];
            _rtmp = NULL;
            [worker unlock];
            
            if (didCatchError) {
                NSLog(@"didCatchError so stop");
                [self stop];
            }
        }
    }
}

/// The other heart of it all, combines the demuxer and the
/// streamer to send data to the destination server.
- (void)workerThread2 {
    nlog2(DBGLog, @"Recorder::Worker2::Starting...");
    
    [worker lock];
    
    Streamer *streamer = nil;
    
    @try {
        nlog2(DBGLog, @"Recorder::Worker2::Opening connection to server...");
        
        streamer = [[Streamer alloc] initWithUrl: destination
                                    andAudioRate: theAudioRate
                                    bufferLength: BUFFER_LENGTH
                                  adaptToNetwork: autoAdaptToNetwork
                                callbackListener: _delegate];
        
        Demuxer *mov = nil;
        
        @try {
            mov = [[Demuxer alloc] initWithFilename:path hasAudio: YES hasVideo: YES];
            
            while (state == STATE_PLAYING && [streamer writePacket:mov andSendVideo:sendVideo date: nil newSize: NO audioCodecContext: NULL]);
        } @catch (NSException *exception) {
            nlog(DBGLog, @"Recorder::Worker2::%@ %@.", [exception name], [exception reason]);
            
            state = STATE_STOPPED;
            
            if (_delegate) {
                [_delegate streamingStateChanged: StreamingState_Error withMessage: [NSString stringWithFormat:@"Likely could not find input file: '%@'.", [exception reason]]];
            }
        } @finally {
            [mov release];
        }
    } @catch (NSException *exception) {
        nlog(DBGLog, @"Recorder::Worker2::%@ %@.", [exception name], [exception reason]);
        
        state = STATE_STOPPED;
    } @finally {
        [streamer release];
        [worker unlock];
        [self onStreamStop];
        [self onStreamStart];
        
        nlog2(DBGLog, @"Recorder::Worker2::Stopped.");
        
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Stopped withMessage: @"Streaming Stopped."];
        }
    }
}

#pragma mark -
#pragma mark Session Preset Setup

- (void)changeSessionPreset:(VideoResolution)resolution
{
    NSLog(@"changeSessionPreset");
    
    [session beginConfiguration];
    
    [session setSessionPreset: [self sessionPresetForResolution: resolution]];
    
    [session commitConfiguration];
}

- (NSString *)sessionPresetForResolution:(VideoResolution)resolution
{
    NSString *returnResolution;
    
    switch (resolution) {
        case VideoResolution_192x144:
            returnResolution = AVCaptureSessionPresetLow;
            break;
        case VideoResolution_320x240:
            returnResolution = AVCaptureSessionPreset352x288;
            break;
        case VideoResolution_480x360:
            returnResolution = AVCaptureSessionPresetMedium;
            break;
        case VideoResolution_640x480:
            returnResolution = AVCaptureSessionPreset640x480;
            break;
        case VideoResolution_1280x720:
            returnResolution = AVCaptureSessionPreset1280x720;
            break;
        case VideoResolution_1920x1080:
            returnResolution = AVCaptureSessionPreset1920x1080;
            break;
        default:
            break;
    }
    
    return returnResolution;
}

#pragma mark - Events

- (void)onStreamStart {
    nlog2(DBGLog, @"Recorder::Session starting...");

    [stream lockWhenCondition:0];
    [stream unlockWithCondition:1];

    nlog2(DBGLog, @"Recorder::Session started.");
}

- (void)onStreamStop {
    nlog2(DBGLog, @"Recorder::Stopping session...");

    [self stop];
    [stream lockWhenCondition:1];
    [stream unlockWithCondition:0];

    nlog2(DBGLog, @"Recorder::Session stopped.");
}

- (void)onStreamError:(NSNotification *)notification {

    nlog2(DBGError, @"Recorder::Stream error.");

    NSLog(@"User Info: %@", notification.userInfo);
    
    [stream lock];
    [stream unlockWithCondition:2];

    nlog2(DBGError, @"Recorder::Stream invalidated. This should never happen.");
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
//    NSLog(@"didDropSampleBuffer with reason: ");
//    
//    CFTypeRef typeRef = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_DroppedFrameReason, NULL);
//    
//    CFStringRef myString = CFCopyDescription (typeRef);
//    
//    NSLog(@"%@", (NSString *)myString);
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {

    CFRetain(sampleBuffer);
    dispatch_async(movieWritingQueue, ^{
        
        //NSLog(@"didOutputSampleBuffer");
        if (state == STATE_COLLECTIONG_EXTRA_DATA && captureOutput == audioOutput) {
            
            [audioExtraDataEncoder appendSample: sampleBuffer isAudio: YES];
            
            [self detach];
        }
        else if (state == STATE_PLAYING) {
            
            BOOL isAudio = captureOutput == audioOutput;
            
            if (! isAudio) {
                
                [encoders lock];
                
                //[rearEncoder appendSample: sampleBuffer isAudio: NO];
                
                if (dropFrames) {
                    
                    frameCounter++;
                    
                    if (frameCounter < frameDroppingFrequency) {
                        [rearEncoder appendSample:sampleBuffer isAudio: NO];
                    }
                    else {
                        //NSLog(@"drop frame------------------");
                        frameCounter = 0;
                    }
                }
                else {
                    [rearEncoder appendSample:sampleBuffer isAudio: NO];
                }
                
                [encoders unlock];
            }
            
            
            if (saveVideoManager) {
                
                CMSampleWrapper *sampleBufferWrapper = [[CMSampleWrapper alloc] init];
                sampleBufferWrapper->sampleBuffer = sampleBuffer;
                //CMSampleBufferCopySampleBufferForRange(kCFAllocatorDefault, sampleBuffer, CFRangeMake(0, 100), &(sampleBufferWrapper->sampleBuffer));
                sampleBufferWrapper->isAudio = isAudio;
                
                //[saveVideoManager performSelectorInBackground: NSSelectorFromString(@"appendSample:") withObject: sampleBufferWrapper];
                [saveVideoManager performSelector: NSSelectorFromString(@"appendSample:") withObject: sampleBufferWrapper];
                
                [sampleBufferWrapper release];
            }
        }
        
        CFRelease(sampleBuffer);
	});
}

#pragma mark - Public API

/// Begin the recording process.
- (void)start {
    
    NSLog(@"START");
    
    //dropFrames = YES;
    //frameDroppingFrequency = 2;
    
    if (state == STATE_COLLECTIONG_EXTRA_DATA || state == STATE_PROCESSING_EXTRA_DATA) {
        
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Error withMessage: @"The stream is initialising."];
        }
        
        return;
    }
    
    if (_noInternet || [_reachability currentReachabilityStatus] == kRTMPNetworkStatusNotReachable) {
        
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Error withMessage: @"Check your internet connection."];
        }
        
        return;
    }
    
    if (waitingToProperlyStop) {
        
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Error withMessage: @"Waiting to properly stop previous session."];
        }
        return;
    }
    
    if (waitingForVideoToBeSaved) {
        
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Error withMessage: @"Waiting for previous video to be saved"];
        }
        
        return;
    }
    
    if ([rearEncoder notReadyForDealloc]) {
        
    }
    
    nlog2(DBGLog, @"Recorder::Start encoding...");
    
    [stream lockWhenCondition:1];
    
    if (state != STATE_STOPPED) {
        [stream unlock];
        nlog2(DBGLog, @"Recorder::Already encoding.");
        
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"The streaming is already running."];
        }
        return;
    }
    
    if (_delegate) {
        [_delegate streamingStateChanged: StreamingState_Starting withMessage: @"Preparing to start."];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    frameCounter = 0;
    
    if (adaptiveManager) {
        [adaptiveManager performSelector: NSSelectorFromString(@"resetManager") withObject: nil];
    }
    
    switch (type) {
        case LIVE_RECORDER:
            
            nlog2(DBGLog, @"Recorder::Worker::Opening connection to server...");
        
            BOOL thereHasBeenAnError = NO;
        
            @try {
                _rtmp = [[Streamer alloc] initWithUrl: destination
                                    andAudioRate: theAudioRate
                                    bufferLength: BUFFER_LENGTH
                                  adaptToNetwork: autoAdaptToNetwork
                                callbackListener: _delegate];
            }
            @catch (NSException *exception) {
                thereHasBeenAnError = YES;
                [stream unlock];
            }
            @finally {
                
            }
        
            if (thereHasBeenAnError) {
                return;
            }
        
        
            sessionJustStarted = YES;
        
            [self performSelectorOnMainThread: @selector(setupEncoders) withObject: nil waitUntilDone: YES];
        
            if (saveVideoManager) {
                [saveVideoManager performSelector: NSSelectorFromString(@"startWriting") withObject: nil];
            }
        
            _rtmp.audioQueue = audioEncoder.audioQueue;
            _rtmp.audioOffsetDelegate = audioEncoder;
        
            [rearEncoder startEncoding];
        
            [NSThread detachNewThreadSelector:@selector(workerThread)
                                     toTarget:self
                                   withObject:nil];
            break;
        case VIDEO_RECORDER:
            
            state = STATE_PLAYING;
            
            [NSThread detachNewThreadSelector:@selector(workerThread2)
                                    toTarget:self
                                  withObject:nil];
            break;
    }

    [stream unlock];

    [_delegate streamingStateChanged: StreamingState_Started withMessage: @"Streaming started."];
    
    nlog2(DBGLog, @"Recorder::Encoding started.");
}

- (void)stop {
    
    [stream lockWhenCondition:1];
    
    if (state != STATE_PLAYING) {
        [stream unlock];
        nlog2(DBGLog, @"Recorder::Not encoding.");
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"Streaming was not runnig."];
        }
        return;
    }
    
    state = STATE_STOPPED;
    
    [audioEncoder stop];
    
    waitingToProperlyStop = YES;
    
    if (_delegate) {
        [_delegate streamingStateChanged: StreamingState_Stopping withMessage: @"Streaming is stopping."];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    
    nlog2(DBGLog, @"Recorder::Stop encoding...");
    
    switch (type) {
        case LIVE_RECORDER:
            //[encoders lock];
            
            NSLog(@"stop everything - finish encoding");
            
            //[rearEncoder finishEncoding];
            
            /*
             if (saveVideoManager) {
             [saveVideoManager performSelector: NSSelectorFromString(@"closeFile") withObject: nil];
             }
             */
            
            //[encoders unlock];
            break;
        case VIDEO_RECORDER:
            break;
    }
    
    //give it time to close encoders
    //[NSThread sleepForTimeInterval: 3.0];
    
    nlog2(DBGLog, @"Recorder::Encoding stopped.");
    
    [self setOutputOrientation: [[UIDevice currentDevice] orientation]];
    
    waitingToProperlyStop = NO;
    
    //give it time to properly close the session
    [NSThread sleepForTimeInterval: 1.0];
    
    [worker lock];
    [worker unlock];
    
    [stream unlock];
    
    if (_delegate) {
        [_delegate streamingStateChanged: StreamingState_Stopped withMessage: @"Streaming stopped."];
    }
    
    //[self stopEverything];
    
}

//- (void)stopEverything
//{
//    
//}

/// Block the main thread until `timeout` has been reached.
/// @param timeout The maximum amount of time to wait.
/// @return NO if the timeout was reached.
- (bool)join:(int)timeout {
    if (state != STATE_PLAYING)
        return YES;

    if ([worker lockBeforeDate:[[NSDate date] dateByAddingTimeInterval:timeout]]) {
        [worker unlock];
        return YES;
    }

    return NO;
}

/// @return Whether or not the recorder is ready to stream.
- (bool)ready {
    return ready;
}

/// @return Whether or not the recorder is active.
- (bool)active {
    return state != STATE_STOPPED;
}

- (void)mute:(BOOL)value{
    
    muteSound = value;
    
    if (audioEncoder) {
        [audioEncoder mute: value];
    }
}

/// Start/Stop sending video frames.
- (void)showVideo:(BOOL)show {
    sendVideo = show;
}

- (BOOL) hasMultipleCameras {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1 ? YES : NO;
}

/// Setter for whether or not to use the front camera.
/// @param front YES to use front camera, NO to use the back one.
- (void)useFrontCamera:(BOOL)front completion:(void (^)(BOOL success))completionBlock{

    self.changeCameraCompletionBlock = completionBlock;
    [self performSelectorInBackground: @selector(changeCameraToFront:) withObject: [NSNumber numberWithBool: front]];
}

- (void)changeCameraToFront:(NSNumber *)frontNumber
{
    @autoreleasepool {
        
        BOOL front = frontNumber.boolValue;
        
        NSLog(@"FRONT: %d", front);
        
        if ([self hasMultipleCameras]) {
            
            AVCaptureDevice *device = front ? frontVideoDevice
            : rearVideoDevice;
            
            NSString *sessionPreset = [session sessionPreset];
            
            if ([device supportsAVCaptureSessionPreset: sessionPreset]) {
                
                [session beginConfiguration];
                [session removeInput:videoInput];
                
                videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                [session addInput: videoInput];
                
                if (streamingOrientation == Orientation_All) {
                    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
                    [[videoOutput connectionWithMediaType: AVMediaTypeVideo] setVideoOrientation: self.referenceOrientation];
                }
                else {
                    [[videoOutput connectionWithMediaType: AVMediaTypeVideo] setVideoOrientation: [self captureOrientationFromVideoOrientation: streamingOrientation]];
                }
                
                [self setFrameRate: (int32_t)framesPerSecond];
                
                [session commitConfiguration];
                
                self.changeCameraCompletionBlock(YES);
            }
            else {
                
                self.changeCameraCompletionBlock(NO);
                
                if (_delegate) {
                    [_delegate streamingStateChanged: StreamingState_Warning withMessage: [NSString stringWithFormat: @"The camera doesn't support this session preset: %@", sessionPreset]];
                }
            }
        }
        else {
            
            self.changeCameraCompletionBlock(NO);
            
            if (_delegate) {
                [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"The device doesn't have multiple cameras."];
            }
        }
    }
}

/// Setter for whether or not to turn the back LED on.
/// @param torch Whether or not to turn the back LED on.
- (void)useTorch:(BOOL)torch {
    AVCaptureTorchMode mode = torch ? AVCaptureTorchModeOn: AVCaptureTorchModeOff;

    if ([rearVideoDevice isTorchModeSupported: mode] && [rearVideoDevice isTorchAvailable]) {
        [rearVideoDevice lockForConfiguration:&error];
        [rearVideoDevice setTorchMode:mode];
        [rearVideoDevice unlockForConfiguration];
    }
}

- (void)setPathWithServer: (NSString *)server
                 username: (NSString *)username
              andPassword: (NSString *)password
{
    if (state == STATE_STOPPED) {
        
        NSString *oldDestination = [NSString stringWithString: destination];
        
        [destination release];
        destination = [[self rtmpPathFromServer: server user: username andPass: password] retain];
        
        if ( ! destination) {
            
            if (_delegate) {
                [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"Invalid rtmp configuration. The destination Path was not modified."];
            }
            
            destination = [oldDestination retain];
        }
    }
    else {
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"Cannot modify destination path while streaming."];
        }
    }
}

- (void)setPreview:(UIView *)preview
{
    if (state == STATE_STOPPED) {
        
        if (previewOutput) {
            [previewOutput removeFromSuperlayer];
            [previewOutput setFrame:[preview bounds]];
            [[preview layer] insertSublayer: previewOutput atIndex: 0];
            [previewOutput setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        }
        else {
            previewOutput = [[AVCaptureVideoPreviewLayer alloc] initWithSession: session];
            [previewOutput setFrame:[preview bounds]];
            [[preview layer] insertSublayer: previewOutput atIndex: 0];
            [previewOutput setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        }
    }
    else {
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"Cannot change the preview while streaming"];
        }
    }
}

- (void)setVideoQuality:(VideoResolution)videoResolution
{
    theVideoResolution = videoResolution;
}

- (void)setAudioRate:(double)audioRate
{
    if (state == STATE_STOPPED) {
        theAudioRate = audioRate;
        
        if (audioEncoder) {
            [audioEncoder setAudioRate: audioRate];
        }
    }
    else {
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"Cannot change the audio rate while streaming"];
        }
    }
}

- (void)setVideoBitrate:(NSInteger)videoBitRate
{
    theVideoRate = videoBitRate;
}

- (void)setKeyFrameInterval:(NSInteger)keyFrameInterval
{
    kFrameInterval = keyFrameInterval;
}

- (void)setFPS:(NSInteger)fps
{
    [session beginConfiguration];
    [self setFrameRate: (int32_t)fps];
    [session commitConfiguration];
}

- (void)setBufferLength:(double)bufferLength
{
    if (state == STATE_STOPPED) {
        BUFFER_LENGTH = bufferLength;
    }
    else {
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"Cannot change the buffer length while streaming"];
        }
    }
}

- (void)setPreviewOrientation:(Video_Orientation)previewOrientation
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.9) {
        
        if ([[previewOutput connection] isVideoOrientationSupported]) {
            
            [[previewOutput connection] setVideoOrientation: [self captureOrientationFromVideoOrientation: previewOrientation]];
        }
    } else {
        if ([previewOutput isOrientationSupported]) {
            [previewOutput setOrientation: [self captureOrientationFromVideoOrientation: previewOrientation]];
        }
    }
}

- (void)saveVideoToCameralRoll:(BOOL)save
{
    if (_delegate) {
        [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"This version does not include the following extra feature: Save video to camera roll"];
    }
}

- (void)autoAdaptToNetwork:(BOOL)adapt
{
    if (_delegate) {
        [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"This version does not include the following extra feature: Auto adapt video bitrate"];
    }
}

- (void)allowResolutionChanges:(BOOL)allowChanges
{
    if (state == STATE_STOPPED) {
        allowsVideoResolutionChanges = allowChanges;
    }
    else {
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"Cannot make modifications on the \"allow resolution changes\" property while streaming"];
        }
    }
}

- (void)valiOrientations:(Video_Orientation)videoOrientations
{
    if (state == STATE_STOPPED) {
        streamingOrientation = videoOrientations;
        [self captureOrientationFromVideoOrientation: videoOrientations];
    }
    else {
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"Cannot modify the video orientation while streaming"];
        }
    }
}

- (void)changePreviewFrame:(CGRect)newFrame
{
    previewOutput.frame = newFrame;
}

- (void)setVideoProfileLevel:(NSString *)h264ProfileLevel
{
    if (state == STATE_STOPPED) {
        self.videoProfile = h264ProfileLevel;
    }
    else {
        
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_Warning withMessage: @"Cannot change the video profile level while streaming"];
        }
    }
}

#pragma mark -
#pragma mark Save video manager notifications

- (void)savingFileStateChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    waitingForVideoToBeSaved = [[userInfo objectForKey: @"waitingForVideoToBeSaved"] boolValue];
}

#pragma mark -
#pragma mark Background Tasks

- (void)applicationDidEnterBackground
{
//    NSLog(@"applicationDidEnterBackground");
//    
//    if (state == STATE_PLAYING) {
//        sessionWasRunnig = YES;
//        [self stopEverything];
//    }
}

- (void)applicationDidEnterForeground
{
//    NSLog(@"applicationDidEnterForeground");
//    
//    if (sessionWasRunnig) {
//        sessionWasRunnig = NO;
//        [self performSelector: @selector(start) withObject: nil afterDelay: 0.5];
//    }
}

#pragma mark -
#pragma mark Create / Destroy Reachability

- (void)initReachability {
    if(_reachability == nil) {
        _reachability = [[RTMPReachability reachabilityForInternetConnection] retain];
        [_reachability startNotifier];
    }
}

- (void)destroyReachability {
    [_reachability stopNotifier];
    [_reachability release];
    _reachability = nil;
}

#pragma mark -
#pragma mark Reachability callback

- (void)onReachabilityChanged:(NSNotification *)notification {
    RTMPNetworkStatus status = [_reachability currentReachabilityStatus];
    
    /*
    if (state == STATE_STOPPED) {
        return;
    }
     */
    
    if(status == kRTMPNetworkStatusReachableViaWiFi) {
        
    } else if (status == kRTMPNetworkStatusReachableViaWWAN) {
        
    }else if (status == kRTMPNetworkStatusNotReachable) {
        
        NSLog(@"kRTMPNetworkStatusNotReachable");
        
        
        if (_delegate) {
            [_delegate streamingStateChanged: StreamingState_NoInternet withMessage: @"No internet connection."];
        }
        
        _noInternet = YES;
        
        if (_rtmp) {
            _rtmp.abortIsRequested = YES;
        }
        
        [self stop];
        
        //[self performSelectorOnMainThread: @selector(stop) withObject: nil waitUntilDone: NO];
        
        return;
    }
    
    _noInternet = NO;
    
    if (_rtmp) {
        _rtmp.abortIsRequested = NO;
    }
    
    /*
    [[NSNotificationCenter defaultCenter] postNotificationName: NetworkStateChangedNotification
                                                        object: nil
                                                      userInfo: [NSDictionary dictionaryWithObject: [NSNumber numberWithBool: NO]
                                                                                            forKey: @"noInternet"]];
     */
}

- (BOOL)hasInternetConnection
{
    return ! [_reachability currentReachabilityStatus] == kRTMPNetworkStatusNotReachable;
}

@end
