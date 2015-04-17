//
//  PhototBankController.m
//  Video Stream
//
//  Created by Globussoft 1 on 3/12/15.
//
//

#import "PhototBankController.h"
#import "customCell.h"
#import "UIImageView+WebCache.h"
#import "PhotoViewframe.h"

@interface PhototBankController ()

@end

@implementation PhototBankController

@synthesize photoBank,photoArray,thumbPhotoArray,segmentControl;

- (void)viewDidLoad {
    [super viewDidLoad];
//     self.navigationController.navigationBarHidden=NO;
    self.thumbPhotoArray= [[NSMutableArray alloc]init];
    self.photoArray = [[NSMutableArray alloc]init];
    
    toggle=0;
   
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
    
    photoBank=[[UITableView alloc]initWithFrame:CGRectMake(0,40, self.view.frame.size.width, self.view.frame.size.height-100)];
    photoBank.delegate=self;
    photoBank.dataSource=self;
    photoBank.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:photoBank];

    [self fetchPhotoWebService];

    // Do any additional setup after loading the view.
}

-(void)mySegmentControlAction:(UISegmentedControl *)segment{
    NSLog(@"in segment control action %ld",(long)segment.selectedSegmentIndex);
    
    if(self.segmentControl.selectedSegmentIndex==0){
        NSLog(@"hiii ->0");
//        [photoBank reloadData];
        
    }else{
        NSLog(@"hiii ->1");
//        [photoBank reloadData];
        
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
    
    cell.title.text=@"Photobank";
    cell.forShowingTime.text=@"   10 hrs";
    
    // cell.imageView.image=[UIImage imageNamed:@"hel.jpeg"];
    
    
    //test
    // NSString *userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    NSString *imageUrl =  [[self.thumbPhotoArray objectAtIndex:indexPath.row]objectForKey:@"arr"];
    
    //http://104.155.224.116//uploads/images/1032/7626060316100x100image_upload.jpg
    
    NSURL *urlStr=[NSURL URLWithString:[NSString stringWithFormat:@"http://104.155.224.116/%@",imageUrl]];
    //uploads/images/1032/6798318192100x100image_upload.jpg
    [cell.imageView setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:@"hel.jpeg"]];
    
    cell.liveNowimageView.hidden=NO;
    
    
    //    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
    //    cell.accessoryView = [[UIImageView alloc]
    //                          initWithImage:[UIImage imageNamed:@"Bulleted Live@2x.png"]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(300.0f,10.0f, 20.0f, 20.0f);
    
    [button setImage:[UIImage imageNamed:@"Bulleted Live@2x.png"] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(performExpand: event :) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView=button;
    
    
    //    cell.accessoryType=button.v;
    // cell.accessoryType=UITableViewCellAccessoryDetailButton;
    return cell;
}

-(void)fetchPhotoWebService{
    
    NSError * error=nil;
    NSURLResponse * urlReponse=nil;
    
    NSString *userid=[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
  
    NSString * urlStr=[NSString stringWithFormat:@"http://104.155.213.29/index.php?index.php?method=fetchImage&userid=%@",userid];
    
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
        [self.photoArray addObject:@{@"arr":[dic objectForKey:@"image_path"]}];
    }
    
    for (NSDictionary *dic in [response objectForKey:@"message"] ) {
        [self.thumbPhotoArray addObject:@{@"arr":[dic objectForKey:@"thumb_image_path"]}];
    }
    NSLog(@"self.photo array is %@",self.photoArray);
    
}


- (void)performExpand:(id)sender event:(id)event
{
    NSSet * touches = [event allTouches];
    UITouch * touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView: photoBank];
    NSIndexPath * indexPath = [photoBank indexPathForRowAtPoint: currentTouchPosition];
    NSLog(@"indexpath.row %i",indexPath.row);
    int1=indexPath.row;
    if (indexPath  != nil)
    {
        [self tableView:photoBank  accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
    UIActionSheet *myActionSheet=[[UIActionSheet alloc ]initWithTitle:@"Options for Video are:" delegate:self cancelButtonTitle:@"Exit" destructiveButtonTitle:nil otherButtonTitles:@"Share",@"Detail",@"Follow",nil];
    [myActionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    
    if ([buttonTitle isEqualToString:@"Share"]) {
//        Share *recent=[[Share alloc]initWithNibName:@"RecentItems" bundle:nil];
//        [self presentViewController:recent animated:YES completion:nil];
//        NSString *string1 = [NSString stringWithFormat:@"%d", int1];
//        recent.indexPath.text=string1;
        
        //        [self.navigationController pushViewController:recent animated:YES];
    }
    if ([buttonTitle isEqualToString:@"Detail"]) {
//        DetailsOfVideo *details=[[DetailsOfVideo alloc]init];
//        [self presentViewController:details animated:YES completion:nil];
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
        //        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"U will gate follows of that person" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        //        [alertView show];
    }
    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.photoArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *imageUrl =  [[self.photoArray objectAtIndex:indexPath.row]objectForKey:@"arr"];
    
   
    if (!photo) {
        photo=[[PhotoViewframe alloc]init ];

    }
     photo.urlStr= imageUrl;
    [self.navigationController pushViewController:photo animated:YES];
    
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{}


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
