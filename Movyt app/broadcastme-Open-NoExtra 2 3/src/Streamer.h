//
//  Streamer.h
//  Streaming
//
//  Created by Radu Dan on 10/27/11.
//  Copyright (c) 2011 Medina Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Demuxer.h"
#import "Util.h"
#import "StreamingCallbackListener.h"

extern NSString *NetworkStateChangedNotification;

@protocol StreamerDelegate  <NSObject>

- (void)didChangeAudioOffset:(int64_t)newOffset;

@end

/// Sends audio and video packets to a RTMP server.
@interface Streamer : NSObject {
    AVFormatContext *file;

    char error[1024],
         cname[1024];

    bool headers;

    int64_t videoPosition,
            audioPosition;
    
    int audioRate;
}

@property (nonatomic, assign) NSMutableArray *audioQueue;
@property (nonatomic, assign) NSNumber *audioOffset;
@property (nonatomic, assign) id <StreamerDelegate> audioOffsetDelegate;
@property (nonatomic, assign) BOOL abortIsRequested;

- (id)initWithUrl: (NSString *)url
     andAudioRate: (int)theAudioRate
     bufferLength: (double)theBufferLength
   adaptToNetwork: (BOOL)adaptToNetwork
 callbackListener: (id<StreamingCallbackListener>)listener;

- (bool)writePacket: (Demuxer *)source
       andSendVideo: (bool)sendVideo
               date: (NSDate*)date
            newSize: (BOOL)newSize
  audioCodecContext: (AVCodecContext *)audioCodec;

- (void)dealloc;

@end
