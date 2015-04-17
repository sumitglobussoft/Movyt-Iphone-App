//
//  SignInViewController.h
//  Video Stream
//
//  Created by Globussoft 1 on 3/13/15.
//
//

#import <UIKit/UIKit.h>
#import "SignUpViewController.h"

@interface SignInViewController : UIViewController<UITextFieldDelegate>
{
    SignUpViewController *signUp;
}
@property (nonatomic, strong) UIView *notSignView;
@property (nonatomic, strong) UIView *signedView;
@property (nonatomic, strong) UITextField *userName;
@property (nonatomic, strong) UITextField *userNameSigned;
@property (nonatomic, strong) UITextField *passWord;
@property(nonatomic,strong)UIImageView *profileImageView;
    //added now
@property(nonatomic,strong) UITextField *Email;
@property(nonatomic,strong) UITextField *Phonenumber;

@property (nonatomic, strong) UIImage *imageMainVC;
@property(nonatomic,strong)  UIButton *LoginButton;
@property(nonatomic,strong)  UIButton *signOutButton;
@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) UIScrollView *scrollView2;
@property(nonatomic,strong) UIWebView *webView;
@property(nonatomic,strong)UIButton *backButton;
- (BOOL) validateEmailWithString:(NSString *)emailStr;
@end
