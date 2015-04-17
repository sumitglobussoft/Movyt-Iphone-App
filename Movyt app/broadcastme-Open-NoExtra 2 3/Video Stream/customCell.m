//
//  customCell.m
//  MoveytProject
//
//  Created by Globussoft 1 on 4/29/14.
//  Copyright (c) 2014 Globussoft 1. All rights reserved.
//

#import "customCell.h"
//#import "Share.h"

@implementation customCell
@synthesize title;
@synthesize forShowingTime;
@synthesize imageView;
@synthesize popUPdisplay;

@synthesize liveNowlabel;

@synthesize liveNowimageView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(150, 10, 200, 30)];
        self.title.textColor = [UIColor blackColor];
        self.title.font = [UIFont fontWithName:@"Arial" size:20.0f];
        
        
        self.forShowingTime = [[UILabel alloc] initWithFrame:CGRectMake(150, 42, 200, 20)];
        self.forShowingTime.textColor = [UIColor blackColor];
        self.forShowingTime.font = [UIFont fontWithName:@"Arial" size:12.0f];
        
        
        [self addSubview:self.title];
        [self addSubview:self.forShowingTime];
        
        
        self.imageView=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 130, 60)];
        self.imageView.backgroundColor=[UIColor yellowColor];
        
        self.liveNowimageView=[[UIImageView alloc]initWithFrame:CGRectMake(140, 45, 15, 15)];
        self.liveNowimageView.image=[UIImage imageNamed:@"redbullet@2x.png"];
       ;
        

        
        self.liveNowlabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 45, 150, 20)];
        self.liveNowlabel.textColor = [UIColor redColor];
        self.liveNowlabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
        
        
        [self.contentView addSubview:liveNowimageView];
        [self.contentView addSubview:liveNowlabel];
        
        [self.contentView addSubview:self.imageView];
        [self addSubview:popUPdisplay];
        [self.contentView addSubview:self.popUPdisplay];
        
 
    }
    
    return self;
}
-(void)options:(UIButton *)button{
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                  initWithTitle:@"Options"
//                                  delegate:self
//                                  cancelButtonTitle:nil
//                                  destructiveButtonTitle:nil
//                                  otherButtonTitles:@"Share", @"Follow", @"Details", nil];
//    
//    [actionSheet showInView:self];

}


    
    
    
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
