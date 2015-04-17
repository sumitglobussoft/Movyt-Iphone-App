//
//  MusicViewController.m
//  Video Stream
//
//  Created by Globussoft 1 on 3/13/15.
//
//

#import "MusicViewController.h"

@interface MusicViewController ()

@end

@implementation MusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mainsubView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    NSLog(@"Main sub view frame X=-=- %f \n Y == %f",[UIScreen mainScreen].bounds.origin.x,[UIScreen mainScreen].bounds.origin.y);
    self.mainsubView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mainsubView];
    
    itemArray=[NSArray arrayWithObjects:@"Live",@"Recent", nil];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    
    self.segmentControl.frame =CGRectMake(-4,0, self.view.frame.size.width+10, 30);
    
    [self.segmentControl addTarget:self action:@selector(mySegmentControlAction:) forControlEvents: UIControlEventValueChanged];
    [self.mainsubView addSubview:self.segmentControl];
    
    [self.segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
//    [self.segmentControl setBackgroundColor:[UIColor colorWithRed:(CGFloat)247/255 green:(CGFloat)96/255 blue:(CGFloat)41/255 alpha:(CGFloat)1]];
//    [self.segmentControl setTintColor:[UIColor colorWithRed:(CGFloat)193/255 green:(CGFloat)59/255 blue:(CGFloat)11/255 alpha:(CGFloat)1]];
    [self.segmentControl setBackgroundColor:[UIColor colorWithRed:(CGFloat)72/255 green:(CGFloat)128/255 blue:(CGFloat)230/255 alpha:(CGFloat)1]];
    [self.segmentControl setTintColor:[UIColor colorWithRed:(CGFloat)48/255 green:(CGFloat)101/255 blue:(CGFloat)196/255 alpha:(CGFloat)1]];
    self.segmentControl.selectedSegmentIndex=0;
    
    liveTable=[[UITableView alloc]initWithFrame:CGRectMake(0,40, self.view.frame.size.width, self.view.frame.size.height-40)];
    liveTable.delegate=self;
    liveTable.dataSource=self;
    liveTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:liveTable];
    
    // Do any additional setup after loading the view.
}

-(void)mySegmentControlAction:(UISegmentedControl *)segment{
    NSLog(@"in segment control action %ld",(long)segment.selectedSegmentIndex);
    
    if(self.segmentControl.selectedSegmentIndex==0){
        NSLog(@"hiii ->0");
        [liveTable reloadData];
        
    }else{
        NSLog(@"hiii ->1");
        [liveTable reloadData];
        
    }
}


#pragma mark -
#pragma mark UITableViewDelegates

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    customCell *cell = (customCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[customCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    if(self.segmentControl.selectedSegmentIndex==0){
        cell.title.text=@"Live Video";
        cell.forShowingTime.text=@"   10 hrs";
        cell.imageView.image=[UIImage imageNamed:@"hel.jpeg"];
        cell.liveNowimageView.hidden=NO;
    }else{
        cell.title.text=@"Recent Video";
        cell.forShowingTime.text=@"   14 hrs";
        cell.imageView.image=[UIImage imageNamed:@"hel.jpeg"];
        cell.liveNowimageView.hidden=NO;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(300.0f,10.0f, 20.0f, 20.0f);
    
    [button setImage:[UIImage imageNamed:@"Bulleted Live@2x.png"] forState:UIControlStateNormal];
    
    // [button addTarget:self action:@selector(performExpand: event :) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView=button;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.segmentControl.selectedSegmentIndex==0){
        //    PlayVideoFrame *video=[[PlayVideoFrame alloc]init ];
        //
        //
        //    [self presentViewController:video animated:YES completion:nil];
    }else{
        //    PlayVideoFrame *video=[[PlayVideoFrame alloc]init ];
        //
        //
        //    [self presentViewController:video animated:YES completion:nil];
        
    }
    
    
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 10;
//}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"return");
    NSLog(@"indexof row %d",indexPath.row);
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
