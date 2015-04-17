//
//  VideoSessionManager.h
//  Video Stream
//
//  Created by Mihai on 08/04/14.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "Util.h"

@interface VideoSessionManager : NSObject

+ (BOOL)setPreset:(VideoResolution)resolution forSession:(AVCaptureSession*)session;
+ (NSString *)videoProfileForWidth:(NSInteger*)width height:(NSInteger*)height forResolution:(VideoResolution*)resolution;

@end
