//
//  HomeVC.h
//  UberValetService
//
//  Created by Globussoft 1 on 10/27/14.
//  Copyright (c) 2014 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface HomeVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
        UIImageView *imageVUser;
        UILabel *lblUserName;
        UITableView *liveTable;
}
@property(nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, copy) UIViewController *selectedViewController;
@property (nonatomic, strong) UISegmentedControl *segmentControl;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) UIView *contentContainerView;
@property (nonatomic, strong) UIView *mainsubView;
@property (nonatomic, strong) UIButton *recorderButton;
@property (readonly, nonatomic) BOOL isiPhone5;

@property (nonatomic, strong) UILabel *menuLabel;
@property (nonatomic, strong) UITableView *menuTableView;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGesture;

@end
