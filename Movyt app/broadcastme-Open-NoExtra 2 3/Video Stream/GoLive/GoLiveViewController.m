//
//  GoLiveViewController.m
//  Video Stream
//
//  Created by Rus Flaviu on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GoLiveViewController.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "SettingsViewController.h"
#include <netinet/in.h>
#import "Recorder.h"

@interface GoLiveViewController ()<SettingsViewControllerDelegate,StreamingCallbackListener>
{
    int secondsPassed;
    Recorder *_stream;
}

@property (nonatomic, retain) NSTimer *timer;

@end

@implementation GoLiveViewController
@synthesize closeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
    self.navigationController.navigationBar.hidden=NO;
////    self.navigationController.navigationBar.translucent=YES;
  self.buttonForSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonForSettings addTarget:self
               action:@selector(pushSettings:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.buttonForSettings setImage:[UIImage imageNamed:@"but_settings.png"] forState:UIControlStateNormal];
    self.buttonForSettings.frame = CGRectMake(20.0,self.view.frame.size.height-100, 80.0, 50.0);
    [self.view addSubview:self.buttonForSettings];
    
    self.buttonForSound   = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonForSound addTarget:self
                               action:@selector(toggleSound:)
                     forControlEvents:UIControlEventTouchUpInside];
   [self.buttonForSound setImage:[UIImage imageNamed:@"but_unmute.png"] forState:UIControlStateNormal];
    self.buttonForSound.frame = CGRectMake(80.0,self.view.frame.size.height-100, 80.0, 50.0);
    [self.view addSubview:self.buttonForSound];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.backgroundColor = [UIColor redColor];
    self.closeButton.frame = CGRectMake(10,20, 30, 30);
    [self.view addSubview:self.closeButton];
    
    
    self.buttonForTorch   = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonForTorch addTarget:self
                               action:@selector(pushTorch:)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.buttonForTorch setImage:[UIImage imageNamed:@"but_tourchoff.png"] forState:UIControlStateNormal];
    self.buttonForTorch.frame = CGRectMake(140.0,self.view.frame.size.height-100, 80.0, 50.0);
    [self.view addSubview:self.buttonForTorch];
    
        self.buttonForFlipCamera   = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonForFlipCamera addTarget:self
                               action:@selector(pushFlipCamera:)
                     forControlEvents:UIControlEventTouchUpInside];
   [ self.buttonForFlipCamera setImage:[UIImage imageNamed:@"but_rotatecamera.png"] forState:UIControlStateNormal];
    self.buttonForFlipCamera.frame = CGRectMake(220.0,self.view.frame.size.height-100, 80.0, 50.0);
    [self.view addSubview:self.buttonForFlipCamera];
    
    self.buttonForToggleStream   = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonForToggleStream addTarget:self
                                 action:@selector(toggleStream:)
                      forControlEvents:UIControlEventTouchUpInside];
    [ self.buttonForToggleStream setImage:[UIImage imageNamed:@"but_golive.png"] forState:UIControlStateNormal];
    self.buttonForToggleStream.frame = CGRectMake(20.0,self.view.frame.size.height-150, 80.0, 50.0);
    [self.view addSubview:self.buttonForToggleStream];

    self.labelForTime = [[UILabel alloc] initWithFrame:CGRectMake(240, self.view.frame.size.height-150, 300, 50)];
    self.labelForTime.backgroundColor = [UIColor clearColor];

    [self.labelForTime setText:@"00:00"];
    self.labelForTime.text=@"00:00";
    self.labelForTime.textColor=[UIColor redColor];
    [self.view addSubview:self.labelForTime];

//    [self setupButtons];
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithUser: @"streamingUser"];
    
    NSString *server = [defaults stringForKey: @"agilio.streaming.serverName"];
    
    [defaults release];
    
    self.buttonForSettings.enabled = NO;
    
    if ( ! server) {
        [self performSelector: @selector(pushSettings:) withObject:nil afterDelay:0.1];
    }
    else {
        [self initStreamer];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)setupButtons
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.buttonForToggleStream setImage: [UIImage imageNamed: @"but_stop"] forState: UIControlStateSelected];
        [self.buttonForSound setImage: [UIImage imageNamed: @"but_mute"] forState: UIControlStateSelected];
        [self.buttonForTorch setImage: [UIImage imageNamed: @"but_tourchon"] forState: UIControlStateSelected];
    }
    else {
        [self.buttonForToggleStream setImage: [UIImage imageNamed: @"but_stop1"] forState: UIControlStateSelected];
        [self.buttonForSound setImage: [UIImage imageNamed: @"but_mute1"] forState: UIControlStateSelected];
        [self.buttonForTorch setImage: [UIImage imageNamed: @"but_tourchon"] forState: UIControlStateSelected];
    }
    
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	
	//return NO;
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		return YES ;
    }
    return NO ;
	
}

#pragma mark -
#pragma mark Actions

- (IBAction)pushSettings:(id)sender {
    
    NSLog(@"push settings");
    

    @try {
        
        if (_stream) {
            [_stream endSession];
            _stream.delegate = nil;
            [_stream release];
        }
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            SettingsViewController *settingView=[[SettingsViewController alloc] init];
            settingView.delegate=self;
            [self.navigationController pushViewController:settingView animated:YES];

        });
            }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception callStackSymbols]);
    }
    
   self.buttonForSettings.enabled = NO;
}

- (IBAction)pushTorch:(id)sender {
    
    self.buttonForTorch.selected = !self.buttonForTorch.selected;
    
    [_stream useTorch: self.buttonForTorch.selected];
}

- (IBAction)pushFlipCamera:(id)sender {
    
    [_stream useFrontCamera: !self.buttonForFlipCamera.selected completion:^(BOOL success) {
        
        NSLog(@"flipped camera: %d", success);
        
        if (success) {
            self.buttonForFlipCamera.selected = !self.buttonForFlipCamera.selected;
        }
    }];
}

- (IBAction)toggleStream:(id)sender {
    
    if (self.buttonForToggleStream.isSelected) {
        [_stream stop];
    }
    else {
        [_stream start];
    }
}

-(void)closeButtonAction:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)toggleSound:(id)sender {
    
    if (self.buttonForSound.isSelected) {
        [self.buttonForSound setSelected: NO];
        [_stream  mute: NO];
    }
    else {
        [self.buttonForSound setSelected: YES];
        [_stream  mute: YES];
    }
}

#pragma mark -
#pragma mark Counter Setup

- (void)startCounter
{
    secondsPassed = 0;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                              target: self
                                            selector: @selector(updateCounter)
                                            userInfo: nil
                                             repeats: YES];
}

- (void)updateCounter
{
    secondsPassed++;
    
    int minutes, seconds;
    
    minutes = (secondsPassed % 3600) / 60;
    seconds = (secondsPassed % 3600) % 60;
    self.labelForTime.text = [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
}

- (void)stopCounter
{
    if (self.timer) {
        [self.timer invalidate];
        _timer = nil;
    }
}

#pragma mark -
#pragma mark Settings Delegate

- (void)settingsDidSave
{
    [self performSelector: @selector(initStreamer)
               withObject: nil
               afterDelay: 0.1];
}

- (void)initStreamer
{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithUser: @"streamingUser"];
    
    CGFloat kbpsScalar = [defaults floatForKey: @"agilio.streaming.savedkbpsScalar"];
    
    NSString *server = [defaults stringForKey: @"agilio.streaming.serverName"];
    NSString *application = [defaults stringForKey: @"agilio.streaming.applicationName"];
    
    NSInteger fps = [defaults integerForKey: @"agilio.streaming.fps"];
    NSInteger keyFrInt = [defaults integerForKey: @"agilio.streaming.keyFrInt"];
    NSInteger resolution = [defaults integerForKey: @"agilio.streaming.savedResolution"];
    
    [defaults release];
    
    unsigned int bps;
    
    switch (resolution) {
        case VideoResolution_192x144:
            bps = kbpsScalar * MaximumBitrate_192x144;
            break;
        case VideoResolution_320x240:
            bps = kbpsScalar * MaximumBitrate_320x240;
            break;
        case VideoResolution_480x360:
            bps = kbpsScalar * MaximumBitrate_480x360;
            break;
        case VideoResolution_640x480:
            bps = kbpsScalar * MaximumBitrate_640x480;
            break;
        case VideoResolution_1280x720:
            bps = kbpsScalar * MaximumBitrate_1280x720;
            break;
        case VideoResolution_1920x1080:
            bps = kbpsScalar * MaximumBitrate_1920x1080;
            break;
        default:
            bps = 1000 * 1000;
            break;
    }
//    rtmp://192.168.7.198:1935/movyt
//#define kDefaultServer @"rtmp://192.168.7.198:1935/movyt"
//#define kDefaultApplication @"myStream"

    _stream = [[Recorder alloc] initWithServer: @"rtmp://104.155.210.134:8086/live/khomeshsahu"
                                      username: @"wowza"
                                      password: @"qwerty1234"
                                       preview: self.view
                                          mute: NO
                              callbackListener: self
                              usingFrontCamera: NO
                                    usingTorch: NO
                              videoWithQuality: resolution
                                     audioRate: 44100
                               andVideoBitRate: bps
                              keyFrameInterval: keyFrInt
                               framesPerSecond: fps
                                  andShowVideo: YES
                         saveVideoToCameraRoll: NO
                            autoAdaptToNetwork: NO
                   allowVideoResolutionChanges: YES
                                  bufferLength: kDefaultBufferLength
                             validOrientations: Orientation_All
                            previewOrientation: Orientation_LandscapeRight];
}

#pragma mark - Multitasking Notifications

- (void) willEnterBackground
{
    /*
    UIApplication *app = [UIApplication sharedApplication];
 
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Do the work associated with the task, preferably in chunks.
    if (self.streaming) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // The device is an iPad running iPhone 3.2 or later.
            [self.playStopButton setImage: [UIImage imageNamed: @"but_golive1.png"] forState: UIControlStateNormal];
        }
        else {
            // The device is an iPhone or iPod touch.
            [self.playStopButton setImage: [UIImage imageNamed: @"but_golive.png"] forState: UIControlStateNormal];
        }
        
        [self stopStreaming];
    }
     */
    
}

- (void) willEnterForeground
{
    /*
    if (( ! self.streaming) && ( ! [self.stream active])) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // The device is an iPad running iPhone 3.2 or later.
            [self.playStopButton setImage: [UIImage imageNamed: @"but_golive1.png"] forState: UIControlStateNormal];
        }
        else {
            // The device is an iPhone or iPod touch.
            [self.playStopButton setImage: [UIImage imageNamed: @"but_golive.png"] forState: UIControlStateNormal];
        }
        
        [self.cameraSelectionButton setAlpha: 1.0];
    }
    else {
        
        [self stopStreaming];
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    
    if (bgTask != UIBackgroundTaskInvalid) {
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
     */
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    switch (toInterfaceOrientation) {
//        case UIInterfaceOrientationLandscapeRight:
//            [_stream setPreviewOrientation: Orientation_LandscapeRight];
//            [_stream changePreviewFrame: CGRectMake(0, 0, 568, 320)];
//            break;
//        case UIInterfaceOrientationLandscapeLeft:
//            [_stream setPreviewOrientation: Orientation_LandscapeLeft];
//            [_stream changePreviewFrame: CGRectMake(0, 0, 568, 320)];
//            break;
//        case UIInterfaceOrientationPortrait:
//            [_stream setPreviewOrientation: Orientation_Portrait];
//            [_stream changePreviewFrame: CGRectMake(0, 0, 320, 568)];
//            break;
//        default:
//            break;
//    }
//}

#pragma mark -
#pragma mark Recorder Delegate

-(void)callStartWebservice{
    
    NSLog(@"web service start called");
    
    BOOL downloaded = [[NSUserDefaults standardUserDefaults] boolForKey:@"downloaded"];
    
    if (!downloaded) {
        NSError * error=nil;
        NSURLResponse * urlReponse=nil;
        
        NSString * urlStr=[NSString stringWithFormat:@"http://wowza:qwerty1234@104.155.210.134:8086/livestreamrecord?app=live&streamname=khomeshsahu&action=startRecording"];
        NSString * urlStr2=[urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url=[NSURL URLWithString:urlStr2];
        NSMutableURLRequest * request=[[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:50];
        
        
        NSData * data=[ NSURLConnection sendSynchronousRequest:request returningResponse:&urlReponse error:&error];
        if (data==nil) {
            NSLog(@" no data");
            return;
        }
        id response=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSString* myString;
       
        myString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        
         NSLog(@"reponse is %@",response);
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey: @"downloaded"];
    }
}

-(void)callStopWebservice{
     NSLog(@"web service stop called");
    
    BOOL downloaded = [[NSUserDefaults standardUserDefaults] boolForKey:@"downloaded"];
    
    if (!downloaded) {
        NSError * error=nil;
        NSURLResponse * urlReponse=nil;
        
        NSString * urlStr=[NSString stringWithFormat:@"http://wowza:qwerty1234@104.155.210.134:8086/livestreamrecord?app=live&streamname=khomeshsahu&action=stopRecording"];
        NSString * urlStr2=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url=[NSURL URLWithString:urlStr2];
        NSMutableURLRequest * request=[[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:50];
        
        
        NSData * data=[ NSURLConnection sendSynchronousRequest:request returningResponse:&urlReponse error:&error];
        if (data==nil) {
            NSLog(@" no data");
            return;
        }
        id response=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSLog(@"reponse is %@",response);
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey: @"downloaded"];
    }
    
}

- (void)streamingStateChanged:(StreamingState)streamingState withMessage:(NSString *)message
{
    NSLog(@"state changed: %@", message);
    
    switch (streamingState) {
        case StreamingState_Started:
            self.buttonForToggleStream.selected = YES;
            self.buttonForSettings.enabled = NO;
            [self startCounter];
            [self callStartWebservice];
            [self calLiveStreamingWebService];
        break;
        case StreamingState_NoInternet:
            break;
        case StreamingState_Error:
            
            if (self.buttonForToggleStream.selected) {
                self.buttonForToggleStream.selected = NO;
                self.buttonForSettings.enabled = YES;
                [self stopCounter];
            }
            break;
            
        case StreamingState_Stopped:
            self.buttonForToggleStream.selected = NO;
            self.buttonForSettings.enabled = YES;
            //[self pushSettings: nil];
            [self stopCounter];
            [self callStopWebservice];
            break;
        case StreamingState_Ready:
            self.buttonForSettings.enabled = YES;
            break;
        default:
            break;
    }
}

//web service called to add video in database.

-(void)calLiveStreamingWebService{
    
    NSLog(@"calLiveStreamingWebService called");
  
    NSString *userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    NSError * error=nil;
        NSURLResponse * urlReponse=nil;
    
    //http://104.155.210.134/index.php?method=livestreaming&category=music&video_name=khomeshsahu&user_id=%@

    
        NSString * urlStr=[NSString stringWithFormat:@"http://104.155.210.134/index.php?method=livestreaming&category=music&video_name=khomeshsahu&user_id=%@",userid];
    
        NSString * urlStr2=[urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
        NSURL *url=[NSURL URLWithString:urlStr2];
        NSMutableURLRequest * request=[[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:50];
    
        NSData * data=[ NSURLConnection sendSynchronousRequest:request returningResponse:&urlReponse error:&error];
        if (data==nil) {
            NSLog(@" no data");
            return;
        }
        id response=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSString* myString;
        
        myString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
        NSLog(@"reponse is %@",response);
}


- (BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) {
        printf("Error. Could not recover network reachability flags\n");
        return 0;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}


@end
