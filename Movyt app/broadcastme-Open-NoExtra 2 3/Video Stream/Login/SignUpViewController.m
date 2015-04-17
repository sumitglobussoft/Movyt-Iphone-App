//
//  SignUpViewController.m
//  Video Stream
//
//  Created by Globussoft 1 on 3/13/15.
//
//

#import "SignUpViewController.h"
#import "AppDelegate.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController
@synthesize nameField;
@synthesize scrollView;
@synthesize passWordField;
@synthesize phoneNoField;
@synthesize emailField;
@synthesize conFirmPassField;
@synthesize checkBox;
@synthesize registerButton;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=NO;
    self.view.backgroundColor=[UIColor whiteColor];
    
    scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    [scrollView setContentSize:CGSizeMake(320, 600)];
    [self.view addSubview:scrollView];
    
    
    nameField=[[UITextField  alloc ]initWithFrame:CGRectMake(50, 80, 220, 50)];
    nameField.delegate=self;
    nameField.placeholder=@" Name ";
    nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [nameField setBackground:[UIImage imageNamed:@"text fill@2x.png"]];
    [scrollView addSubview:nameField];
    
    
    emailField=[[UITextField  alloc ]initWithFrame:CGRectMake(50, 150, 220, 50)];
    emailField.delegate=self;
    emailField.placeholder=@" EmailAddress ";
    emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [emailField setKeyboardType:UIKeyboardTypeEmailAddress];
    [emailField setBackground:[UIImage imageNamed:@"text fill@2x.png"]];
    [scrollView addSubview:emailField];
    
    passWordField=[[UITextField  alloc ]initWithFrame:CGRectMake(50, 220, 220, 50)];
    passWordField.delegate=self;
    passWordField.placeholder=@" PassWord ";
    passWordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passWordField.secureTextEntry=YES;
    [passWordField setBackground:[UIImage imageNamed:@"text fill@2x.png"]];
    [scrollView addSubview:passWordField];
    
    conFirmPassField=[[UITextField  alloc ]initWithFrame:CGRectMake(50, 290, 220, 50)];
    conFirmPassField.delegate=self;
    conFirmPassField.placeholder=@" ConfirmPassword ";
    conFirmPassField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    conFirmPassField.secureTextEntry=YES;
    [conFirmPassField setBackground:[UIImage imageNamed:@"text fill@2x.png"]];
    [scrollView addSubview:conFirmPassField];
    
    phoneNoField=[[UITextField  alloc ]initWithFrame:CGRectMake(50, 360, 220, 50)];
    phoneNoField.delegate=self;
    phoneNoField.placeholder=@" PhoneNumber ";
    phoneNoField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [phoneNoField setKeyboardType:UIKeyboardTypeNumberPad];
    [phoneNoField setBackground:[UIImage imageNamed:@"text fill@2x.png"]];
    
    [scrollView addSubview:phoneNoField];
    
    
    registerButton=[UIButton buttonWithType:UIButtonTypeCustom];
    registerButton.frame=CGRectMake(50,470 , 100, 40) ;
    
    [registerButton addTarget:self action:@selector(registerButton:) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setImage:[UIImage imageNamed:@"register@2x.png"] forState:UIControlStateNormal];
    [scrollView addSubview:registerButton];
    
    
    
    checkBox=[[UIButton alloc]initWithFrame:CGRectMake(50,420, 35, 35) ];
    [checkBox addTarget:self action:@selector(toggleButton:) forControlEvents:UIControlEventTouchUpInside];
    [checkBox setImage:[UIImage imageNamed: @"blankcheckbox.png"] forState:UIControlStateNormal];
    [checkBox  setImage:[UIImage imageNamed: @"checkboxticked.png"] forState:UIControlStateHighlighted];
    [checkBox setImage:[UIImage imageNamed:@"checkboxticked.png"] forState:UIControlStateSelected];
    [scrollView addSubview:checkBox];
    
    UILabel *checkBoxlabel=[[UILabel alloc]initWithFrame:CGRectMake(95, 420,210, 35)];
    [checkBoxlabel setFont:[UIFont fontWithName:nil size:11.0]];
    [checkBoxlabel setTextColor:[UIColor blueColor]];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"I agree to terms & Condition."];
    [attributeString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[attributeString length]}];
    [checkBoxlabel setAttributedText:attributeString];
    [scrollView addSubview:checkBoxlabel];


    // Do any additional setup after loading the view.
}

-(void)toggleButton:(UIButton * )button{
    if (checkBoxSelected==0) {
        [checkBox setSelected:YES];
        checkBoxSelected=1;
    }
    else{
        [checkBox setSelected:NO];
        checkBoxSelected=0;
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField==emailField) {
        
        if(emailField.text.length > 5){
            if(![self validateEmailWithString:emailField.text])
            {
                    // user entered invalid email address
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Enter a valid email address." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                return NO;
                    //email.text=@"";
            } else {
                    //                    [self.emailDelegate sendEmailForCell:emailTextField.text];
                [emailField resignFirstResponder];
                return YES;
                
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Email address too Short" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            
            return NO;
        }
    }
    
    if (textField==nameField) {
        
        if(nameField.text.length>0 ){
            
            NSString *validtext = @"[a-zA-z]+([ '-][a-zA-Z]+)*$";
            
            NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",validtext ];
            
            if ([test evaluateWithObject:nameField.text]==YES) {
                [nameField resignFirstResponder];
            }
            else{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Name field not correct " delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
                
            }
        }
        else{
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Name field should not be empty" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            
        }
    }
    if (textField==passWordField) {
        
        
        if (passWordField.text.length<6) {
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"PassWordField should have atleast 6 Character Long" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
        else{
            [passWordField resignFirstResponder];
        }
        
    }
    
    if (textField==conFirmPassField) {
        
        if([conFirmPassField.text isEqualToString: passWordField.text]) {
            NSLog(@"password confirm");
            [conFirmPassField resignFirstResponder];
            
            NSLog(@"password confirm");
            
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"password not matching please enter properly" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            
        }
        
    }
    return  YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if( textField == phoneNoField )
    {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.barStyle = UIBarStyleBlackTranslucent;
        numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButton)],nil];
        textField.inputAccessoryView = numberToolbar;
    }
    return YES;
}

-(void)registerButton:(UIButton *)button{
    
    if ((nameField.text.length  > 0)&& (emailField.text.length > 0)&& (phoneNoField.text.length == 10)&& (conFirmPassField.text.length > 0) && (passWordField.text.length > 0) ) {
        
        
            //        registerButton.enabled = YES;
        
        if(checkBoxSelected==0){
            
                //adding
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Select the terms and condition to Ok " delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            return;
        }
        else{
                ///changing
            NSError * error=nil;
            NSURLResponse * urlReponse=nil;
            
            NSString *device_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"devicetoken"];
            
            NSString * urlStr=[NSString stringWithFormat:@"http://movyt.socialsignifier.com/index.php?method=signup&username=%@&email=%@&password=%@&country=India&device_token=%@",nameField.text,emailField.text,passWordField.text,device_token];
            
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
            
            if ([responseShow isEqualToString:@"User added successfully"]){
                
                NSLog(@"user succesfully registered");
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Success" message:@"User successfully registered" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
                
                
                [[AppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"message"]];
                [[NSUserDefaults standardUserDefaults]setObject:nameField.text forKey:@"Username" ];
                
                [[NSUserDefaults standardUserDefaults]setObject:@"yes" forKey:@"SignIn"];
                
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
        }//else
        
    }
    
    else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Fill All the Field First.." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        
    }
    
}

- (BOOL) validateEmailWithString:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
        //Keyboard becomes visible
    scrollView.frame = CGRectMake(scrollView.frame.origin.x,
                                  scrollView.frame.origin.y,
                                  scrollView.frame.size.width,
                                  scrollView.frame.size.height - 400 + 50);   //resize
    
        //    scrollView.contentOffset=CGPointMake(0,textField.frame.origin.y);
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
        //keyboard will hide
    scrollView.frame = CGRectMake(scrollView.frame.origin.x,
                                  scrollView.frame.origin.y,
                                  scrollView.frame.size.width,
                                  scrollView.frame.size.height + 400 - 50); //resize
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)doneButton
{
    if (phoneNoField.text.length!=10) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Phone Number is Invalid" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }
    else
        [phoneNoField resignFirstResponder];
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
