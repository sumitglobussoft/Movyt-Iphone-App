//
//  VideoBankController.m
//  Video Stream
//
//  Created by Globussoft 1 on 3/12/15.
//
//

#import "VideoBankController.h"
#import "customCell.h"
#import "DetailsOfVideo.h"
#import "PlayVideoFrame.h"
#import "ViewController.h"


@interface VideoBankController (){
   
   //  VMediaPlayer       *mMPayer;
}

@end

@implementation VideoBankController
/*
static NSString *sMediaURLs[] = {
    //	@"assets-library://asset/asset.MOV?id=112C86F5-1A5E-42EF-ADFA-0BE19C540665&ext=MOV",
    
    @"v.mp4",
    
    @"http://hot.vrs.sohu.com/ipad1407291_4596271359934_4618512.m3u8", // 2
    @"http://219.232.161.210:5080/livestream/uv54q5wp_20131215132307_20131215132522.ts",
    
    @"http://219.232.161.210:5080/livestream/uv54q5wp20131215191827.ts",
    @"http://stream.foream.cn:5080/hls/timeshift/hX1fvBGT.m3u8",
    
    @"http://219.232.161.210:5080/livestream/uv54q5wp_20131215132307_20131215132522.ts",
    
    //	@"http://ting.weibo.com/page/appclient/getmp3?object_id=1022:10151501_121466&source_id=1040",
    
    //	@"d/like.mp4",
    //	@"d/like.mkv",
    //	@"d/big.mkv",
    //	@"d/big.mov",
    //	@"d/vv.mp4",
    //	@"d/11.rmvb",
    //	@"d/2/2.m3u8",
    //	@"d/JiaZhouLvGuan.avi",
    //	@"d/r.mkv",
    
    //	@"d/beyond.flac",
    
    @"http://hot.vrs.sohu.com/ipad1407291_4596271359934_4618512.m3u8", // 2
    @"http://hot.vrs.sohu.com/ipad1407282_4596271442077_4618503.m3u8", // 1
    
    @"http://paikeapp.video.sina.com.cn/stream/D9xQWySKVsGlnzq~.mp4", // open slowly?
    @"http://metal.video.qiyi.com/20131104/dbb56b29ef709ba4c9e17621c0e5c2a5.m3u8", // 40
    
    @"rtmp://42.121.85.232/live/20854663",
    
    // bad
    //	@"http://v.youku.com/player/getRealM3U8/vid/XMjc5NjQxOTQ4/type//video.m3u8",
    //	@"http://mtv.v.iask.com/manifest/20130924906_400.m3u8",
    //	@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8",
    
    // good
    //	@"http://mp4i.vodfile.m1905.com/movie/1202/120298DF21FC43729B32.mp4",
    
    //	@"rtsp://www.jxtvjd.com/jxtv7",
    
    //	@"mms://218.61.6.228/jtgb?NiMwIzE=",
    //	@"mms://cdnmms.cnr.cn/cnr001",
    //	@"http://ndrstream.ic.llnwd.net/stream/ndrstream_ndr1wellenord_hi_mp3",
    
    
    //	@"http://metal.video.qiyi.com/395/07705bd9a5adb020805afdb6bec05168.m3u8", //  泰囧 2012年
    //	@"http://v.youku.com/player/getRealM3U8/vid/XNjA1ODU3MDA4/type/mp4", // - 15
    //	@"http://metal.video.qiyi.com/276/61739091ac7cf21a479fbe683384fc81.m3u8", // 父子
    ////	@"http://metal.video.qiyi.com/20131015/8602db40710b279823eefb28851fa7ed.m3u8", // 3
    //	@"http://metal.video.qiyi.com/20131014/159fd3bbd63503e3807af1dffcaf107b.m3u8", // 1
    //	@"http://metal.video.qiyi.com/20131016/e703483d81fd519619e925fa52d7191d.m3u8", // 2
    
    //	@"http://17173.tv.sohu.com/api/2525361.m3u8",
    //	@"http://17173.tv.sohu.com/api/1632389.m3u8",
    
    //	@"http://chanson.cdnvideo.ru/paramlive/chanson128.stream/playlist.m3u8", // only audio stream(AAC)
    @"http://v.youku.com/player/getRealM3U8/vid/XNDY2ODM2NTg0/type/mp4",
    
    @"http://17173.tv.sohu.com/api/2752061.m3u8",
    @"http://17173.tv.sohu.com/api/1620355.m3u8",
    
    @"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8", // contains multiple video stream
    //    @"mms://alive.rbc.cn/fm1006",
    //	@"mms://218.61.6.228/jtgb?NiMwIzE=",
    //	@"rtmp://113.161.212.25/live/atv1",
    
    //	@"http://112.197.2.11:1935/live/vtv3.stream/playlist.m3u8",
    //	@"http://184.72.239.149/vod/smil:bigbuckbunnyiphone.smil/playlist.m3u8", // contains multiple video stream
    //	@"http://sjlive.cbg.cn/app_2/_definst_/ls_2.stream/playlist.m3u8",
    
    //	@"http://live.gslb.letv.com/gslb?stream_id=cctv1&tag=live&ext=m3u8&sign=live_ipad", // live
    
    //	@"http://v.youku.com/player/getRealM3U8/vid/XMTgzMTQ1NjYw/type/mp4",
    
    @"http://gslb.yixia.com/stream/brTfKUwBl7asf0bF.mp4?yx=",
    
    @"http://v.youku.com/player/getRealM3U8/vid/XMTI2NjQzMDAw/type/hd2",
    @"http://v.youku.com/player/getRealM3U8/vid/XNjI1NjM4MDIw/type/hd2",
    @"http://v.youku.com/player/getRealM3U8/vid/XNjI4MzAyOTQ0/type/mp4",
    
    @"http://pl.youku.com/playlist/m3u8?vid=XMzYwNDAyNDgw&type=mp4&ts=1381806651&keyframe=0",
    
    @"http://v.youku.com/player/getRealM3U8/vid/XNTY0ODIwODQ0/type/hd2",
    //	@"http://f3.r.56.com/f3.c56.56.com/flvdownload/10/9/128093354047hd.flv?v=1&t=KiCn5l4sG4hKYjQ1t1SeJw&r=47239&e=1382603789&tt=6440&sz=215433701&vid=58425523",
    @"http://v.youku.com/player/getRealM3U8/vid/XNjAwMDM5MDI0/type/hd2",
    
    @"http://pl.youku.com/playlist/m3u8?vid=XMzYwNDAyNDgw&type=mp4&ts=1381806651&keyframe=0",
    @"http://pl.youku.com/playlist/m3u8?vid=XNDM3NTk5NDY0&type=mp4&ts=1381806059&keyframe=0",
    
    //	@"http://v.youku.com/player/getRealM3U8/vid/XNjIxMTM4MjY4/type/mp4/ts/1381743774/useKeyframe/0/video.m3u8",
    
    @"http://159.226.15.215:8080/hls/zeiou/zeiou.m3u8",
};
*/
//static int sCurrPlayIdx;


@synthesize VideoBank,image2,segmentControl,mainsubView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userVideosArray = [[NSMutableArray alloc]init];
    [self getUserVideos];
    self.mainsubView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    NSLog(@"Main sub view frame X=-=- %f \n Y == %f",[UIScreen mainScreen].bounds.origin.x,[UIScreen mainScreen].bounds.origin.y);
    self.mainsubView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mainsubView];
    
    itemArray=[NSArray arrayWithObjects:@"Live",@"Recent", nil];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    
    self.segmentControl.frame =CGRectMake(-4,3, self.view.frame.size.width+10, 30);
    
    [self.segmentControl addTarget:self action:@selector(mySegmentControlAction:) forControlEvents: UIControlEventValueChanged];
    [self.mainsubView addSubview:self.segmentControl];
    
    [self.segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
//    [self.segmentControl setBackgroundColor:[UIColor colorWithRed:(CGFloat)247/255 green:(CGFloat)96/255 blue:(CGFloat)41/255 alpha:(CGFloat)1]];
//    [self.segmentControl setTintColor:[UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)59/255 blue:(CGFloat)11/255 alpha:(CGFloat)1]];
    [self.segmentControl setBackgroundColor:[UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)128/255 blue:(CGFloat)230/255 alpha:(CGFloat)1]];
    [self.segmentControl setTintColor:[UIColor colorWithRed:(CGFloat)48/255 green:(CGFloat)101/255 blue:(CGFloat)196/255 alpha:(CGFloat)1]];
    self.segmentControl.selectedSegmentIndex=0;

    toggle=0;
    VideoBank=[[UITableView alloc]initWithFrame:CGRectMake(0,40, self.view.frame.size.width, self.view.frame.size.height-100)];
    VideoBank.delegate=self;
    VideoBank.dataSource=self;
    VideoBank.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:VideoBank];
    // Do any additional setup after loading the view.
}
-(void)mySegmentControlAction:(UISegmentedControl *)segment{
    NSLog(@"in segment control action %ld",(long)segment.selectedSegmentIndex);
    
    if(self.segmentControl.selectedSegmentIndex==0){
        NSLog(@"hiii ->0");
      //  [liveTable reloadData];
        
    }else{
        NSLog(@"hiii ->1");
       // [liveTable reloadData];
        
    }
}


#pragma UITableViewDelegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    customCell *cell = (customCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[customCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *imageUrl =  [[self.userVideosArray objectAtIndex:indexPath.row]objectForKey:@"arr"];

    cell.title.text=imageUrl;
    cell.forShowingTime.text=@"   10 hrs";
    cell.imageView.image=image2;
    //        cell.imageView.image=[UIImage imageNamed:@"hel.jpeg"];
    cell.liveNowimageView.hidden=NO;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(300.0f,10.0f, 20.0f, 20.0f);
    
    [button setImage:[UIImage imageNamed:@"Bulleted Live@2x.png"] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(performExpand:  event:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView=button;
    
    
    return cell;
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.userVideosArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
    
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.isPlay2 = YES;
//    PlayerController *playerCtrl;
//    playerCtrl = [[[PlayerController alloc] initWithNibName:nil bundle:nil] autorelease];
//    playerCtrl.delegate = self;
//    [self presentViewController:playerCtrl animated:YES completion:nil];
    //   [self.navigationController pushViewController:playerCtrl animated:YES];
//
    ViewController *viewCtrl;
    viewCtrl = [[ViewController alloc]initWithNibName:nil bundle:nil];
    [self presentViewController:viewCtrl animated:YES completion:nil];
    
  }

#pragma mark - PlayerControllerDelegate
/*
- (NSURL *)playCtrlGetCurrMediaTitle:(NSString **)title lastPlayPos:(long *)lastPlayPos
{
    if (self.isPlay2) {
        NSURL *url =[NSURL URLWithString:@"rtmp://104.155.213.29:8086/live/khomeshsahu"];
        NSLog(@"url is= %@",url);
        return [NSURL URLWithString:@"rtmp://104.155.213.29:8086/live/khomeshsahu"];
    }
    
    int num = sizeof(sMediaURLs) / sizeof(sMediaURLs[0]);
    sCurrPlayIdx = (sCurrPlayIdx + num) % num;
    NSString *v = sMediaURLs[sCurrPlayIdx];
    NSLog(@"returned is %@",[NSURL URLWithString:[v stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]);
    return [NSURL URLWithString:[v stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURL *)playCtrlGetNextMediaTitle:(NSString **)title lastPlayPos:(long *)lastPlayPos
{
    int num = sizeof(sMediaURLs) / sizeof(sMediaURLs[0]);
    sCurrPlayIdx = (sCurrPlayIdx + num + 1) % num;
    NSString *v = sMediaURLs[sCurrPlayIdx];
    return [NSURL URLWithString:[v stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSURL *)playCtrlGetPrevMediaTitle:(NSString **)title lastPlayPos:(long *)lastPlayPos
{
    int num = sizeof(sMediaURLs) / sizeof(sMediaURLs[0]);
    sCurrPlayIdx = (sCurrPlayIdx + num - 1) % num;
    NSString *v = sMediaURLs[sCurrPlayIdx];
    return [NSURL URLWithString:[v stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

*/

- (void)performExpand:(id)sender event:(id)event
{
    NSSet * touches = [event allTouches];
    UITouch * touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:VideoBank];
    NSIndexPath * indexPath = [VideoBank indexPathForRowAtPoint: currentTouchPosition];
    NSLog(@"indexpath.row %li",(long)indexPath.row);
    int1=indexPath.row;
    if (indexPath  != nil)
    {
        [self tableView:VideoBank  accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
    UIActionSheet *myActionSheet=[[UIActionSheet alloc ]initWithTitle:@"Options for Video are:" delegate:self cancelButtonTitle:@"Exit" destructiveButtonTitle:nil otherButtonTitles:@"Share",@"Detail",@"Follow",nil];
    [myActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    
    if ([buttonTitle isEqualToString:@"Share"]) {
//        Share *recent=[[Share alloc]initWithNibName:@"Share" bundle:nil];
//        [self presentViewController:recent animated:YES completion:nil];
//        NSString *string1 = [NSString stringWithFormat:@"%d", int1];
//        recent.indexPath.text=string1;
        
        
    }
    if ([buttonTitle isEqualToString:@"Detail"]) {
        DetailsOfVideo *details=[[DetailsOfVideo alloc]init];
        [self presentViewController:details animated:YES completion:nil];
        NSLog(@"Follow pressed");
    }
    if ([buttonTitle isEqualToString:@"Follow"]) {
        NSLog(@"Details pressed");
        if (toggle==0) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"U will  follow" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alertView show];
            toggle=1;
            return;
        }
        
        if (toggle==1) {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"U will  unfollow " delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alertView show];
            toggle=0;
        }
        
    }
}

-(void)getUserVideos{
    NSError * error=nil;
    NSURLResponse * urlReponse=nil;
    
    NSString *userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    userid = @"1";
    NSString * urlStr=[NSString stringWithFormat:@"http://104.155.213.29/index.php?method=videosearch&category=all&page=1&user_id=%@",userid];
    
//    http://104.155.213.29/index.php?method=videosearch&category=all&page=1&user_id=1
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
        [self.userVideosArray addObject:@{@"arr":[dic objectForKey:@"video_name"]}];
    }
//
    NSLog(@"self.userVideosArray is %@",self.userVideosArray);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
