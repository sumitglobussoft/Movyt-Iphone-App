//
//  SignUpViewController.h
//  Video Stream
//
//  Created by Globussoft 1 on 3/13/15.
//
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController<UITextFieldDelegate>{
    BOOL checkBoxSelected;
    NSMutableString *mutableString;

}
@property(nonatomic,strong) UITextField *nameField;
@property(nonatomic,strong) UITextField *passWordField;
@property(nonatomic,strong) UITextField *emailField;
@property(nonatomic,strong) UITextField *conFirmPassField;
@property(nonatomic,strong) UITextField *phoneNoField;
@property(nonatomic,strong)UIButton *checkBox;
@property(nonatomic,strong)UIButton *registerButton;
@property(nonatomic,strong) UIScrollView *scrollView;
@end
