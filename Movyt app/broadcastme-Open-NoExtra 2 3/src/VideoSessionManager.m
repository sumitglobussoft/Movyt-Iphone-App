//
//  VideoSessionManager.m
//  Video Stream
//
//  Created by Mihai on 08/04/14.
//
//

#import "VideoSessionManager.h"

@implementation VideoSessionManager

+ (BOOL)setPreset:(VideoResolution)resolution forSession:(AVCaptureSession *)session
{
    BOOL success = YES;
    
    switch (resolution) {
        case VideoResolution_192x144:
            [session setSessionPreset: AVCaptureSessionPresetLow];
            break;
        case VideoResolution_320x240:
            [session setSessionPreset: AVCaptureSessionPreset352x288];
            break;
        case VideoResolution_480x360:
            [session setSessionPreset: AVCaptureSessionPresetMedium];
            break;
        case VideoResolution_640x480:
            [session setSessionPreset: AVCaptureSessionPreset640x480];
            break;
        case VideoResolution_1280x720:
            [session setSessionPreset: AVCaptureSessionPreset1280x720];
            //saveVideoToCameraRoll = NO;
            break;
        default:
            [session setSessionPreset: AVCaptureSessionPresetLow];
            success = NO;
            break;
    }
    
    return success;
}

+ (NSString*)videoProfileForWidth:(NSInteger *)width height:(NSInteger *)height forResolution:(VideoResolution *)resolution
{
    BOOL success = YES;
    
    NSString *profile = AVVideoProfileLevelH264Baseline30;
    
    switch (*resolution) {
        case VideoResolution_192x144:
        {
            *width = 192;
            *height = 144;
            break;
        }
        case VideoResolution_320x240:
        {
            *width = 320;
            *height = 240;
            break;
        }
        case VideoResolution_480x360:
        {
            *width = 480;
            *height = 360;
            break;
        }
        case VideoResolution_640x480:
        {
            *width = 640;
            *height = 480;
            break;
        }
        case VideoResolution_1280x720:
        {
            *width = 1280;
            *height = 720;
            profile = AVVideoProfileLevelH264Baseline31;
            break;
        }
        default:
            success = NO;
            profile = nil;
            break;
    }
    
    return profile;
}

@end
