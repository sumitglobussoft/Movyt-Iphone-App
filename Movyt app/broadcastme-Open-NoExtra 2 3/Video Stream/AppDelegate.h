//
//  AppDelegate.h
//  Video Stream
//
//  Created by Rus Flaviu on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate>{
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) UIWindow *window;
@property (readonly, nonatomic) BOOL isiPhone5;
@property(strong,nonatomic)UINavigationController *navController;

+(AppDelegate *)sharedAppDelegate;
-(void) showHUDLoadingView:(NSString *)strTitle;
-(void) hideHUDLoadingView;
-(void)showToastMessage:(NSString *)message;

@end
