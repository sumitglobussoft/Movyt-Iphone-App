//
//  Encoder.h
//  Streaming
//
//  Created by Radu Dan on 10/23/11.
//  Copyright (c) 2011 Medina Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "Util.h"

@interface CMSampleWrapper : NSObject
{
@public
    CMSampleBufferRef sampleBuffer;
    BOOL isAudio;
}

@end

/// Wrapper over Apple's own h264/aac encoder.
@interface Encoder : NSObject {
    // The URL to where the encoded file should be saved.
    NSURL *url;

    // The path to where the encoded file should be saved.
    NSString *path;

    // The audio and video encoders.
    AVAssetWriterInput *audio,
                       *video;

    // The native muxer.
    AVAssetWriter *writer;

    NSConditionLock *state;

    // `defaultManager` is _not_ thread safe so we need a local copy.
    NSFileManager *manager;

    // Holds the last error that was passed in from one of the native methods.
    NSError *error;

    // Whether or not encoding has started.
    bool start;

    NSInteger osVersion;
}

- (id)initWithFilename:(NSString *)filename
            andQuality:(VideoResolution)theResolution
              andAudio:(double)audioRateValue
       andVideoBitRate:(NSInteger)videoBitrate
            isPortrait:(BOOL)isPortrait
      keyFrameInterval:(NSInteger)keyframeInterval
       didChangePreset:(BOOL)changePreset
          videoProfile:(NSString *)videoProfile;

- (void)startEncoding;
- (void)finishEncoding;
- (void)appendSample:(CMSampleBufferRef)sampleBuffer isAudio:(bool)isAudio;
- (void)dealloc;
- (NSString *)filename;

- (void)transformVideoInput:(CGAffineTransform)transform;

- (BOOL)didChangePreset;
- (VideoResolution)resolution;
- (BOOL)notReadyForDealloc;

- (NSMutableArray *)getTimeQueue;

@end
