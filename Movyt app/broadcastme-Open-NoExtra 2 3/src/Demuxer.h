//
//  MovDemuxer.h
//  Streaming
//
//  Created by Radu Dan on 10/26/11.
//  Copyright (c) 2011 Medina Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Util.h"

#import "libavformat/avformat.h"

/// Reads audio and video packets from a local mp4 file.
@interface Demuxer : NSObject {
    AVFormatContext *file;

    // The audio and video stream's codecs, respectively.
    AVCodecContext *audioCodec,
                   *videoCodec;

    AVPacket packet;

    char *error;

    int videoStream, audioStream;
}

@property (nonatomic, retain) NSMutableArray *timeQueue;

- (id)initWithFilename:(NSString *)filename hasAudio:(BOOL)hasAudio hasVideo:(BOOL)hasVideo;
- (AVPacket *)readPacket:(bool *)isVideo;
- (AVCodecContext *)videoCodec;
- (AVCodecContext *)audioCodec;
- (int64_t)actualAudioOffset;
- (int64_t)actualVideoOffset;
- (int64_t)audioOffset;
- (int64_t)videoOffset;
- (int64_t)audioDuration;
- (int64_t)videoDuration;
- (NSUInteger)audioTimeBaseDenominator;
- (NSUInteger)videoTimeBaseDenominator;
- (CGFloat)audioDurationSeconds;
- (CGFloat)videoDurationSeconds;
- (void)dealloc;

@end
