//
//  HomeVC.m
//  UberValetService
//
//  Created by Globussoft 1 on 10/27/14.
//  Copyright (c) 2014 Globussoft 1. All rights reserved.
//

#import "HomeVC.h"
#import "RoundedImageView.h"
#import "GoLiveViewController.h"
#import "AppDelegate.h"



@interface HomeVC ()
{
    UIView *profileView;
    UITextField  *emailLbl;
    UITextField  * nameField;
    UITextField  * contactField;
    UITextField  * pswdField;
    NSString *editOrsave;
}

@end

@implementation HomeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden=YES;
//    72,128,230
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(CGFloat)224/255 green:(CGFloat)64/255 blue:(CGFloat)5/255 alpha:1]];
//     [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)128/255 blue:(CGFloat)230/255 alpha:1]];
//    [[UINavigationBar appearance] setTranslucent:NO];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=YES;
    self.view.backgroundColor = [UIColor whiteColor];

    self.mainsubView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    NSLog(@"Main sub view frame X=-=- %f \n Y == %f",[UIScreen mainScreen].bounds.origin.x,[UIScreen mainScreen].bounds.origin.y);
    self.mainsubView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mainsubView];

    CGFloat hh;
    CGRect frame_b;
     CGRect frame_a;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        hh = 75;
        frame_b = CGRectMake(68, 30, 45, 25);
        frame_a = CGRectMake(145, 30, 45, 25);

    }
    else{
        hh = 55;
        frame_b = CGRectMake(25, 20, 45, 25);
        frame_a = CGRectMake(130, 20, 150, 25);

    }
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, hh);
    
    self.headerView = [[UIView alloc] initWithFrame:frame];
     // 72,128,230
    self.headerView.backgroundColor = [UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)128/255 blue:(CGFloat)230/255 alpha:1];
    self.headerView.layer.borderColor = [UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)110/255 blue:(CGFloat)117/255 alpha:1].CGColor;
    self.headerView.layer.borderWidth = 0.7;

    [self.mainsubView addSubview:self.headerView];

    frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-50);
    self.contentContainerView = [[UIView alloc] initWithFrame:frame];
    self.contentContainerView.backgroundColor = [UIColor grayColor];
    self.contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.mainsubView addSubview:self.contentContainerView];

    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = frame_b;
    self.menuButton.titleLabel.font = [UIFont systemFontOfSize:9.0f];
    self.menuButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
        //self.menuButton.titleLabel.layer.
    [self.menuButton addTarget:self action:@selector(menuButtonClciked:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButton setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    
    [self.headerView addSubview:self.menuButton];
   self.selectedIndex = 0;
    
    
    self.menuLabel=[[UILabel alloc] init];
    self.menuLabel.frame=frame_a;
    self.menuLabel.backgroundColor=[UIColor clearColor];
    self.menuLabel.textColor=[UIColor whiteColor];
    self.menuLabel.font=[UIFont fontWithName:nil size:20.0];
    self.menuLabel.text=@"Home";
    self.menuLabel.numberOfLines=0;
    self.menuLabel.lineBreakMode=NSLineBreakByCharWrapping;
    [self.headerView addSubview:self.menuLabel];
    [self.menuLabel sizeToFit];

    self.recorderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recorderButton.frame =CGRectMake(245, 20, 32, 32) ;
    self.recorderButton.titleLabel.font = [UIFont systemFontOfSize:9.0f];
    self.recorderButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
        //self.menuButton.titleLabel.layer.
    [self.recorderButton addTarget:self action:@selector(recorderButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.recorderButton setBackgroundImage:[UIImage imageNamed:@"golive1.png"] forState:UIControlStateNormal];
    [self.headerView addSubview:self.recorderButton];
    
    [self createMenuTableView];
    self.swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    self.swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.mainsubView addGestureRecognizer:self.swipeGesture];

    NSArray *itemArray=[NSArray arrayWithObjects:@"Live",@"Recent", nil];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    
    self.segmentControl.frame =CGRectMake(-4,self.headerView.frame.size.height-5, self.view.frame.size.width+10, 30);
    
    [self.segmentControl addTarget:self action:@selector(mySegmentControlAction:) forControlEvents: UIControlEventValueChanged];
    [self.mainsubView addSubview:self.segmentControl];
    
    [self.segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
//    [self.segmentControl setBackgroundColor:[UIColor colorWithRed:(CGFloat)247/255 green:(CGFloat)96/255 blue:(CGFloat)41/255 alpha:(CGFloat)1]];
//    [self.segmentControl setTintColor:[UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)59/255 blue:(CGFloat)11/255 alpha:(CGFloat)1]];
    [self.segmentControl setBackgroundColor:[UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)128/255 blue:(CGFloat)230/255 alpha:(CGFloat)1]];
    [self.segmentControl setTintColor:[UIColor colorWithRed:(CGFloat)48/255 green:(CGFloat)101/255 blue:(CGFloat)196/255 alpha:(CGFloat)1]];

    self.segmentControl.selectedSegmentIndex=0;
        
    self.menuLabel.frame=frame_a;
    
//    liveTable=[[UITableView alloc]initWithFrame:CGRectMake(0,40, self.view.frame.size.width, self.view.frame.size.height-40)];
//    liveTable.delegate=self;
//    liveTable.dataSource=self;
//    liveTable.separatorStyle=UITableViewCellSeparatorStyleNone;
//    [self.mainsubView addSubview:liveTable];

    
    UIViewController *viewControler= [_viewControllers objectAtIndex:7];
    [self getSelectedViewControllers:viewControler];
           // Do any additional setup after loading the view.
}


-(void)mySegmentControlAction:(UISegmentedControl *)segment{
   
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


-(void)recorderButton:(UIButton *)button {
    
    
    //for live recording.
   /*
   UIViewController *goLiveViewController= [_viewControllers objectAtIndex:1];
      [self.navigationController pushViewController:goLiveViewController animated:YES];
    */

    NSLog(@"camera button tapped");
    
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    if(cameraDeviceAvailable && photoLibraryAvailable)
    {
        [self shouldStartCameraController];
    }

    
    
}


-(void) handleSwipeGesture:(UISwipeGestureRecognizer *)swipeGesture{
    
    
    
    if (self.mainsubView.frame.origin.x>100 ) {
        
        [UIView animateWithDuration:.5 animations:^{
            self.mainsubView.frame = CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height);
            
        }completion:^(BOOL finish){
            self.swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
            
        }];
    }
    else{
        [UIView animateWithDuration:.5 animations:^{
            self.mainsubView.frame = CGRectMake(200, 0, self.view.frame.size.width, self.view.frame.size.height);
            
        }completion:^(BOOL finish){
            
            self.swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
            
        }];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) createMenuTableView{
//    self.view.backgroundColor=[UIColor colorWithRed:192.0/255.0 green:59.0/255.0 blue:60.0/255.0 alpha:1.0];
    if (!self.menuTableView) {
        NSString *signIn=[[NSUserDefaults standardUserDefaults]objectForKey:@"SignIn"];
        if ([signIn isEqualToString:@"no"]) {
            
            self.menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, self.view.frame.size.height-10) style:UITableViewStylePlain];
        }else{
            self.menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 130, 200, self.view.frame.size.height-130) style:UITableViewStylePlain];
            
            if (!imageVUser) {
                imageVUser = [[RoundedImageView alloc] init];
                imageVUser.frame=CGRectMake(20, 20, 80, 80);
                [imageVUser setImage:[UIImage imageNamed:@"profile.png"]];
                [imageVUser setUserInteractionEnabled:YES];
                [self.view insertSubview:imageVUser belowSubview:self.mainsubView];
                UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageGesture:)];
                [imageVUser addGestureRecognizer:tapGesture];
            }
            if (!lblUserName) {
                
                lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(50, 110, 150, 30) ];
                
                lblUserName.font=[UIFont boldSystemFontOfSize:12];
                lblUserName.textColor=[UIColor blackColor];
                lblUserName.text=@"Vinayaka";
                    //        [self.headerView addSubview:lblUserName];
                [self.view insertSubview:lblUserName belowSubview:self.mainsubView];
            }

        }
        self.selectedIndex = 0;
      
        self.menuTableView.scrollEnabled=YES;

       
        self.menuTableView.backgroundColor=[UIColor whiteColor];
        self.menuTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
         self.menuTableView.separatorColor=[UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)59/255 blue:(CGFloat)11/255 alpha:(CGFloat)1];
        self.menuTableView.delegate = self;
        self.menuTableView.dataSource = self;
       
            // self. menuTableView.contentOffset=CGPointMake(200, self.view.frame.size.height+200);
//        [self.menuTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    }
    else{
        [self.menuTableView reloadData];
    }
    
    [self.view insertSubview:self.menuTableView belowSubview:self.mainsubView];
    
    
               NSLog(@"in iPhone4 ");
            imageVUser.frame=CGRectMake(self.view.frame.size.width-260, 20, 60, 60);
            lblUserName.frame=CGRectMake(self.view.frame.size.width-260,85 , 100, 20);

         
    
}


-(void)imageGesture:(UITapGestureRecognizer *)tapGesture{
    
    
    
}



-(void)textFieldDidBeginEditing:(UITextField *)textField{

 self.scrollView.contentOffset=CGPointMake(0,200);
}

-(void)textFieldDidEndEditing:(UITextField *)textField{

 self.scrollView.contentOffset=CGPointMake(0, 0);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)fillData
{
}

-(void)editButtonClick:(UIButton *)button{

}



#pragma mark -
#pragma mark TableView Delegate and DataSource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 3;
    
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
//    if (tableView == self.menuTableView) {
        if (section==0) {
            
            return 6;
        }
        else if(section==1){
            return 1;
        }else{
            return 9;
        }

//    }else{
//        
//        return 5;
//    }
   
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
   
    /*UIColor *firstColor =  [UIColor colorWithRed:(CGFloat)39/255 green:(CGFloat)39/255 blue:(CGFloat)41/255 alpha:1];
    UIColor *secColor = [UIColor colorWithRed:(CGFloat)48/255 green:(CGFloat)48/255 blue:(CGFloat)50/255 alpha:1];
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = cell.contentView.frame;
    layer.colors = [NSArray arrayWithObjects:(id)firstColor.CGColor,(id)secColor.CGColor, nil];
    
    [cell.contentView.layer insertSublayer:layer atIndex:0];*/
    
    cell.contentView.backgroundColor=[UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    
    
       // NSLog(@" ** Scrolled up");
        CGFloat direction = -1;//-for left, +for right
        cell.transform = CGAffineTransformMakeTranslation(cell.bounds.size.width * direction, 0);
        [UIView animateWithDuration:0.75 animations:^{
            cell.transform = CGAffineTransformIdentity;
        }];
        
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell Identifier";
    profileView.hidden=YES;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        //Check Section

    cell.textLabel.text =  [(UIViewController *)[self.viewControllers objectAtIndex:indexPath.row]title];
    cell.textLabel.font=[UIFont fontWithName:nil size:30.0];
    NSString *cellValue = [(UIViewController *)[self.viewControllers objectAtIndex:indexPath.row]title];
        //adding now
   // NSLog(@"cell value %@",cellValue);

     NSString *userName= [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
   
         if ([cellValue isEqualToString:@"Sign In"]||[cellValue isEqualToString:userName]) {
            cell.imageView.image=[UIImage imageNamed:@"signin1.png"];
        }
    
        else if ([cellValue isEqualToString:@"Go Live"]) {
            cell.imageView.image=[UIImage imageNamed:@"golive1.png"];
        }
    
    
  else if ([cellValue isEqualToString:@"Photo Bank"] || [cellValue isEqualToString:@"홈"]) {
        cell.imageView.image=[UIImage imageNamed:@"photobank1.png"];
    }
    else if ([cellValue isEqualToString:@"Video Bank"] || [cellValue isEqualToString:@"주제"]) {
        cell.imageView.image=[UIImage imageNamed:@"videobank1.png"];
    }
    else if ([cellValue isEqualToString:@"Following"] || [cellValue isEqualToString:@"친구"]) {
        cell.imageView.image=[UIImage imageNamed:@"Following1.png"];
    }
    else if ([cellValue isEqualToString:@"Notification"] || [cellValue isEqualToString:@"역사"]) {
        cell.imageView.image=[UIImage imageNamed:@"slideHistory.png"];
    }
        if (indexPath.section==1) {
        
             cell.textLabel.text =  [(UIViewController *)[self.viewControllers objectAtIndex:6]title];
             cell.imageView.image=[UIImage imageNamed:@"upcoming1.png"];
       
    }
    else if (indexPath.section==2){
        if(indexPath.row==0)
        {
            cell.textLabel.text =  [(UIViewController *)[self.viewControllers objectAtIndex:7]title];
             cell.imageView.image=[UIImage imageNamed:@"all1.png"];
        }else if (indexPath.row==1){
            cell.textLabel.text =  [(UIViewController *)[self.viewControllers objectAtIndex:8]title];
            cell.imageView.image=[UIImage imageNamed:@"entertainment1.png"];
        }else if (indexPath.row==2){
            cell.textLabel.text =  [(UIViewController *)[self.viewControllers objectAtIndex:9]title];
            cell.imageView.image=[UIImage imageNamed:@"sports1.png"];
        }else if (indexPath.row==3){
            cell.textLabel.text =  [(UIViewController *)[self.viewControllers objectAtIndex:10]title];
            cell.imageView.image=[UIImage imageNamed:@"animal1.png"];
        }else if (indexPath.row==4){
            cell.textLabel.text =  [(UIViewController *)[self.viewControllers objectAtIndex:11]title];
            cell.imageView.image=[UIImage imageNamed:@"music1.png"];
        }else if (indexPath.row==5){
            cell.textLabel.text =  [(UIViewController *)[self.viewControllers objectAtIndex:12]title];
            cell.imageView.image=[UIImage imageNamed:@"education1.png"];
        }else if (indexPath.row==6){
            cell.textLabel.text =  [(UIViewController *)[self.viewControllers objectAtIndex:13]title];
            cell.imageView.image=[UIImage imageNamed:@"gaming1.png"];
        }else if (indexPath.row==7){
            cell.textLabel.text =  [(UIViewController *)[self.viewControllers objectAtIndex:14]title];
          cell.imageView.image=[UIImage imageNamed:@"technology.png"];
        }else if (indexPath.row==8){
            cell.textLabel.text =  [(UIViewController *)[self.viewControllers objectAtIndex:15]title];
              cell.imageView.image=[UIImage imageNamed:@"news1.png"];
        }
    }
    
    return cell;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.segmentControl.hidden = YES;
    [UIView animateWithDuration:.5 animations:^{
        if (indexPath.section==0) {
            
            
            if(indexPath.row<2){
            UIViewController *viewControler= [_viewControllers objectAtIndex:indexPath.row];
                [self.navigationController pushViewController:viewControler animated:YES];
            }else{
                UIViewController *viewControler= [_viewControllers objectAtIndex:indexPath.row];
                [self addChildViewController:viewControler];
                [self getSelectedViewControllers:viewControler];
            }
            
        }else if (indexPath.section==1)
        {
            UIViewController *viewControler= [_viewControllers objectAtIndex:6];
          //  [self addChildViewController:viewControler];
            [self getSelectedViewControllers:viewControler];
        }
        else if (indexPath.section==2)
        {
            if (indexPath.row==0) {
                UIViewController *viewControler= [_viewControllers objectAtIndex:7];
               // [self addChildViewController:viewControler];
                [self getSelectedViewControllers:viewControler];
            }else if (indexPath.row==1){
                UIViewController *viewControler= [_viewControllers objectAtIndex:8];
               // [self addChildViewController:viewControler];
                [self getSelectedViewControllers:viewControler];
            }else if (indexPath.row==2){
                UIViewController *viewControler= [_viewControllers objectAtIndex:9];
               // [self addChildViewController:viewControler];
                [self getSelectedViewControllers:viewControler];
            }else if (indexPath.row==3){
                UIViewController *viewControler= [_viewControllers objectAtIndex:10];
               // [self addChildViewController:viewControler];
                [self getSelectedViewControllers:viewControler];
            }else if (indexPath.row==4){
                UIViewController *viewControler= [_viewControllers objectAtIndex:11];
                //[self addChildViewController:viewControler];
                [self getSelectedViewControllers:viewControler];
            }else if (indexPath.row==5){
                UIViewController *viewControler= [_viewControllers objectAtIndex:12];
               // [self addChildViewController:viewControler];
                [self getSelectedViewControllers:viewControler];
            }else if (indexPath.row==6){
                UIViewController *viewControler= [_viewControllers objectAtIndex:13];
                //[self addChildViewController:viewControler];
                [self getSelectedViewControllers:viewControler];
            }else if (indexPath.row==7){
                UIViewController *viewControler= [_viewControllers objectAtIndex:14];
               // [self addChildViewController:viewControler];
                [self getSelectedViewControllers:viewControler];
            }else if (indexPath.row==8){
                UIViewController *viewControler= [_viewControllers objectAtIndex:15];
               // [self addChildViewController:viewControler];
                [self getSelectedViewControllers:viewControler];
            }
            
        }
        self.mainsubView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    }completion:^(BOOL finished){
    }];
    
   
}//Index Path 1 End

-(void) getSelectedViewControllers:(UIViewController *)newViewController{
        // selected new view controller
    UIViewController *oldViewController = _selectedViewController;
    
    if (newViewController != nil) {
        [oldViewController.view removeFromSuperview];
        _selectedViewController = newViewController;
                [self updateViewContainer];
            //Check Delegate assign or not
    }
}

-(void) updateViewContainer{
    self.selectedViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        //NSLog(@"View Height  = %f",self.contentContainerView.frame.size.height);
    self.selectedViewController.view.frame = self.contentContainerView.bounds;
    
    self.menuLabel.text = self.selectedViewController.title;
    NSLog(@"menu label -=- %@",self.menuLabel.text);
    [self.contentContainerView addSubview:self.selectedViewController.view];
}


-(void) menuButtonClciked:(id)sender{
    
    NSString *userName= [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    NSString *signIn=[[NSUserDefaults standardUserDefaults]objectForKey:@"SignIn"];
    
    if (self.mainsubView.frame.origin.x>100 ) {
        
        [UIView animateWithDuration:.5 animations:^{
            self.mainsubView.frame = CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height);
            
        }completion:^(BOOL finish){
            self.swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
            
        }];
    }
    else{
        [UIView animateWithDuration:.5 animations:^{
            self.mainsubView.frame = CGRectMake(200, 0, self.view.frame.size.width, self.view.frame.size.height);
            
        }completion:^(BOOL finish){
            
            self.swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
            
        }];
    }
    
    if ([signIn isEqualToString:@"no"]) {
        self.menuTableView.frame = CGRectMake(0, 0, 200, self.view.frame.size.height-10);
        lblUserName.hidden=YES;
        imageVUser.hidden=YES;
        NSIndexPath *fifthRow = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [self.menuTableView cellForRowAtIndexPath:fifthRow];
        cell.textLabel.text = @"Sign In";
        
    }else{
        self.menuTableView.frame = CGRectMake(0, 130, 200, self.view.frame.size.height-130);
        NSIndexPath *fifthRow = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [self.menuTableView cellForRowAtIndexPath:fifthRow];
        cell.textLabel.text = userName;

        if (!imageVUser) {
            imageVUser = [[RoundedImageView alloc] init];
            imageVUser.frame=CGRectMake(40, 20, 80, 80);
            [imageVUser setImage:[UIImage imageNamed:@"profile.png"]];
            [imageVUser setUserInteractionEnabled:YES];
            [self.view insertSubview:imageVUser belowSubview:self.mainsubView];
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageGesture:)];
            [imageVUser addGestureRecognizer:tapGesture];
        }else{
            imageVUser.hidden=NO;
        }
        if (!lblUserName) {
            
            lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(60, 105, 150, 30) ];
            
            lblUserName.font=[UIFont boldSystemFontOfSize:12];
            lblUserName.textColor=[UIColor blackColor];
            lblUserName.text=@"Vinayaka";
                //        [self.headerView addSubview:lblUserName];
            [self.view insertSubview:lblUserName belowSubview:self.mainsubView];
        }else{
            lblUserName.hidden=NO;
        }
        
        lblUserName.text=userName;
    }

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
                        return 45;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 30;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    
   // [headerView setBackgroundColor:[UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)59/255 blue:(CGFloat)11/255 alpha:(CGFloat)1]];
//    72,128,230
     [headerView setBackgroundColor:[UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)128/255 blue:(CGFloat)230/255 alpha:(CGFloat)1]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, tableView.bounds.size.width - 10, 20)];
        label.font=[UIFont systemFontOfSize:15];
     label.textAlignment=NSTextAlignmentLeft;
    
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        
        
        if(section == 0){
            label.text= @"You";
        }
        if(section == 1){
            label.text= @"Upcoming";
        }
        if (section==2) {
            label.text= @"Explore";
        }
        
        [headerView addSubview:label];
            //        return headerView;
   

    return headerView;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"You";
    if(section == 1)
        return @"Upcoming";
    else
        return @"Explore";
    
}

#pragma mark-
#pragma Search Button Tapped
-(void)cameraButtonTapped:(UIButton *)button{
    NSLog(@"camera button tapped");
    
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    if(cameraDeviceAvailable && photoLibraryAvailable)
    {
        [self shouldStartCameraController];
    }
    //    else{
    //        [self shouldStartPhotoLibraryPickerController];
    //    }
    
    
    
    /*
     //rtmp library integration.
     
     GoLiveViewController *GoLivecontroller = [[GoLiveViewController alloc]initWithNibName:nil bundle:nil];
     [self.view addSubview:GoLivecontroller.view];
     */
    
    //  [self videostorageWebservice];//tested ok
    
    // [self Videoformybroadcasts]; //tested ok
    
    //  [self followVideoWebservice]; // tested ok.
    
    // [self unfollowVideoService];
    
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if(image)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
        
        [self uploadJPEGImage:nil image:image];
        
    }
    
}

//image upload web service

- (void)uploadJPEGImage:(NSString*)requestURL image:(UIImage*)image
{
    
    NSString *UserId =  [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    NSString *url1 = [NSString stringWithFormat:@"http://104.155.224.116/image_upload.php?userid=%@",UserId];
    NSURL *url = [[NSURL alloc] initWithString:url1];
    NSMutableURLRequest *urequest = [NSMutableURLRequest requestWithURL:url];
    
    [urequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urequest setHTTPShouldHandleCookies:NO];
    [urequest setTimeoutInterval:60];
    [urequest setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [urequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    // Add __VIEWSTATE
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"__VIEWSTATE\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"/wEPDwUKLTQwMjY2MDA0M2RkXtxyHItfb0ALigfUBOEHb/mYssynfUoTDJNZt/K8pDs=" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //http://movyt.socialsignifier.com/image_upload.php?userid=10
    
    // add image data
    
    //      [formData appendPartWithFileData:imageToUpload name:@"image_upload" fileName:@"image_upload.png" mimeType:@"png"];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"image_upload\"; filename=\"image_upload.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [urequest setHTTPBody:body];
    NSLog(@"Check response if image was uploaded after this log");
    //return and test
    NSHTTPURLResponse *response = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:urequest returningResponse:&response error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"reponse is -=-=-=-=-%@", returnString);
    
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)videostorageWebservice{
    
    NSError * error=nil;
    NSURLResponse * urlReponse=nil;
    NSString *device_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"device_token"];
    NSString * urlStr=[NSString stringWithFormat:@"http://104.155.224.116/index.php?method=videostorage&video_name=demo2&user_id=1032&screencast=new&device_token=%@",device_token];
    
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
    
    NSString *responseShow = [response objectForKey:@"message"];
    
    [[AppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"message"]];
    
    if ([responseShow isEqualToString:@"Login Unsuccessful"]){
        
        NSLog(@"user succesfully logged");
        
    }
}

-(void)Videoformybroadcasts{
    NSError * error=nil;
    NSURLResponse * urlReponse=nil;
    
    NSString * urlStr=[NSString stringWithFormat:@"http://104.155.224.116/index.php?method=videosearch&category=all&page=1&user_id=1032"];
    
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
    
}

-(void)followVideoWebservice{
    
    NSError * error=nil;
    NSURLResponse * urlReponse=nil;
    NSString *device_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"device_token"];
    NSString * urlStr=[NSString stringWithFormat:@"http://104.155.224.116/index.php?method=followvideo&video_id=113&user_id=1032&device_token=%@",device_token];
    
    
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
    
    
}

-(void)unfollowVideoService{
    
    NSError * error=nil;
    NSURLResponse * urlReponse=nil;
    
    NSString * urlStr=[NSString stringWithFormat:@"http://104.155.224.116/index.php?method=unfollowvideo&video_id=113&user_id=1032&follow_video_status=0"];
    //  unfollowvideo&video_id=1&user_id=1&
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
    
}

-(void)callStartWebservice{
    
    NSLog(@"web service start called");
    
    BOOL downloaded = [[NSUserDefaults standardUserDefaults] boolForKey:@"downloaded"];
    
    if (!downloaded) {
        NSError * error=nil;
        NSURLResponse * urlReponse=nil;
        
        NSString * urlStr=[NSString stringWithFormat:@"http://wowza:qwerty1234@104.155.224.116:8086/livestreamrecord?app=live&streamname=myStream&action=startRecording"];
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
        NSURLResponse * urlReponse;
        
        NSString * urlStr=[NSString stringWithFormat:@"http://wowza:qwerty1234@104.155.224.116:8086/livestreamrecord?app=live&streamname=myStream&action=stopRecording"];
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
