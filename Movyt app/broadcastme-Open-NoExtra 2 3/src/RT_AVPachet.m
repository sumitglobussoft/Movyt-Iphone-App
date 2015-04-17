//
//  RT_AVPachet.m
//  Video Stream
//
//  Created by Mihai on 04/06/14.
//
//

#import "RT_AVPachet.h"

@implementation RT_AVPachet

- (id)initWithPacket:(AVPacket*)thePacket isVideo:(BOOL)video
{
    self = [super init];
    
    if (self) {
        
        self->isVideo = video;
        self->packet = malloc(sizeof(AVPacket));
        memcpy(self->packet, thePacket, sizeof(AVPacket));
    }
    
    return self;
}

- (void)dealloc
{
    free(self->packet);
    
    [super dealloc];
}

@end
