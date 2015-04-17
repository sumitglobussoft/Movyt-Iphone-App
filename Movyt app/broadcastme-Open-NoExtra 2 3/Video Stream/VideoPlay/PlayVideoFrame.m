//
//  PlayVideoFrame.m
//  MoveytProject
//
//  Created by Globussoft 1 on 5/15/14.
//  Copyright (c) 2014 Globussoft 1. All rights reserved.
//

#import "PlayVideoFrame.h"
//#import "CustomMenuViewController.h"
#import "AppDelegate.h"
//#import "MyPlayerLayerView.h"
//#import "MyStreamingMovieViewController.h"

@interface PlayVideoFrame ()

@end

@implementation PlayVideoFrame
@synthesize videoPlayerview,playUrl;
//@synthesize moviePlayer;
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
    self.commentArray=[[NSMutableArray alloc]init];
    self.commentUserArray=[[NSMutableArray alloc]init];
    
//   [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
   //  [[AVAudioSession sharedInstance] setCategory:AVVideoScalingModeFit error:nil];
    self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width-10, 600)];
    [self.view addSubview:self.scrollView];
    [self GetCommentsWebService];

  //  NSURL *url = [[NSURL alloc]initWithString:self.playUrl];
    // NSURL *url = [NSURL URLWithString:self.playUrl];
    // NSURL *url = [[NSURL alloc]initWithString:@"http://movyt.socialsignifier.com/uploads/videos/video13.mp4"];
   
    NSLog(@"url in playvideo frame is %@",self.playUrl);
    // NSURL *url = [[NSURL alloc]initWithString:@"http://www.jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v"];
    toggleLike=0;
    likeCount=0;

//    MyStreamingMovieViewController *myStream = [[MyStreamingMovieViewController alloc]init];
//    [myStream loadMovieButtonPressed:nil];

    
     UIButton *backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame=CGRectMake(10, 10, 50, 30);
    [backButton addTarget:self action:@selector(backButtonMethod:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"back.jpeg"] forState:UIControlStateNormal];
    [self.scrollView addSubview:backButton];
    
    self.likeButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.likeButton setBackgroundColor:[UIColor yellowColor]];
    self.likeButton.frame= CGRectMake(10, 250, 100, 30);
    [self.likeButton setTitle:@"like" forState:UIControlStateNormal];
    [self.likeButton addTarget:self action:@selector(likeButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.likeButton];
    
    self.commentTable=[[UITableView alloc] initWithFrame:CGRectMake(10, 280, 300, 200) style:UITableViewStylePlain];
    self.commentTable.delegate=self;
    self.commentTable.dataSource=self;
    [self.scrollView addSubview:self.commentTable];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 480, 300, 50)];
    self.textView.textColor = [UIColor whiteColor];
    self.textView.font = [UIFont fontWithName:@"Arial" size:18];
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor grayColor];
    
    self.textView.text = @"Comments";
    self.textView.returnKeyType = UIReturnKeyDefault;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    self.textView.scrollEnabled = YES;
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.scrollView addSubview: self.textView];
    
    self.dataArray=[[NSMutableArray alloc] init];
   

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden=NO;
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        //self.navigationController.navigationBarHidden = YES;
       // [player.view removeFromSuperview];
    }
}

//- (void) moviePlayBackDidFinish:(NSNotification*)notification {
//    NSError *error = [[notification userInfo] objectForKey:@"error"];
//    if (error) {
//        NSLog(@"Did finish with error: %@", error);
//    }
//}

//- (void) moviePlayBackDidFinish:(NSNotification*)notification {
//    
//    moviePlayer = [notification object];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
//    
//    if ([moviePlayer respondsToSelector:@selector(setFullscreen:animated:)])
//    {
//        [moviePlayer.view removeFromSuperview];
//    }
//}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
//    [self.videoPlayWebView stopLoading];
}


-(void)backButtonMethod:(UIButton *)button{

    [self dismissViewControllerAnimated:YES completion:nil];

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return YES;
}

-(void)likeButtonEvent:(UIButton *)button{
    if (toggleLike==1) {
        [self.likeButton setTitle:@"Like" forState:UIControlStateNormal];
        toggleLike=0;
    }
    if (toggleLike==0) {
         [self.likeButton setTitle:@"Unlike" forState:UIControlStateNormal];
        likeCount++;
        toggleLike=1;

    }
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{

    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"SEND" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton:)],nil];
    textView.inputAccessoryView = numberToolbar;
    return YES;
}

-(void)doneButton:(id)sender{
    [self.textView resignFirstResponder];
    [self.dataArray addObject:self.textView.text];
    [self addCommentWebService];
    self.textView.text=nil;
    [self.commentTable reloadData];
}

-(void)addCommentWebService{
    NSError * error=nil;
    NSURLResponse * urlReponse=nil;
     NSString *device_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"device_token"];
    NSString * urlStr=[NSString stringWithFormat:@"http://104.155.224.116/index.php?method=comments&video_id=113&user_id=1032&comment=%@&device_token=%@",self.textView.text,device_token];
    
  //  comments&video_id=1&user_id=1&comment=test&device_token=1

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

    [self GetCommentsWebService];
    
}

-(void)GetCommentsWebService{
    NSError * error=nil;
    NSURLResponse * urlReponse=nil;
 
    NSString * urlStr=[NSString stringWithFormat:@"http://104.155.224.116/index.php?method=getcomments&video_id=113"];
     // getcomments&video_id=1
    //  comments&video_id=1&user_id=1&comment=test&device_token=1
    
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
    
    
    for (NSDictionary *dic in [response objectForKey:@"message"] ) {
        [self.commentArray addObject:@{@"cmt":[dic objectForKey:@"comment"]}];
    }
  //  NSLog(@"self.commentArray is %@",self.commentArray);
    
    for (NSDictionary *dict in [response objectForKey:@"message"]) {
        [self.commentUserArray addObject:@{@"cuser":[dict objectForKey:@"user_name"]}];
    }
   // NSLog(@"self.commentUserArray is %@",self.commentUserArray);

}


#pragma mark-
#pragma Comment tableView delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

   // NSLog(@"comment array count is %lu",(unsigned long)self.commentArray.count);
    return self.commentArray.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"Cell Identifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //NSLog(@"[self.commentArray objectAtIndex:indexPath.row] Is %@",[self.commentArray objectAtIndex:indexPath.row]);
    
    cell.textLabel.text=[[self.commentArray objectAtIndex:indexPath.row]objectForKey:@"cmt"];
    
    return cell;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.scrollView.contentOffset=CGPointMake(0,textView.frame.origin.y);
    textView.text=@"";
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    self.scrollView.contentOffset=CGPointMake(-5,10);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.textView resignFirstResponder];
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
