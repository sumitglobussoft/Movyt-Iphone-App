//
//  Encoder.m
//  Streaming
//
//  Created by Radu Dan on 10/23/11.
//  Copyright (c) 2011 Medina Software. All rights reserved.
//

#import "Encoder.h"
#import "Util.h"
#import "VideoSessionManager.h"

@implementation CMSampleWrapper

- (void)dealloc
{
    //CFRelease(self->sampleBuffer);
    [super dealloc];
}

@end

@interface Encoder ()
{
    BOOL presetChanged;
    BOOL isNotReadyForDealloc;
    VideoResolution currentResolution;
    
    NSMutableArray *timeQueue;
}
@end

@implementation Encoder

/// Create a new Encoder.
/// @param filename The path where the encoded file will be saved.
/// @param theQuality The quality of the video stream (one of 192, 480 or 640).
/// @param audioRateValue The audio bit trate.
/// @param videoBitrate The video bit rate.
- (id)initWithFilename:(NSString *)filename
            andQuality:(VideoResolution)theResolution
              andAudio:(double)audioRateValue
       andVideoBitRate:(NSInteger)videoBitrate
            isPortrait:(BOOL)isPortrait
      keyFrameInterval:(NSInteger)keyframeInterval
       didChangePreset:(BOOL)changePreset
          videoProfile:(NSString *)videoProfile
{
    if (self = [super init]) {
        
        NSInteger width = 0;
        NSInteger height = 0;
        
        timeQueue = [[NSMutableArray alloc] init];
        
        presetChanged = changePreset;
        currentResolution = theResolution;
        
        NSString *videoProfileLevel = [VideoSessionManager videoProfileForWidth: &width
                                                                         height: &height
                                                                  forResolution: &theResolution];
        
        if (videoProfile) {
            videoProfileLevel = videoProfile;
        }
        
        if ( ! videoProfileLevel) {
            
            @throw [NSException exceptionWithName:@"EncoderError"
                                           reason:[NSString stringWithFormat:@"This resolution is not supported."]
                                         userInfo:nil];
            
            return nil;
        }
        
        if (isPortrait) {
            NSInteger aux = width;
            width = height;
            height = aux;
        }
        
        osVersion = [[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue];

        //nlog(DBGLog, @"Encoder::Initialising with width=%ld, height=%ld, bitrate=%ld, newResolution=%d", (long)width, (long)height, (long)videoBitrate, presetChanged);

        // Get application path.
        NSString *appPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

        // Get buffer path and url.
        path = [[appPath stringByAppendingPathComponent:filename] retain],
        url = [[NSURL alloc] initFileURLWithPath:path];

        // Setup encoding format.
        AudioChannelLayout channelDescriptor;
        bzero(&channelDescriptor, sizeof(channelDescriptor));

        // WARNING: If modified, must also change Streamer::setAudioFormat parameters.
        channelDescriptor.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;

        NSDictionary *audioFormat = @{AVFormatIDKey         : [NSNumber numberWithInt:kAudioFormatMPEG4AAC],
                                      AVSampleRateKey       : [NSNumber numberWithFloat:audioRateValue],
                                      AVNumberOfChannelsKey : @1,
                                      AVChannelLayoutKey    : [NSData dataWithBytes:&channelDescriptor length:sizeof(channelDescriptor)],
                                      AVEncoderBitRateKey   : [NSNumber numberWithInt:64 * 1024]};

        NSDictionary *videoFormat = @{AVVideoCodecKey  : AVVideoCodecH264,
                                      AVVideoWidthKey  : [NSNumber numberWithInteger:width],
                                      AVVideoHeightKey : [NSNumber numberWithInteger:height],
                                      AVVideoCompressionPropertiesKey : @{AVVideoAverageBitRateKey      : [NSNumber numberWithInteger:videoBitrate],
                                                                          AVVideoMaxKeyFrameIntervalKey : [NSNumber numberWithInteger:keyframeInterval],
                                                                          AVVideoProfileLevelKey        : videoProfileLevel}};

        NSLog(@"video profile level : %@", videoProfileLevel);
        
        // Initialize encoder inputs.
        audio = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioFormat] retain];
        video = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoFormat] retain];

        [audio setExpectsMediaDataInRealTime:YES];
        [video setExpectsMediaDataInRealTime:YES];
        
        //[video setTransform: CGAffineTransformMakeRotation(-M_PI_2)];

        state = [[NSConditionLock alloc] initWithCondition:0];
        manager = [[NSFileManager alloc] init];
    }

    return self;
}

- (void)dealloc {
    
    NSLog(@"dealloc 1");
    
    if ([state lockWhenCondition:1 beforeDate:[NSDate date]]) {
        if (osVersion < 6) {
            [writer finishWriting];
            [writer release];
            [state unlockWithCondition: 0];
        } else {
            [writer finishWritingWithCompletionHandler:^{
                NSLog(@"dealloc 2");
                [writer release];
                [state unlockWithCondition: 0];
            }];
        }
    
    }
    
    if ([manager fileExistsAtPath:path])
        [manager removeItemAtPath:path error:&error];
    
    // Release buffer path and url.
    [path release];
    [url release];

    // Release encoder and inputs.
    [video release];
    [audio release];

    // Release threading objects.
    [manager release];
    [state release];

    [timeQueue release];
    
    NSLog(@"dealloc 3");
    
    [super dealloc];
}

- (void)transformVideoInput:(CGAffineTransform)transform
{
    video.transform = transform;
}

/// Open associated file buffer and redirect all future samples to it.
- (void)startEncoding {
    
    [state lockWhenCondition:0];

    // Ensure buffer file don't exist.
    if ([manager fileExistsAtPath:path])
        [manager removeItemAtPath:path error:&error];

    // Initialize encoder.
    writer = [[AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:&error] retain];
    [writer setShouldOptimizeForNetworkUse:YES];
    [writer addInput:video];
    [writer addInput:audio];
    
    if (! [writer startWriting]) {
        NSLog(@"the writer didn't start writing!!!!!!!!!!!!!!!!!!!");
    }
    
    start = YES;

    //Switch state to encoding.
    [state unlockWithCondition:1];
}

/// Flush all received samples to disc and stall any further samples.
- (void)finishEncoding {
    
    isNotReadyForDealloc = YES;
    
    [state lockWhenCondition:1];
    
    [audio markAsFinished];
    [video markAsFinished];
    
    if (osVersion < 6) {
        [writer finishWriting];
        [writer release];
        [state unlockWithCondition:0];
        
        isNotReadyForDealloc = NO;
    } else {
        // Will not work if there's a race condition a-brewin'.
        [state unlockWithCondition:0];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
//            if (lastTime.value != 0 && lastTime.timescale != 0) {
//                [writer endSessionAtSourceTime: lastTime];
//            }
            [writer finishWritingWithCompletionHandler:^{
                isNotReadyForDealloc = NO;
                [writer release];
                
                [[NSNotificationCenter defaultCenter] postNotificationName: @"encoderDidFinishEncoding"
                                                                    object: nil
                                                                  userInfo: [NSDictionary dictionaryWithObject: self.filename
                                                                                                        forKey: @"filename"]];
            }];
        });
    }
}

- (void)closeWriter
{
    
}

- (void)appendSample:(CMSampleBufferRef)sampleBuffer isAudio:(bool)isAudio {
    if (!CMSampleBufferDataIsReady(sampleBuffer))
        return;

    // Wait for encoding to start.
    [state lockWhenCondition:1];

    // Start encoding if this is the first sample.
    if (start) {
        start = NO;
        
        //lastTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        [writer startSessionAtSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
    }
    
    // Get sample type.
    AVAssetWriterInput *target = isAudio ? audio : video;

    // Drop sample buffer if the encoder is busy.
    if ([target isReadyForMoreMediaData]) {
        [target appendSampleBuffer: sampleBuffer];
        //NSLog(@"append audio sample: %d", isAudio);
    }

    [state unlock];
    
    CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    if (!isAudio) {
        
        int64_t pts = time.value / 1000000;
        
        [timeQueue addObject: [NSNumber numberWithUnsignedLongLong: pts]];
    }
}

/// @return The path where the movie is being saved.
- (NSString *)filename {
  return path;
}

- (BOOL)didChangePreset {
    return presetChanged;
}

- (VideoResolution)resolution
{
    return currentResolution;
}

- (BOOL)notReadyForDealloc
{
    return isNotReadyForDealloc;
}

- (NSMutableArray *)getTimeQueue
{
    return timeQueue;
}

@end
