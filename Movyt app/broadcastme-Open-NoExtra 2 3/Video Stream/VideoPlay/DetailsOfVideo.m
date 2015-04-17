//
//  DetailsOfVideo.m
//  MoveytProject
//
//  Created by Globussoft 1 on 5/6/14.
//  Copyright (c) 2014 Globussoft 1. All rights reserved.
//

#import "DetailsOfVideo.h"
//#import "CustomMenuViewController.h"

@interface DetailsOfVideo ()

@end

@implementation DetailsOfVideo
@synthesize detailsLabel;
@synthesize pictureLabel;
@synthesize liveNowLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    [scrollView setContentSize:CGSizeMake(320, 800)];
    [self.view addSubview:scrollView];
    
    UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    headerView.backgroundColor=[UIColor colorWithRed:(CGFloat)221/255 green:(CGFloat)66/255 blue:(CGFloat)25/255 alpha:(CGFloat)1];
    [scrollView addSubview:headerView];
    
    UIButton *backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame=CGRectMake(100,435,90,20);
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.backgroundColor=[UIColor grayColor];
    [backButton addTarget:self action:@selector(backbutton:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:backButton];
    
    detailsLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 10, 300, 50)];
    detailsLabel.text=@"Details";
    detailsLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:detailsLabel];

        //  =======================
    pictureLabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 50, 300, 50)];
    pictureLabel.text=@"Picture name";
    pictureLabel.textAlignment = NSTextAlignmentCenter;
    [pictureLabel setFont:[UIFont fontWithName:@"Helvetica" size:8]];
    [scrollView addSubview:pictureLabel];
        //=======================
    liveNowLabel=[[UILabel alloc]initWithFrame:CGRectMake(30, 65, 300, 50)];
    liveNowLabel.text=@"Live now";
    liveNowLabel.textAlignment = NSTextAlignmentCenter;
    [liveNowLabel setFont:[UIFont fontWithName:@"Helvetica" size:8]];
    liveNowLabel.textColor=[UIColor redColor];
     [scrollView addSubview:liveNowLabel];
        //========================
    
    UIImageView *imageHolder = [[UIImageView alloc] initWithFrame:CGRectMake(12, 51,120, 70)];
    UIImage *image = [UIImage imageNamed:@"ghh.jpeg"];
    imageHolder.image = image;
    [scrollView addSubview:imageHolder];
    
    UIImageView *imageHolder1 = [[UIImageView alloc] initWithFrame:CGRectMake(150, 81,10, 20)];
    UIImage *image1 = [UIImage imageNamed:@"redbullet@2x.png"];
    imageHolder1.image = image1;
    [scrollView addSubview:imageHolder1];
    
    
    
        //To make the border look very close to a UITextField
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 125, 300, 300)];
    [textView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [textView.layer setBorderWidth:2.0];
    
        //The rounded corner part, where you specify your view's corner radius:
    textView.layer.cornerRadius = 5;
    textView.clipsToBounds = YES;
    textView.text = [textView.text stringByAppendingString:@"    We have a beautiful,exciting and enchanting world. Nature is a beauty of hidden paradise and has provided us with wonderful gifts. It is filled with adventurous spots , scenic landscapes, mystic caves , colorful flora and fauna, splendid waterfalls, exotic locales, snow capped peaks, lofty mountain ranges, picturesque dense lush green forests, dazzling deserts, breathtaking seascapes,serene flowing rivers, captivating sandy beaches all mesmerizes and provides one with awesome sights.                                                            From times immortal nature has been a source of inspiration to man. But man's need for comfort has made him to destruct it . Many plants and animals are becoming extinct . Hence it becomes very important for us to protect this incredible beauty of Nature for generations to come."];
    textView.editable=NO;
    [scrollView addSubview:textView];
}

    // Do any additional setup after loading the view.

-(void)backbutton:(UIButton *)button{
//   CustomMenuViewController *customVC=[[CustomMenuViewController alloc]init];
[self dismissViewControllerAnimated:YES completion:nil];
//  [self presentViewController:customVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
