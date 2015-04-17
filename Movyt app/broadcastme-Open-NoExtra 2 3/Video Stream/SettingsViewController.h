//
//  SettingsViewController.h
//  Video Stream
//
//  Created by Rus Flaviu on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsDidSave;

@end

@interface SettingsViewController : UIViewController<UITextFieldDelegate>

@property (retain, nonatomic)  UIScrollView *scrollView;
@property (retain, nonatomic)  UIControl *control;
@property (retain, nonatomic)  UITextField *textFieldForServer;
@property (retain, nonatomic)  UITextField *testFieldForFPS;
@property (retain, nonatomic)  UITextField *textFieldForApplication;
@property (retain, nonatomic)  UITextField *textFieldForKeyFrameInterval;
@property (retain, nonatomic)  UISegmentedControl *segmentForResolutions;
@property (retain, nonatomic)  UISlider *sliderForkbps;
@property (retain, nonatomic)  UILabel *labelForkbps;
@property (retain, nonatomic)  UIButton *pushCancel;
@property (retain, nonatomic)  UIButton *pushSaveSetting;

@property (assign, nonatomic) id<SettingsViewControllerDelegate> delegate;

- (IBAction)sliderChangedValue:(id)sender;
- (IBAction)resolutionChangedValue:(id)sender;
- (IBAction)pushSaveSettings:(id)sender;
- (IBAction)pushCancel:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@end
