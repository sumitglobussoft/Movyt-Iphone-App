//
//  EntertainmentController.h
//  Video Stream
//
//  Created by Globussoft 1 on 3/13/15.
//
//

#import <UIKit/UIKit.h>
#import "customCell.h"

@interface EntertainmentController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UITableView *liveTable;
    NSArray *itemArray;

}

@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UIView *mainsubView;
@property (nonatomic, strong) NSMutableArray *entertainmentArray;
@end
