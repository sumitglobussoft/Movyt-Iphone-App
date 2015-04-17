//
//  RT_AVPachet.h
//  Video Stream
//
//  Created by Mihai on 04/06/14.
//
//

#import <Foundation/Foundation.h>
#import "libavcodec/avcodec.h"

@interface RT_AVPachet : NSObject
{
@public
    AVPacket *packet;
    BOOL isVideo;
    
}

- (id)initWithPacket:(AVPacket*)thePacket isVideo:(BOOL)video;

@end
