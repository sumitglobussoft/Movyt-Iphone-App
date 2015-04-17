//
//  VideoBankController.h
//  Video Stream
//
//  Created by Globussoft 1 on 3/12/15.
//
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Vitamio.h"
#import "PlayerController.h"
#import "PlayerControllerDelegate.h"

@interface VideoBankController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    NSInteger int1;
    NSInteger toggle;
    NSArray *itemArray;
  //  MyStreamingMovieViewController *stream1;
}
@property(nonatomic,strong) UITableView *VideoBank;
@property(nonatomic,strong) MPMoviePlayerController *moviePlayer;
@property(nonatomic,strong) UIImage *image2;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UIView *mainsubView;
@property (nonatomic, copy)   NSURL *videoURL;
@property (nonatomic, assign) UITextField *urlTextFidld;
@property (nonatomic, assign)          int          isPlay2;
@property (nonatomic,strong) NSMutableArray *userVideosArray;
@end
