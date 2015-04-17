//
//  GoLiveViewController.h
//  Video Stream
//
//  Created by Rus Flaviu on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoLiveViewController : UIViewController {
    
    
}

@property (retain, nonatomic)  UIButton *buttonForSettings;
@property (retain, nonatomic)  UIButton *buttonForSound;
@property (retain, nonatomic)  UIButton *buttonForTorch;
@property (retain, nonatomic)  UIButton *buttonForFlipCamera;
@property (retain, nonatomic)  UIButton *buttonForToggleStream;
@property (retain, nonatomic)  UIButton *closeButton;
@property (retain, nonatomic)  UILabel *labelForTime;

- (void)pushSettings:(id)sender;
- (void)pushTorch:(id)sender;
- (void)pushFlipCamera:(id)sender;
- (void)toggleStream:(id)sender;
- (void)toggleSound:(id)sender;


- (BOOL) connectedToNetwork;

@end
