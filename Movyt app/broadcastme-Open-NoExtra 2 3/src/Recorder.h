//
//  Recorder.h
//  Streaming
//
//  Created by Radu Dan on 10/19/11.
//  Copyright (c) 2011 Medina Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "Demuxer.h"
#import "Encoder.h"
#import "Streamer.h"
#import "Util.h"

#import "StreamingCallbackListener.h"


/// All the possible states that the Recorder can be in.
typedef enum {
    STATE_STOPPED,
    STATE_PLAYING,
    STATE_STARTING,
    STATE_STOPPING,
    STATE_COLLECTIONG_EXTRA_DATA,
    STATE_PROCESSING_EXTRA_DATA
} RecorderState;

// All the possible types of Recorders.
typedef enum {
  LIVE_RECORDER,
  VIDEO_RECORDER
} RecorderType;

/// Ties everything together.
/// This is the main entry point of the library.
@interface Recorder : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate> {
    AVCaptureSession *session;

    AVCaptureDevice *frontVideoDevice,
                    *rearVideoDevice;

    AVCaptureInput *audioInput,
                   *videoInput;

    AVCaptureAudioDataOutput *audioOutput;
    AVCaptureVideoDataOutput *videoOutput;

    AVCaptureVideoPreviewLayer *previewOutput;

    // The two media encoders.
    Encoder *frontEncoder, *rearEncoder;

    // The RTMP address to which to stream.
    NSString *destination;

    // The path to the file that is being streamed (if any).
    NSString *path;

    // Locked while the encoders are being used.
    NSLock *encoders;

    // Locked while the worker thread is running.
    NSLock *worker;

    NSConditionLock *stream;

    // Holds the last error that was passed in from one of the native methods.
    NSError *error;

    // The current audio volume (<= 1.0).
    CGFloat volume;

    // The current state of the recorder.
    RecorderState state;

    // The type of this recorder.
    RecorderType type;

    // Whether or not the recorder is ready to stream.
    bool ready;

    // Whether or not to send video frames.
    bool sendVideo;
}

@property (nonatomic, assign) id<StreamingCallbackListener> delegate;
@property (nonatomic, assign) CGFloat theVideoRate;
@property (nonatomic, assign) VideoResolution theVideoResolution;
@property (nonatomic, assign) BOOL dropFrames;
@property (nonatomic, assign) BOOL allowsVideoResolutionChanges;
@property (nonatomic, assign) BOOL changePreset;
@property (nonatomic, assign) int frameDroppingFrequency;
@property (nonatomic, assign) NSInteger framesPerSecond;
@property (nonatomic) BOOL noInternet;
@property (nonatomic, readonly) Streamer *rtmp;

/**
 Initialization method for LIVE video stream.
 
 @param server The RTMP full path. Example: rtmp://server_name/application_name/stream_name
 @param username The RTMP authentication username if it is required. Pass nil if the RTMP application doesn't require authentication.
 @param password The RTMP authentication password if it is required. Pass nil if the RTMP application doesn't require authentication.
 @param preview A UIView instance of the video preview. You can pass the self.view instance of the UIViewController that is displaying the video.
 @param mute If YES, there will be no sound recorded; sound will be recorded otherwise
 @param front If TRUE it sets the front camera (Facetime camera) as the default one. Else the back camera is used.
 @param torch If TRUE the torch is on by default. 
 @param videoResolution The video resolution of the stream. The value must be within the VideoResolution enumeration.
 @param audioRate The audio rate in Hz. The recommended value is 441000 Hz.
 @param videoBitRate The video bit rate per second. We recommend using values between MainimumBitrates and MaximumBitrates enumerations for each resolution respectively.
 @param keyframeInterval The video codec key frame interval.
 @param fps The number of frames per second. Be aware that not every device has the same maximum fps.
 @param showVideo If FALSE the library will only send audio streams.
 @param saveVideo If TRUE the streamed video will also be saved into the phone's Photo Library. This feature is currently supported only for resolutions smaller or eqaual to VideoResolution_640x480
 @param autoAdapt If TRUE the library manager will adapt the video settings to the network and device performances (upload speed, routing, device capabilities etc). If the network doesn't supply enough performance for the chosen configuration the manager will decrease the video bitrate, drop video frames or even decrease the video resolution. When the network improves its performance, the video settings start to gain bitrate, frames per second and higher resolution until is reaches the initial ones (not more than the ones passed initially)
 @param allowChanges This is only took into consideration if 'autoAdapt' is TRUE. If TRUE than it allows the adapt manager to decrease and increase video resolution. If FALSE then the adapt manager will only change bitrate and number of frames per second.
 @param bufferLength This the local buffer length in seconds. It's value must not be smaller than 1.0 for presets smaller or equal to VideoResolution_1280x720 and not smaller than 1.5 for the VideoResolution_1920x1080 preset.
 @param orientation Represents the allowed video orientations. Must be a value within the Video_Orientation enumeration. If Orientation_All is passed then the device orientation in the moment of startind the stream will be considered.
 @param previewOrientation The preview orientation should have the same orientation as the UIViewController that contains it; THIS VALUE SHOULD NOT BE Orientation_All !!! If its value is Orientation_All, Orientation_Portrait will be considered
 
 @return A new Recorder instance ready to stream or nil if something went wrong.
 */

- (id)       initWithServer: (NSString *)server
                   username: (NSString *)username
                   password: (NSString *)password
                    preview: (UIView *)preview
                       mute: (BOOL)mute
           callbackListener: (id<StreamingCallbackListener>)callbackListener
           usingFrontCamera: (bool)front
                 usingTorch: (bool)torch
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
         previewOrientation: (Video_Orientation)previewOrientation;

/**
 Call this method to start streaming. It may be called only after initialization.
 */
- (void)start;

/**
 Call this method to stio the streaming.
 */
- (void)stop;

/**
 Call this method to check if the streamer is running
 
 @return Whether or not the recorder is active.
 */
- (bool)active;

- (void)setPathWithServer: (NSString *)server
                 username: (NSString *)username
              andPassword: (NSString *)password;

- (void)setPreview:(UIView *)preview;

- (void)setVideoQuality:(VideoResolution)videoResolution;

- (void)setAudioRate:(double)audioRate;

- (void)setVideoBitrate:(NSInteger)videoBitRate;

- (void)setKeyFrameInterval:(NSInteger)keyFrameInterval;

- (void)setFPS:(NSInteger)fps;

- (void)setBufferLength:(double)bufferLength;

- (void)setPreviewOrientation:(Video_Orientation)previewOrientation;

- (void)saveVideoToCameralRoll:(BOOL)save;

- (void)autoAdaptToNetwork:(BOOL)adapt;

- (void)allowResolutionChanges:(BOOL)allowChanges;

- (void)valiOrientations:(Video_Orientation)videoOrientations;

- (void)changePreviewFrame:(CGRect)newFrame;

/**
 Set the video H264 profile level. We recommend changing this only if you know what you're doing! Call this method only when the streaming is NOT running. Nothing will happen otherwise.
 @param h264ProfileLevel NSString representing the H264 profile level. Use a value from AVVideoSettings.h (AVVideoProfileLevelKey)
 */
- (void)setVideoProfileLevel:(NSString *)h264ProfileLevel;

/**
 Call this method to mute / unmute the audio.
 
 @param value If YES, there will be no sound recorded; sound will be recorded otherwise
 */
- (void)mute:(BOOL)value;

/**
 The video stream can be shown or hidden while the recorder is streaming.
 
 @param show BOOL value stating whether or not the video stream should be sent
 */
- (void)showVideo:(BOOL)show;

/**
 Change the device active camera. Make sure that the camera that you want to be used supports the current resolution, otherwise it won't have any effect.
 
 @param front BOOL value stating whether or not to use the front camera
*/
- (void)useFrontCamera:(BOOL)front completion:(void (^)(BOOL success))completionBlock;

/**
 One may opt to choose the device's torch.
 
 @param torch BOOL value stating to wheter to activate or not the torch 
 */
- (void)useTorch:(BOOL)torch;

/**
 Whether the device is connected to internet or not
 */
- (BOOL)hasInternetConnection;

/**
 Call this method to end the capture session. Make sure to ALWAYS call this method before releasing the Record object
 */
- (void)endSession;

@end
