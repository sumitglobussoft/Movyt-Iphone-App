//
//  customCell.h
//  MoveytProject
//
//  Created by Globussoft 1 on 4/29/14.
//  Copyright (c) 2014 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customCell : UITableViewCell<UIActionSheetDelegate>{

UITableView *popUpView;

}

@property(nonatomic,strong) UILabel *title;
@property(nonatomic,strong) UILabel *forShowingTime ;
@property(nonatomic,strong) UIImageView *imageView ;
@property(nonatomic,strong) UIButton *popUPdisplay;
@property(nonatomic,strong)UIImageView *liveNowimageView;
@property(nonatomic,strong) UILabel *liveNowlabel ;
@end
