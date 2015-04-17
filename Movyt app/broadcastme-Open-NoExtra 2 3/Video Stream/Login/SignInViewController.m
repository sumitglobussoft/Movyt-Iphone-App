//
//  SignInViewController.m
//  Video Stream
//
//  Created by Globussoft 1 on 3/13/15.
//
//

#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "RoundedImageView.h"
#import "AppDelegate.h"

@interface SignInViewController ()

@end

@implementation SignInViewController
@synthesize scrollView,LoginButton;
@synthesize userName,passWord,userNameSigned;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=NO;
      NSString *signIn=[[NSUserDefaults standardUserDefaults]objectForKey:@"SignIn"];
    NSString *username= [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];

    
    self.view.backgroundColor=[UIColor colorWithRed:(CGFloat)244/255 green:(CGFloat)244/255 blue:(CGFloat)244/255 alpha:(CGFloat)1] ;
    self.notSignView=[[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height)];
    self.notSignView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.notSignView];
    
    self.signedView=[[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height)];
    self.signedView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.signedView];
    
    if (![signIn isEqualToString:@"no"]) {
        self.notSignView.hidden=YES;
        
        }else{
        self.signedView.hidden=YES;
        
    }
    self.scrollView2=[[UIScrollView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height)];
    [self.scrollView2 setContentSize:CGSizeMake(320, 600)];
    [self.signedView addSubview:self.scrollView2];
    
    
    self.profileImageView = [[RoundedImageView alloc] init];
    self.profileImageView.frame=CGRectMake(self.view.frame.size.width/2-50, 20, 80, 80);
    [ self.profileImageView setImage:[UIImage imageNamed:@"profile.png"]];
    [ self.profileImageView setUserInteractionEnabled:YES];
    [self.scrollView2 addSubview: self.profileImageView];

    
    scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height)];
    [scrollView setContentSize:CGSizeMake(320, 600)];
    
    [self.notSignView addSubview:scrollView];

    
    self.signOutButton=[UIButton buttonWithType:UIButtonTypeCustom];
     self.signOutButton.frame=CGRectMake(100, 230, 100, 40) ;
    [ self.signOutButton addTarget:self action:@selector(signOut:) forControlEvents:UIControlEventTouchUpInside];
    [ self.signOutButton setImage:[UIImage imageNamed:@"signout@2x.png"] forState:UIControlStateNormal];
    [self.scrollView2 addSubview: self.signOutButton];

    
    userName=[[UITextField  alloc ]initWithFrame:CGRectMake(50, 60, 220, 40)];
    userName.delegate=self;
    userName.placeholder=@" UserName ";
    userName.text=@"vinayaka";
    userName.textAlignment = NSTextAlignmentLeft;
    userName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [userName setBackground:[UIImage imageNamed:@"text fill@2x.png"]];
    [scrollView addSubview:userName];
    
    userNameSigned=[[UITextField  alloc ]initWithFrame:CGRectMake(50, 60, 220, 40)];
    userNameSigned.delegate=self;
    userNameSigned.placeholder=@" UserName ";
    userNameSigned.text=@"vinayaka";
    userNameSigned.textAlignment = NSTextAlignmentLeft;
    userNameSigned.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [userNameSigned setBackground:[UIImage imageNamed:@"text fill@2x.png"]];
    [self.scrollView2 addSubview:userNameSigned];
    
    if (![signIn isEqualToString:@"no"]){
        
        userName.enabled=NO;
        userName.frame=CGRectMake(50, 140, 220, 40);
        userName.text=username;
    }
    
    passWord=[[UITextField  alloc ]initWithFrame:CGRectMake(50, 110, 220, 40)];
    passWord.delegate=self;
        //[passWord setBorderStyle:UITextBorderStyleNone];
    passWord.placeholder=@" Password  ";
    passWord.backgroundColor=[UIColor grayColor];
    passWord.secureTextEntry=YES;
    passWord.text=@"123456";
    passWord.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [passWord setBackground:[UIImage imageNamed:@"text fill@2x.png"]];
    [scrollView addSubview:passWord];
    
    
        // Do any additional setup after loading the view, typically from a nib.
    LoginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    LoginButton.frame=CGRectMake(50, 180, 100, 40) ;
    [LoginButton addTarget:self action:@selector(loginButton:) forControlEvents:UIControlEventTouchUpInside];
    [LoginButton setImage:[UIImage imageNamed:@"Login@2x.png"] forState:UIControlStateNormal];
    [scrollView addSubview:LoginButton];
    
    
    
    UIButton *forgetPasswordButton=[UIButton buttonWithType:UIButtonTypeCustom ];
    forgetPasswordButton.frame=CGRectMake(170, 180, 140, 40);
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:@"ForgotPassword"];
    [forgetPasswordButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [forgetPasswordButton addTarget:self action:@selector(forgetPassword:) forControlEvents:UIControlEventTouchUpInside];
 
    [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
    [commentString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,[commentString length])];
    
    [forgetPasswordButton setAttributedTitle:commentString forState:UIControlStateNormal];
       [scrollView addSubview:forgetPasswordButton];
    
    UILabel *newAtMoveyt=[[UILabel alloc]initWithFrame:CGRectMake(50, 245, 150, 20)];
    newAtMoveyt.text=@"New to Moveyt?";
    [newAtMoveyt setTextColor:[UIColor blackColor]];
    [scrollView addSubview:newAtMoveyt];
    
    
    UIButton *signUpButton=[UIButton buttonWithType:UIButtonTypeCustom];
    signUpButton.frame=CGRectMake(50, 260, 200, 40) ;
    [signUpButton setImage:[UIImage imageNamed:@"sign Up@2x.png"] forState:UIControlStateNormal];
    [signUpButton addTarget:self action:@selector(signUpButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [scrollView addSubview:signUpButton];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
 NSString *signIn=[[NSUserDefaults standardUserDefaults]objectForKey:@"SignIn"];
     NSString *username= [[NSUserDefaults standardUserDefaults]objectForKey:@"Username"];
    if (![signIn isEqualToString:@"no"]) {
        self.notSignView.hidden=YES;
        self.signedView.hidden=NO;
        userNameSigned.enabled=NO;
        userNameSigned.frame=CGRectMake(50, 140, 220, 40);
        userNameSigned.text=username;

        }else{
        self.notSignView.hidden=NO;
        self.signedView.hidden=YES;
    }

    
    self.navigationController.navigationBarHidden=NO;

}

-(void)signOut:(UIButton *)button{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"Username"];
    [[NSUserDefaults standardUserDefaults]setObject:@"no" forKey:@"SignIn"];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)signUpButton:(UIButton *) button{
    if (!signUp) {
         signUp=[[SignUpViewController alloc] init];
        
    }
   [self.navigationController pushViewController:signUp animated:YES];
}


-(void)loginButton:(UIButton *) button{
    
    NSError * error=nil;
    NSURLResponse * urlReponse=nil;
    
    NSString * urlStr=[NSString stringWithFormat:@"http://movyt.socialsignifier.com/index.php?method=login&username=%@&password=%@",userName.text,passWord.text];
    
    NSString * urlStr2=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url=[NSURL URLWithString:urlStr2];
    
    NSMutableURLRequest * request=[[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:50];
    
    
    NSData * data=[ NSURLConnection sendSynchronousRequest:request returningResponse:&urlReponse error:&error];
    
    
    if (data==nil) {
        NSLog(@" no data");
        return;
    }
    id response=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"reponse is %@",response);
    
    NSString *responseShow = [response objectForKey:@"message"];
    NSString *userId = [response objectForKey:@"user_id"];
    NSString *userName1 = [response objectForKey:@"username"];
    
    [[NSUserDefaults standardUserDefaults]setObject:userId forKey:@"userId"];
    [[NSUserDefaults standardUserDefaults]setObject:userName1 forKey:@"UserName"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    if ([responseShow isEqualToString:@"Login Successfully"]){
        
        NSLog(@"user succesfully logged");
        
        
    [[AppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"message"]];
    [[NSUserDefaults standardUserDefaults]setObject:userName.text forKey:@"Username" ];

        [[NSUserDefaults standardUserDefaults]setObject:@"yes" forKey:@"SignIn"];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}

- (BOOL) validateEmailWithString:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}


-(void)forgetPassword:(UIButton *)button{
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    NSString *url=@"http://movyt.socialsignifier.com/forgot.php";
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [self.webView loadRequest:nsrequest];
    [self.view addSubview:self.webView];
    
    self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton addTarget:self action:@selector(webViewBackButton:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.frame=CGRectMake(10, 10, 70, 20);
    
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    self.backButton.backgroundColor=[UIColor clearColor];
    [self.backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.webView addSubview:self.backButton];
    
}

-(void)webViewBackButton:(UIButton *)button{
    [self.webView removeFromSuperview];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField==userName) {
        
        if(userName.text.length > 5){
            if(![self validateEmailWithString:userName.text])
            {
                    // user entered invalid email address
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Enter a valid email address." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                return NO;
                    //email.text=@"";
            } else {
                    //                    [self.emailDelegate sendEmailForCell:emailTextField.text];
                [userName resignFirstResponder];
                return YES;
                
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Email address too Short" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            
            return NO;
        }
    }
    
    
        //    [userName resignFirstResponder];
    [passWord resignFirstResponder];
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
        //Keyboard becomes visible
    scrollView.frame = CGRectMake(scrollView.frame.origin.x,
                                  scrollView.frame.origin.y,
                                  scrollView.frame.size.width,
                                  scrollView.frame.size.height - 500 + 50);   //resize
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
        //keyboard will hide
    scrollView.frame = CGRectMake(scrollView.frame.origin.x,
                                  scrollView.frame.origin.y,
                                  scrollView.frame.size.width,
                                  scrollView.frame.size.height + 500 - 50); //resize
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
