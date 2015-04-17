//
//  StreamingCallbackListener.h
//  Video Stream
//
//  Created by Mihai on 03/04/14.
//
//

#import <Foundation/Foundation.h>

@interface StreamingCallbackListener : NSObject
{


}
@end

@protocol StreamingCallbackListener <NSObject>

- (void)streamingStateChanged: (StreamingState)streamingState
                  withMessage: (NSString *)message;

@optional
- (void)adaptedToNetworkWithState: (AutoAdaptState)adaptState
                              fps: (NSInteger)fps
                          bitrate: (int)bitrate
                       resolution: (VideoResolution)resolution;

@end
