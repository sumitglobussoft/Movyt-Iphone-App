//
//  MovDemuxer.m
//  Streaming
//
//  Created by Radu Dan on 10/26/11.
//  Copyright (c) 2011 Medina Software. All rights reserved.
//

#import "Demuxer.h"

@implementation Demuxer

/// Create a new Demuxer given the path to a file.
/// @param filename The path of the file to "demux".
- (id)initWithFilename:(NSString *)filename hasAudio:(BOOL)hasAudio hasVideo:(BOOL)hasVideo {
    
    if (self = [super init]) {
        int retcode;
        char cname[1024];

        if (![filename hasPrefix:@"/"]) {
            [[@"file://" stringByAppendingString: filename] getCString:cname
                                                             maxLength:1024
                                                              encoding:NSUTF8StringEncoding];
        } else {
            [filename getCString:cname
                       maxLength:1024
                        encoding:NSUTF8StringEncoding];
        }

        if ((retcode = avformat_open_input(&file, cname, NULL, NULL))) {
            elog2(@"Could not open file: %s.", retcode);
            @throw [NSException exceptionWithName:@"DemuxerError"
                                           reason:[NSString stringWithFormat:@"Couldn't open file '%s'.", cname]
                                         userInfo:nil];
        }

        if ((retcode = avformat_find_stream_info(file, NULL)) < 0)
            elog2(@"Could not read stream info. %s.", retcode);

        audioStream = videoStream = -1;

        for (int i = 0; i < file->nb_streams; i++) {
            switch (file->streams[i]->codec->codec_type) {
                case AVMEDIA_TYPE_AUDIO:
                    audioStream = i;
                    audioCodec = file->streams[i]->codec;
                    break;
                case AVMEDIA_TYPE_VIDEO:
                    videoStream = i;
                    videoCodec = file->streams[i]->codec;
                    break;
                default:
                    break;
            }
        }

        if (videoStream == -1 && hasVideo)
            @throw [NSException exceptionWithName: @"DemuxerError"
                                           reason: @"No video stream found."
                                         userInfo: nil];

        if (audioStream == -1 && hasAudio)
            @throw [NSException exceptionWithName: @"DemuxerError"
                                           reason: @"No audio stream found."
                                         userInfo: nil];
    }

    return self;
}

- (void)dealloc {
    if (file) {
        avformat_close_input(&file);
    }
    
    [_timeQueue release];
    
    [super dealloc];
}

/// Reads a packet from the movie.
/// @param isVideo Used to return whether or not the packet being read is a video packet.
- (AVPacket *)readPacket:(bool *)isVideo {
    
    if (av_read_frame(file, &packet) >= 0) {
        
        if (packet.stream_index == videoStream) {
            *isVideo = YES;
            packet.pts = [[self.timeQueue objectAtIndex: 0] unsignedLongLongValue];
            packet.dts = packet.pts;
            [self.timeQueue removeObjectAtIndex: 0];
        } else if (packet.stream_index == audioStream) {
            *isVideo = NO;
        } else {
            return NULL;
        }

        return &packet;
    }

    return NULL;
}

/// @return The movie's duration in seconds.
- (CGFloat)movieDuration {
    return MIN((float) file->streams[videoStream]->duration / file->streams[videoStream]->time_base.den,
               (float) file->streams[audioStream]->duration / file->streams[audioStream]->time_base.den);
}

/// @return The timestamp of the inital audio packet in the audio stream's time base.
- (int64_t)actualAudioOffset {
    return file->streams[audioStream]->start_time;
}

/// @return The timestamp of the inital audio packet in the audio stream's time base.
- (int64_t)actualVideoOffset {
    return file->streams[videoStream]->start_time;
}

/// @return The timestamp of the inital audio packet as an absolute value (in the audio stream's time base).
- (int64_t)audioOffset {
    return ABS(file->streams[audioStream]->start_time);
}

/// @return The timestamp of the inital video packet as an absolute value (in the video stream's time base).
- (int64_t)videoOffset {
    return ABS(file->streams[videoStream]->start_time);
}

/// @return The audio stream's duration in the audio stream's own time base.
- (int64_t)audioDuration {
    return file->streams[audioStream]->duration;
}

/// @return The video stream's duration in the video stream's own time base.
- (int64_t)videoDuration {
    return file->streams[videoStream]->duration;
}

/// @return The audio stream's time base denominator.
- (NSUInteger)audioTimeBaseDenominator {
    return file->streams[audioStream]->time_base.den;
}

/// @return The video stream's time base denominator.
- (NSUInteger)videoTimeBaseDenominator {
    return file->streams[videoStream]->time_base.den;
}

/// @return The audio stream's duration in seconds.
- (CGFloat)audioDurationSeconds {
    return (float) file->streams[audioStream]->duration * file->streams[audioStream]->time_base.num / file->streams[audioStream]->time_base.den;
}

/// @return The video stream's duration in seconds.
- (CGFloat)videoDurationSeconds {
    return (float) file->streams[videoStream]->duration * file->streams[videoStream]->time_base.num / file->streams[videoStream]->time_base.den;
}

/// @return The audio stream's codec.
- (AVCodecContext *)audioCodec {
    return audioCodec;
}

/// @return The video stream's codec.
- (AVCodecContext *)videoCodec {
    return videoCodec;
}

@end
