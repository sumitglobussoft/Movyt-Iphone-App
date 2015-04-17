//
//  AppDelegate.m
//  Video Stream
//
//  Created by Rus Flaviu on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "GoLiveViewController.h"
#import "SignInViewController.h"
#import "FollowingViewController.h"
#import "RecentViewController.h"
#import "LiveViewController.h"
#import "PhototBankController.h"
#import "AllViewController.h"
#import "UpcomingViewController.h"
#import "NotificationViewController.h"
#import "EntertainmentController.h"
#import "SportViewController.h"
#import "AnimalViewController.h"
#import "MusicViewController.h"
#import "EducationViewController.h"
#import "VideoBankController.h"
#import "GamingViewController.h"
#import "TechnologyViewController.h"
#import "NewsViewController.h"
#import "HomeVC.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [application setStatusBarHidden: YES];
    
    NSString *signIn=[[NSUserDefaults standardUserDefaults]objectForKey:@"SignIn"];
    if (!signIn) {
        [[NSUserDefaults standardUserDefaults]setObject:@"no" forKey:@"SignIn"];
    }
    
#if TARGET_IPHONE_SIMULATOR
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"iOS-RTSP"
                                                    message: @"This app uses a video camera. Please run it on a device."
                                                   delegate: nil
                                          cancelButtonTitle: @"Ok"
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
#else
  /*
    _isiPhone5 = [self deviceIsiPhone5];
    
    NSString *nibName;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        if (_isiPhone5) {
            nibName =  @"GoLiveViewController_iPhone5";
        }
        else {
            nibName = @"GoLiveViewController_iPhone";
        }
    }
    else {
        nibName = @"GoLiveViewController_iPad";
    }
    
    GoLiveViewController *goLiveViewController = [[GoLiveViewController alloc] initWithNibName: nibName bundle: [NSBundle mainBundle]];
    [self.window setRootViewController: goLiveViewController];
    [goLiveViewController release];*/
     HomeVC *hom=[[HomeVC alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:hom];
    self.navController.delegate=self;
    self.navController.navigationBarHidden=YES;
   NSString *userName= [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    SignInViewController *signIned=[[SignInViewController alloc] init];
    signIned.title=@"Sign In";
    if (![signIn isEqualToString:@"no"]&&userName!=nil) {
        signIned.title=userName;
    }
    GoLiveViewController *golive=[[GoLiveViewController alloc] init];
    golive.title=@"Go Live";

    PhototBankController *photoBankVC=[[PhototBankController alloc] init];
    photoBankVC.title=@"Photo Bank";
    VideoBankController *videoBankVC=[[VideoBankController alloc] init];
    videoBankVC.title=@"Video Bank";
    FollowingViewController *follow=[[FollowingViewController alloc]init];
    follow.title=@"Following";
    AllViewController *all=[[AllViewController alloc] init];
    all.title=@"All";
    EntertainmentController *entertainment=[[EntertainmentController alloc] init];
    entertainment.title=@"Entertainment";
    SportViewController *sport=[[SportViewController alloc] init];
    sport.title=@"Sports";
    AnimalViewController *animal=[[AnimalViewController alloc] init];
    animal.title=@"Animal";
    MusicViewController *music=[[MusicViewController alloc] init];
    music.title=@"Music";
    UpcomingViewController *upcoming=[[UpcomingViewController alloc] init];
    upcoming.title=@"Upcoming";
    EducationViewController *education=[[EducationViewController alloc] init];
    education.title=@"Education";
    GamingViewController *gaming=[[GamingViewController alloc] init];
    gaming.title=@"Gaming";
    TechnologyViewController *tech=[[TechnologyViewController alloc] init];
    tech.title=@"Technology";
    NotificationViewController *notification=[[NotificationViewController alloc] init];
    notification.title=@"Notification";
    NewsViewController *news=[[NewsViewController alloc] init];
    news.title=@"News";
    hom.viewControllers=@[signIned,golive,videoBankVC,photoBankVC,follow,notification,upcoming,all,education,entertainment,sport,animal,music,gaming,tech,news];
    [self.window setRootViewController: self.navController];
    
    
#endif
    
    [self.window makeKeyAndVisible];
    return YES;
}
#pragma mark -
#pragma mark - Loading View

-(void) showHUDLoadingView:(NSString *)strTitle
{
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:HUD];
        //HUD.delegate = self;
        //HUD.labelText = [strTitle isEqualToString:@""] ? @"Loading...":strTitle;
    HUD.detailsLabelText=[strTitle isEqualToString:@""] ? @"Loading...":strTitle;
    [HUD show:YES];
}

-(void) hideHUDLoadingView
{
    [HUD removeFromSuperview];
}

+(AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)showToastMessage:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window
                                              animated:YES];
    
        // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = message;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2.0];
}


- (BOOL)deviceIsiPhone5
{
    
    
    NSLog(@"[[UIScreen mainScreen] applicationFrame].size.height = %f", [[UIScreen mainScreen] applicationFrame].size.height);
    
    if ([[UIScreen mainScreen] applicationFrame].size.height == 568) {
        return YES;
    }
    
    if ((![UIApplication sharedApplication].statusBarHidden && (int)[[UIScreen mainScreen] applicationFrame].size.height == 548) || ([UIApplication sharedApplication].statusBarHidden && (int)[[UIScreen mainScreen] applicationFrame].size.height == 568))
        return YES;
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    //NSLog(@"applicationWillResignActive");
    [[NSNotificationCenter defaultCenter] postNotificationName: @"WillEnterBackground" object: nil];
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //NSLog(@"applicationWillEnterForeground");
    [[NSNotificationCenter defaultCenter] postNotificationName: @"WillEnterForeground" object: nil];
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
