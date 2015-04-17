//
//  DetailsOfVideo.h
//  MoveytProject
//
//  Created by Globussoft 1 on 5/6/14.
//  Copyright (c) 2014 Globussoft 1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsOfVideo : UIViewController<UITextFieldDelegate>{
    UIScrollView *scrollView;
}
@property(nonatomic,strong)UITextView* textView;
@property(nonatomic,strong)UILabel *detailsLabel;
@property(nonatomic,strong)UILabel *pictureLabel;
@property(nonatomic,strong)UILabel *liveNowLabel;

@end
