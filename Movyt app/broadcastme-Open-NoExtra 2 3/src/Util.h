//
//  Util.h
//  Video Stream
//
//  Created by Bogdan on 4/11/13.
//

#ifndef Video_Stream_Util_h
#define Video_Stream_Util_h

typedef enum {
  DBGError,
  DBGWarning,
  DBGLog,
  DBGDebug
} DGBLevel;

typedef enum {
    VideoResolution_192x144 = 0,
    VideoResolution_320x240,
    VideoResolution_480x360,
    VideoResolution_640x480,
    VideoResolution_1280x720,
    VideoResolution_1920x1080
}VideoResolution;

typedef enum {
    Orientation_Portrait           = 1,
    Orientation_PortraitUpsideDown = 2,
    Orientation_LandscapeRight     = 3,
    Orientation_LandscapeLeft      = 4,
    Orientation_All                = 5
} Video_Orientation;

typedef enum {
    MaximumBitrate_192x144   =   128 * 1000,
    MaximumBitrate_320x240   =   700 * 1000,
    MaximumBitrate_480x360   =  3500 * 1000,
    MaximumBitrate_640x480   =  3500 * 1000,
    MaximumBitrate_1280x720  =  5000 * 1000,
    MaximumBitrate_1920x1080 = 10000 * 1000
}MaximumBitrates;

typedef enum {
    MinimumBitrate_192x144   =   50 * 1000,
    MinimumBitrate_320x240   =  128 * 1000,
    MinimumBitrate_480x360   =  200 * 1000,
    MinimumBitrate_640x480   =  350 * 1000,
    MinimumBitrate_1280x720  = 1500 * 1000,
    MinimumBitrate_1920x1080 = 3000 * 1000
}MinimumBitrates;

typedef enum {
    StreamingState_Error = 0,
    StreamingState_Warning,
    StreamingState_Ready,
    StreamingState_Starting,
    StreamingState_Started,
    StreamingState_Stopping,
    StreamingState_Stopped,
    StreamingState_NoInternet,
    StreamingState_NoServerConnection
}StreamingState;

typedef enum {
    AutoAdaptState_DecreasingBitrate,
    AutoAdaptState_IncreasingBitrate,
    AutoAdaptState_DroppingVideoFrames,
    AutoAdaptState_IncreasingVideoFrames,
    AutoAdaptState_DecreasingResolution,
    AutoAdaptState_IncreasingResolution
}AutoAdaptState;

#define kDefaultFramesPerSecond 24
#define kDefaultKeyFrameInterval 30
#define kDefaultBufferLength 0.4
#define kDefaultAudioRate 44100.0

#define DBG DBGDebug

#define nlog(level, message, ...) \
  if (DBG >= level) NSLog(message, __VA_ARGS__);

#define nlog2(level, message) \
  if (DBG >= level) NSLog(message);

#define elog(message, code, ...) {               \
  char errstr[255];                              \
  av_strerror(code, errstr, 255);                \
  nlog(DBGError, message, __VA_ARGS__, errstr); \
}

#define elog2(message, code) {      \
  char errstr[255];                 \
  av_strerror(code, errstr, 255);   \
  nlog(DBGError, message, errstr); \
}

#endif
