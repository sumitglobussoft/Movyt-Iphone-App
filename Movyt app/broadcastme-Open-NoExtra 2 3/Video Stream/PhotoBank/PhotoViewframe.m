//
//  PhotoViewframe.m
//  MoveytProject
//
//  Created by Globussoft 1 on 5/15/14.
//  Copyright (c) 2014 Globussoft 1. All rights reserved.
//

#import "PhotoViewframe.h"
#import "UIImageView+WebCache.h"

@interface PhotoViewframe ()

@end

@implementation PhotoViewframe
@synthesize imageView,urlStr;
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
//    UIButton *backButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    backButton.frame=CGRectMake(10, 40, 50, 20);
//    
//    [backButton addTarget:self action:@selector(backButtonMethod:) forControlEvents:UIControlEventTouchUpInside];
//        //    [backButton setTitle:@"back" forState:UIControlStateNormal];
//    [backButton setImage:[UIImage imageNamed:@"back.jpeg"] forState:UIControlStateNormal];
//    [self.view addSubview:backButton];

    imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 70, 300, 300)];
    
   

   // imageView.backgroundColor=[UIColor yellowColor];
    [self.view addSubview:imageView];

    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden=NO;
    NSString *urlAdded = [NSString stringWithFormat:@"http://104.155.224.116/%@",self.urlStr];
    NSURL *url = [NSURL URLWithString:urlAdded];
     [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"hel.jpeg"]];
}

-(void)backButtonMethod:(UIButton *)button{
    
   // [self removeFromParentViewController];
//    [self.view removeFromSuperview];
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
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
