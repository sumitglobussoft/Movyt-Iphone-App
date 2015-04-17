//
//  SettingsViewController.m
//  Video Stream
//
//  Created by Rus Flaviu on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "Util.h"

//http://movyt.socialsignifier.com/wowza_start.php

#define kDefaultServer @"rtmp://192.168.7.198:1935/live"
#define kDefaultApplication @"myStream"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	
	//return NO;
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		return YES ;
    }
    return NO ;
}

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
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_textFieldForServer release];
    [_testFieldForFPS release];
    [_textFieldForApplication release];
    [_textFieldForKeyFrameInterval release];
    [_segmentForResolutions release];
    [_sliderForkbps release];
    [_labelForkbps release];
    [_scrollView release];
    [super dealloc];
}
- (void)viewDidUnload {
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [self setTextFieldForServer:nil];
    [self setTestFieldForFPS:nil];
    [self setTextFieldForApplication:nil];
    [self setTextFieldForKeyFrameInterval:nil];
    [self setSegmentForResolutions:nil];
    [self setSliderForkbps:nil];
    [self setLabelForkbps:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor=[UIColor blackColor];
    
    self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    self.scrollView.showsVerticalScrollIndicator=YES;
    self.scrollView.scrollEnabled=YES;
    self.scrollView.userInteractionEnabled=YES;
   
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width,self.view.frame.size.height+200);
     [self.view addSubview:self.scrollView];

    
    self.pushCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pushCancel addTarget:self
                               action:@selector(pushCancel:)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.pushCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    self.pushCancel.frame = CGRectMake(20.0,self.view.frame.size.height-100, 80.0, 50.0);
    [self.scrollView addSubview:self.pushCancel];

    self.pushSaveSetting = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pushSaveSetting addTarget:self
                        action:@selector(pushSaveSettings:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.pushSaveSetting setTitle:@"Save Settings" forState:UIControlStateNormal];
    self.pushSaveSetting.frame = CGRectMake(150.0,self.view.frame.size.height-100, 160.0, 50.0);
    [self.scrollView addSubview:self.pushSaveSetting];

    
    UILabel *server = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 300, 50)];
    server.backgroundColor = [UIColor clearColor];
    
    [server setText:@"Server :"];

    server.textColor=[UIColor whiteColor];
    [self.scrollView addSubview:server];

    UILabel *stream = [[UILabel alloc] initWithFrame:CGRectMake(20, 140, 300, 50)];
    stream.backgroundColor = [UIColor clearColor];
    
    [stream setText:@"Stream :"];
    stream.text=@"Stream :";
    stream.textColor=[UIColor whiteColor];
    [self.scrollView addSubview:stream];
    
    
    UILabel *FPS = [[UILabel alloc] initWithFrame:CGRectMake(20, 250, 100, 50)];
    FPS.backgroundColor = [UIColor clearColor];
    [FPS setText:@"FPS :"];
    FPS.text=@"FPS :";
    FPS.textColor=[UIColor whiteColor];
    [self.scrollView addSubview:FPS];
    
    UILabel *keyFrameInterval = [[UILabel alloc] initWithFrame:CGRectMake(20,190, 300, 50)];
    keyFrameInterval.backgroundColor = [UIColor clearColor];
    
    [keyFrameInterval setText:@"Key Frame Interval :"];
    keyFrameInterval.text=@"Key Frame Interval :";
    keyFrameInterval.textColor=[UIColor whiteColor];
    [self.scrollView addSubview:keyFrameInterval];

    UILabel *resolution = [[UILabel alloc] initWithFrame:CGRectMake(20, 280, 100, 50)];
    resolution.backgroundColor = [UIColor clearColor];
    
    [resolution setText:@"Resolution :"];
    resolution.text=@"Resolution :";
    resolution.textColor=[UIColor whiteColor];
    [self.scrollView addSubview:resolution];
    
    UILabel *videoBitRate = [[UILabel alloc] initWithFrame:CGRectMake(20, 380, 100, 50)];
    videoBitRate.backgroundColor = [UIColor clearColor];
        [videoBitRate setText:@"Video Bit \n Rate :"];
//    videoBitRate.text=@"Video Bit Rate :";
    videoBitRate.numberOfLines=0;
    videoBitRate.lineBreakMode=NSLineBreakByCharWrapping;
    videoBitRate.textColor=[UIColor whiteColor];
    [self.scrollView addSubview:videoBitRate];
    [videoBitRate sizeToFit];
    
    
 self.textFieldForServer   = [[UITextField alloc] initWithFrame:CGRectMake(100, 90, 200, 30)];
    self.textFieldForServer.backgroundColor=[UIColor whiteColor];
 self.textFieldForServer.placeholder = @"Enter your last name here";   //for place holder
    self.textFieldForServer.borderStyle=UITextBorderStyleRoundedRect;
self.textFieldForServer.textAlignment = NSTextAlignmentLeft;
self.textFieldForServer.font = [UIFont fontWithName:nil size:14.0]; // text font
self.textFieldForServer.adjustsFontSizeToFitWidth = YES;
self.textFieldForServer.textColor = [UIColor blackColor];
self.textFieldForServer.keyboardType = UIKeyboardTypeAlphabet;
self.textFieldForServer.returnKeyType = UIReturnKeyDone;
self.textFieldForServer.clearButtonMode = UITextFieldViewModeWhileEditing;
self.textFieldForServer.delegate = self;
    [self.scrollView addSubview:self.textFieldForServer];
    
//    =======
    self.testFieldForFPS   = [[UITextField alloc] initWithFrame:CGRectMake(190, 260, 100, 30)];
      self.testFieldForFPS.backgroundColor=[UIColor whiteColor];
    self.testFieldForFPS.borderStyle=UITextBorderStyleRoundedRect;
    [self.scrollView addSubview:self.testFieldForFPS];
    self.testFieldForFPS.placeholder = @"Enter your last name here";   //for place holder
    self.testFieldForFPS.textAlignment = NSTextAlignmentLeft;
    self.testFieldForFPS.font = [UIFont fontWithName:nil size:14.0]; // text font
    self.testFieldForFPS.adjustsFontSizeToFitWidth = YES;
    self.testFieldForFPS.textColor = [UIColor blackColor];
    self.testFieldForFPS.keyboardType = UIKeyboardTypeAlphabet;
    self.testFieldForFPS.returnKeyType = UIReturnKeyDone;
    self.testFieldForFPS.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.testFieldForFPS.delegate = self;
//    ======
    
    
    self.textFieldForApplication   = [[UITextField alloc] initWithFrame:CGRectMake(100, 140, 200, 30)];
    
    self.textFieldForApplication.placeholder = @"Enter your last name here";  
    self.textFieldForApplication.borderStyle=UITextBorderStyleRoundedRect;
    self.textFieldForApplication.textAlignment = NSTextAlignmentLeft;
    self.textFieldForApplication.font = [UIFont fontWithName:nil size:14.0]; // text font
    self.textFieldForApplication.adjustsFontSizeToFitWidth = YES;
    self.textFieldForApplication.textColor = [UIColor blackColor];
    self.textFieldForApplication.keyboardType = UIKeyboardTypeAlphabet;
    self.textFieldForApplication.returnKeyType = UIReturnKeyDone;
    self.textFieldForApplication.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textFieldForApplication.delegate = self;
    [self.scrollView addSubview:self.textFieldForApplication];
//=======
    self.textFieldForKeyFrameInterval   = [[UITextField alloc] initWithFrame:CGRectMake(190, 200, 100, 30)];
    [self.scrollView addSubview:self.textFieldForKeyFrameInterval];
    self.textFieldForKeyFrameInterval.placeholder = @"Enter your last name here";
    self.textFieldForKeyFrameInterval.backgroundColor=[UIColor whiteColor];
     self.textFieldForKeyFrameInterval.borderStyle=UITextBorderStyleRoundedRect;
    self.textFieldForKeyFrameInterval.textAlignment = NSTextAlignmentLeft;
    self.textFieldForKeyFrameInterval.font = [UIFont fontWithName:nil size:14.0]; // text font
    self.textFieldForKeyFrameInterval.adjustsFontSizeToFitWidth = YES;
    self.textFieldForKeyFrameInterval.textColor = [UIColor blackColor];
    self.textFieldForKeyFrameInterval.keyboardType = UIKeyboardTypeAlphabet;
    self.textFieldForKeyFrameInterval.returnKeyType = UIReturnKeyDone;
    self.textFieldForKeyFrameInterval.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textFieldForKeyFrameInterval.delegate = self;
    
    self.labelForkbps = [[UILabel alloc] initWithFrame:CGRectMake(240, self.view.frame.size.height-210, 300, 50)];
    self.labelForkbps.backgroundColor = [UIColor clearColor];
    self.labelForkbps.textColor=[UIColor redColor];
    [self.scrollView addSubview:self.labelForkbps];

    CGRect frame = CGRectMake(100.0, 405.0, 200.0, 10.0);
    self.sliderForkbps = [[UISlider alloc] initWithFrame:frame];
    [self.sliderForkbps addTarget:self action:@selector(sliderChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.sliderForkbps setBackgroundColor:[UIColor clearColor]];
    self.sliderForkbps.minimumValue = 0.0;
    self.sliderForkbps.maximumValue = 50.0;
    self.sliderForkbps.continuous = YES;
    self.sliderForkbps.value = 25.0;
    [self.scrollView addSubview:self.sliderForkbps];
    
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"192x144", @"320x240", @"480x360", @"640x480", @"1280x720", @"1920x1080", nil];
    
    
    self.segmentForResolutions = [[UISegmentedControl alloc]initWithItems:itemArray];
   self.segmentForResolutions.frame = CGRectMake(10, 320, 300, 50);
//    [self.segmentForResolutions setTitle:@"192x144" forSegmentAtIndex:0];
//   [self.segmentForResolutions setTitle:@"320x240" forSegmentAtIndex:1];
//  [self.segmentForResolutions setTitle:@"480x360" forSegmentAtIndex:2];
//  [self.segmentForResolutions setTitle:@"640x480" forSegmentAtIndex:3];
//    [self.segmentForResolutions setTitle:@"1280x720" forSegmentAtIndex:4];
//    [self.segmentForResolutions setTitle:@"1920x1080" forSegmentAtIndex:5];
    [ self.segmentForResolutions addTarget:self action:@selector(resolutionChangedValue:) forControlEvents: UIControlEventValueChanged];
     self.segmentForResolutions.selectedSegmentIndex = 1;
    [self.scrollView addSubview: self.segmentForResolutions];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardDidShow)
                                                 name: UIKeyboardDidShowNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardDidHide)
                                                 name: UIKeyboardDidHideNotification
                                               object: nil];
    
    self.sliderForkbps.maximumValue = 1.0;
    self.sliderForkbps.minimumValue = 0.1;
    
    [self loadSavedValues];
    [self sliderChangedValue: nil];
}

#pragma mark -
#pragma mark UIKeyboard Notifications

- (void)keyboardDidShow
{
    self.scrollView.contentSize = CGSizeMake(480, self.scrollView.frame.size.height + 162);
}

- (void)keyboardDidHide
{
    self.scrollView.contentSize = CGSizeMake(480, self.scrollView.frame.size.height);
}

#pragma mark -
#pragma mark Settings Values

- (void)loadSavedValues
{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithUser: @"streamingUser"];
    
    self.segmentForResolutions.selectedSegmentIndex = [defaults integerForKey: @"agilio.streaming.savedResolution"];
    
    CGFloat kbpsScalar = [defaults floatForKey: @"agilio.streaming.savedkbpsScalar"];
    
    if (kbpsScalar < 0.1) {
        kbpsScalar = 0.4;
    }
    
    self.sliderForkbps.value = kbpsScalar;
    
    NSString *server = [defaults stringForKey: @"agilio.streaming.serverName"];
    NSString *application = [defaults stringForKey: @"agilio.streaming.applicationName"];
    
    NSInteger fps = [defaults integerForKey: @"agilio.streaming.fps"];
    NSInteger keyFrInt = [defaults integerForKey: @"agilio.streaming.keyFrInt"];
    
    [defaults release];
    
    self.textFieldForServer.text = server ? server : kDefaultServer;
    self.textFieldForApplication.text = application ? application : kDefaultApplication;
    self.testFieldForFPS.text = fps != 0 ? [NSString stringWithFormat: @"%ld", (long)fps] : [NSString stringWithFormat: @"%d", kDefaultFramesPerSecond];
    self.textFieldForKeyFrameInterval.text = keyFrInt != 0 ? [NSString stringWithFormat: @"%ld", (long)keyFrInt] : [NSString stringWithFormat: @"%d", kDefaultKeyFrameInterval];
}

- (BOOL)saveValues
{
    if (self.textFieldForApplication.text.length == 0 ||
        self.testFieldForFPS.text.length == 0 ||
        self.textFieldForKeyFrameInterval.text.length == 0 ||
        self.textFieldForServer.text.length == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                        message: @"Please complete all fields."
                                                       delegate: nil
                                              cancelButtonTitle: @"Ok"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        return NO;
    }
    else {
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithUser: @"streamingUser"];
        
        [defaults setInteger: self.segmentForResolutions.selectedSegmentIndex forKey: @"agilio.streaming.savedResolution"];
        [defaults setFloat: self.sliderForkbps.value forKey: @"agilio.streaming.savedkbpsScalar"];
        [defaults setInteger: self.textFieldForKeyFrameInterval.text.integerValue forKey: @"agilio.streaming.keyFrInt"];
        [defaults setInteger: self.testFieldForFPS.text.integerValue forKey: @"agilio.streaming.fps"];
        [defaults setObject:@"movyt" forKey: @"agilio.streaming.applicationName"];
        [defaults setObject: @"192.168.7.198:1935" forKey: @"agilio.streaming.serverName"];
        [defaults synchronize];
        
        [defaults release];
        
        return YES;
    }
}

#pragma mark -
#pragma mark Actions

- (IBAction)sliderChangedValue:(id)sender {
    
    CGFloat sliderValue;
    
    switch (self.segmentForResolutions.selectedSegmentIndex) {
        case 0:
            sliderValue = self.sliderForkbps.value * MaximumBitrate_192x144 / 1000;
            break;
        case 1:
            sliderValue = self.sliderForkbps.value * MaximumBitrate_320x240 / 1000;
            break;
        case 2:
            sliderValue = self.sliderForkbps.value * MaximumBitrate_480x360 / 1000;
            break;
        case 3:
            sliderValue = self.sliderForkbps.value * MaximumBitrate_640x480 / 1000;
            break;
        case 4:
            sliderValue = self.sliderForkbps.value * MaximumBitrate_1280x720 / 1000;
            break;
        case 5:
            sliderValue = self.sliderForkbps.value * MaximumBitrate_1920x1080 / 1000;
            break;
        default:
            sliderValue = 1000;
            break;
    }
    
    self.labelForkbps.text = [NSString stringWithFormat: @"%d kbps", (int)sliderValue];
}

- (IBAction)resolutionChangedValue:(id)sender {
    [self sliderChangedValue: nil];
}

- (IBAction)pushSaveSettings:(id)sender {
    
    if ([self saveValues]) {
       [self.navigationController popViewControllerAnimated:YES];
       [self.delegate settingsDidSave];
    }
    
}

- (IBAction)pushCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
   [self.delegate settingsDidSave];
}

- (IBAction)backgroundTap:(id)sender {
    [self.testFieldForFPS resignFirstResponder];
    [self.textFieldForApplication resignFirstResponder];
    [self.textFieldForKeyFrameInterval resignFirstResponder];
    [self.textFieldForServer resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
