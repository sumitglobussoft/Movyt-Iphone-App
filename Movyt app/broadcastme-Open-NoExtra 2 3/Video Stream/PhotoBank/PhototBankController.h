//
//  PhototBankController.h
//  Video Stream
//
//  Created by Globussoft 1 on 3/12/15.
//
//

#import <UIKit/UIKit.h>
#import "PhotoViewframe.h"

@interface PhototBankController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
{
    NSInteger int1;
    NSInteger toggle;
    NSArray *itemArray;
    PhotoViewframe *photo;
}

@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property(nonatomic,strong) UITableView *photoBank;
@property(nonatomic,strong) NSMutableArray *photoArray;
@property(nonatomic,strong) NSMutableArray *thumbPhotoArray;
@property (nonatomic, strong) UIView *mainsubView;
@end
