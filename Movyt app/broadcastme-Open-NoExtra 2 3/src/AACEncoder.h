//
//  StreamingViewManager.h
//  StreamingAudioVideo_RTSP
//
//  Created by Mihai on 10/7/13.
//  Copyright (c) 2013 Agilio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Streamer.h"

@class AACEncoder;

@interface AACEncoder : NSObject <StreamerDelegate>{
}
@property (nonatomic, retain) NSMutableArray *audioQueue;
@property (nonatomic, assign) int64_t audioOffset;

- (id)initWithAudioRate:(float)theAudioRate;

- (void)setAudioRate:(float)theAudioRate;

- (void) start;
- (void) stop;
- (void) mute:(BOOL) val;

@end
