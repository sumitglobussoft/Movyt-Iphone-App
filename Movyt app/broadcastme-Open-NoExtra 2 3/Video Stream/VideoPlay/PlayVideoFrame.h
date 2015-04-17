//
//  PlayVideoFrame.h
//  MoveytProject
//
//  Created by Globussoft 1 on 5/15/14.
//  Copyright (c) 2014 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayVideoFrame : UIViewController<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,MPMediaPickerControllerDelegate,MPMediaPlayback>
{
    NSInteger likeCount;
    NSInteger toggleLike;
   
}
@property(nonatomic,strong) UIView *videoPlayerview;

@property(nonatomic,strong) MPMoviePlayerController *moviePlayer;
//@property(nonatomic,strong) MPMoviePlayerViewController *movieController;
@property(nonatomic,strong)UITextView *textView;
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UITableView *commentTable;
@property(nonatomic,strong) UIButton *likeButton;
@property(nonatomic,strong) NSMutableArray *dataArray;
@property(nonatomic,strong) NSMutableArray *commentArray;
@property(nonatomic,strong) NSMutableArray *commentUserArray;
//@property(nonatomic,strong) NSMutableArray *urlArray;
@property(nonatomic,strong) NSString *playUrl;
@property (nonatomic) UIWebView *videoPlayWebView;


@end
