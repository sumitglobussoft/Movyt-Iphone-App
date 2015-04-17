//
//  StreamingViewManager.h
//  StreamingAudioVideo_RTSP
//
//  Created by Mihai on 10/7/13.
//  Copyright (c) 2013 Agilio. All rights reserved.
//

#import "AACEncoder.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import  <CoreMedia/CoreMedia.h>
#include <mach/mach.h>
#include <mach/mach_time.h>

#import "libavformat/avformat.h"

#import "RT_AVPachet.h"

#import <AVFoundation/AVFoundation.h>


#define kNumberRecordBuffers 3

int const AUDIO_STREAM_ = 1;
int const FLV_TIMEBASE_ = 1000;

#pragma mark user data struct
// Listing 4.3
typedef struct MyRecorder {
    AudioFileID recordFile;
    UInt64 recordPacket;
    Boolean running;
    AudioQueueRef queue;
    BOOL mute;
}MyRecorder;

static AACEncoder   *encoder = nil;
static MyRecorder   recorder = {0};
static BOOL         audioTrimmed = NO;
static uint         packetCount = 0;
static BOOL         sessionJustStarted = NO;
static int64_t          audioPosition;
int                 audioCount;
float               audioRate;
mach_timebase_info_data_t info;

int initAudioQueue(void);

#pragma mark utility functions

static void CheckError(OSStatus error, const char *operation) {
    if (error == noErr) return;
    
    char errorString[20];
    //check fourcc
    *(UInt32*)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
        isprint(errorString[3]) && isprint(errorString[4]))
    {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    }
    else {
        sprintf(errorString, "%d", (int)error);
        printf("\n");
    }
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
}


static int MyComputeRecordBufferSize(const AudioStreamBasicDescription *format,
                                     AudioQueueRef queue, float seconds) {
    
    int packets, frames, bytes;
    frames = (int)ceil(seconds * format->mSampleRate);
    //NSLog(@"Frames: %d", frames);
    if (format->mBytesPerFrame > 0) // 1
        bytes = frames * format->mBytesPerFrame;
    else
    {
        UInt32 maxPacketSize;
        if (format->mBytesPerPacket > 0) { // 2
            // Constant packet size
            maxPacketSize = format->mBytesPerPacket;
        }    
        else
        {
            // Get the largest single packet size possible
            UInt32 propertySize = sizeof(maxPacketSize); // 3
            CheckError(AudioQueueGetProperty(queue,
                                             kAudioConverterPropertyMaximumOutputPacketSize,
                                             &maxPacketSize, &propertySize),
                       "Couldn't get queue's maximum output packet size");
        }
        if (format->mFramesPerPacket > 0) {
            packets = frames / format->mFramesPerPacket; // 4
        }
        else {
            packets = frames; // 5
        }
        if (packets == 0)
            packets = 1;
        bytes = packets * maxPacketSize; // 6
        //NSLog(@"bytes: %d", bytes);
    }
    return bytes;
}

#pragma mark record callback function

static void MyAQInputCallback(void *inUserData, 
                              AudioQueueRef inQueue,
                              AudioQueueBufferRef inBuffer,
                              const AudioTimeStamp *inStartTime,
                              UInt32 inNumPackets,
                              const AudioStreamPacketDescription *inPacketDesc) {
    
    MyRecorder *recorder = (MyRecorder *)inUserData;
    
    if (1 && inNumPackets > 0) {
        
        uint64_t time_stamp = inStartTime->mHostTime;
        /* Convert to nanoseconds */
        time_stamp *= info.numer;
        time_stamp /= info.denom;
        
        audioCount++;
        
        for(int i=0; i<inNumPackets; i++) {

            int64_t presentationTimeStamp = time_stamp / 1000000;//inStartTime->mSampleTime  / (i+1) * FLV_TIMEBASE / audioRate + encoder.audioOffset;

            AVPacket *videoPacket = malloc(sizeof(AVPacket));
            av_new_packet(videoPacket, inBuffer->mAudioDataByteSize/inNumPackets);
            
            if (! recorder->mute) {
                memcpy(videoPacket->data, &inBuffer->mAudioData[i],  inBuffer->mAudioDataByteSize/inNumPackets);
            }
            
            videoPacket->pts = presentationTimeStamp;
            videoPacket->dts = presentationTimeStamp;
            videoPacket->duration = (inStartTime->mSampleTime / audioCount) / (i+1) * FLV_TIMEBASE_ / audioRate;
            videoPacket->stream_index = AUDIO_STREAM_;
            
            RT_AVPachet *rt_packet = [[RT_AVPachet alloc] initWithPacket: videoPacket isVideo: NO];
            
            //av_free_packet(videoPacket);
            free(videoPacket);
            
            @synchronized(encoder.audioQueue) {
                [encoder.audioQueue addObject: rt_packet];
                [rt_packet release];
            }
        }
    }
    
    if (recorder->running)
        CheckError(AudioQueueEnqueueBuffer(inQueue, inBuffer, 0, NULL), "AudioQueueEnqueueBuffer failed");
    else
        NSLog(@"RECORDER NOT RUNNING");
}



int initAudioQueue()
{
    audioTrimmed = NO;
    packetCount = 0;
    //recorder.mute = NO;
    
    AudioStreamBasicDescription recordFormat = {0};
    memset(&recordFormat, 0, sizeof(recordFormat));
    
    recordFormat.mFormatID = kAudioFormatMPEG4AAC;
    recordFormat.mChannelsPerFrame = 1;
    recordFormat.mSampleRate = audioRate;
    //     bbrecordFormat.mBytesPerFrame = 186;
    
    UInt32 propSize = sizeof(recordFormat);
    CheckError(AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &propSize, &recordFormat), "AudioFormatGetProperty Failed");
    
    //NOTE: We are running on the default CFRunLoop. If you are having problems try pusing this to a queue.
    //e.g. Startup this class on a queue and then use CFRunLoopGetCurrent() for \/ that parameter.
    CheckError(AudioQueueNewInput(&recordFormat, MyAQInputCallback, &recorder, NULL, NULL, 0, &recorder.queue), "AudioQueueNewInput Failed");
    //CheckError(AudioQueueNewInput(&recordFormat, MyAQInputCallback, &recorder, CFRunLoopGetCurrent(), NULL, 0, &recorder.queue), "AudioQueueNewInput Failed");
    
    
    UInt32 size = sizeof(recordFormat);
    CheckError(AudioQueueGetProperty(recorder.queue, kAudioConverterCurrentOutputStreamDescription, &recordFormat, &size), "Could not get queue's format");
    
    UInt32 val = kAudioQueueHardwareCodecPolicy_UseSoftwareOnly;
    CheckError(AudioQueueSetProperty(recorder.queue, kAudioQueueProperty_HardwareCodecPolicy, &val, sizeof(UInt32)), "Error setting audio software codec");
    
    int bufferByteSize = MyComputeRecordBufferSize(&recordFormat, recorder.queue, 0.03);
    //NSLog(@"Buffer Size: %d", bufferByteSize);
    
    int bufferIndex;
    for (bufferIndex = 0; bufferIndex < kNumberRecordBuffers; ++bufferIndex)
    {
        AudioQueueBufferRef buffer;
        CheckError(AudioQueueAllocateBuffer(recorder.queue, bufferByteSize, &buffer),
                   "AudioQueueAllocateBuffer failed");
        CheckError(AudioQueueEnqueueBuffer(recorder.queue, buffer, 0, NULL),
                   "AudioQueueEnqueueBuffer failed");
    }
    
//    UInt32 sz;
    //CreateEncoderCookie(recorder.queue, &sz);
    
    return 0;
}


@implementation AACEncoder

- (id)initWithAudioRate:(float)theAudioRate
{
    self = [self init];
    
    audioRate = theAudioRate;
    
    return self;
}

- (id)init {
    
    self = [super init];
    
    if (self) {
        mach_timebase_info(&info);
        _audioQueue = [[NSMutableArray alloc] init];
        [self initAudioSession];
    }
    return self;
}

- (void) mute:(BOOL) val {
    recorder.mute = val;
}

- (void)initAudioSession
{
    AudioSessionInitialize(NULL, NULL, NULL, self);
    
    //	//set the audio category
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);
    
    // mix with others!! this allows using AVCaptureSession and AusioSession simultaniously
    UInt32 doSetProperty = 1;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers,  sizeof(doSetProperty), &doSetProperty);
    
    //AudioSessionSetActive(YES);
}

- (void)setAudioRate:(float)theAudioRate
{
    audioRate = theAudioRate;
}

- (void) start {
    
    //[self initAudioSession];
    
    AudioSessionSetActive(YES);
    
    @synchronized(_audioQueue) {
        
        for (RT_AVPachet *audioPacket in _audioQueue) {
            av_free_packet(audioPacket->packet);
        }
        
        [_audioQueue removeAllObjects];
    }
    
    audioCount = 0;
    
    encoder = self;
    audioPosition = 0;
    self.audioOffset = 0;
    
    //AudioSessionSetActive(YES);
    initAudioQueue();
    recorder.running = TRUE;
    sessionJustStarted = YES;
    AudioTimeStamp ts = {0};
    
    CheckError(AudioQueueStart(recorder.queue, &ts), "AudioQueueStart failed");
}

- (void) stop {
    
    NSLog(@"stop the audio queue");
    
    if (!recorder.running) {
        return;
    }
    
    recorder.running = FALSE;
    CheckError(AudioQueueStop(recorder.queue, TRUE), "AudioQueueStop failed");
    AudioQueueDispose(recorder.queue, TRUE);
}

- (void)dealloc
{
    @synchronized(_audioQueue) {
        
        for (RT_AVPachet *audioPacket in _audioQueue) {
            av_free_packet(audioPacket->packet);
        }
        
        [_audioQueue removeAllObjects];
    }
    
    [_audioQueue release];
    [super dealloc];
}

#pragma mark -
#pragma mark - Streamer delegate

- (void)didChangeAudioOffset:(int64_t)newOffset
{
    self.audioOffset -= newOffset;
}

@end
