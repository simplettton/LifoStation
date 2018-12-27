//
//  LoginViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/20.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "SetNetWorkView.h"
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *remenberNameSwitch;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //编辑框下横线
    [self setBorderWithView:self.userView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0Xbbbbbb) borderWidth:1.0];
    [self setBorderWithView:self.passwordView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0XBBBBBB) borderWidth:1.0];
    
    //用户名显示
    NSString *userName = [UserDefault objectForKey:@"UserName"];
    BOOL hasRememberUserName = [UserDefault boolForKey:@"HasRememberName"];
    self.userNameTextField.text = hasRememberUserName ? userName : @"";
    
    [self.passwordTextField setSecureTextEntry:YES];
}
#pragma mark - hide keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self hideKeyBoard];
}
-(void)hideKeyBoard {
    [self.view endEditing:YES];
}
#pragma mark - login
- (IBAction)login:(id)sender {
    
    if (self.userNameTextField.text.length == 0 || self.passwordTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"用户名或密码不能为空"];
        return;
    }else if(self.passwordTextField.text.length <6){
        [SVProgressHUD showErrorWithStatus:@"密码不小于6位"];
        return;
    }
    [self showLoginIndicator];
    [self loginCheck];
}
-(void)showLoginIndicator {
    [BEProgressHUD showLoading:@"正在登录中..."];
}
-(void)loginCheck {
    [self hideKeyBoard];
    [UserDefault setBool:[self.remenberNameSwitch isOn] forKey:@"HasRememberName"];
    [UserDefault synchronize];
}
#pragma mark - Network configure
- (IBAction)setNetwork:(id)sender {
    [self hideKeyBoard];
    [SetNetWorkView alertControllerAboveIn:self return:^(NSString *ip) {
//        [UserDefault setObject:ip forKey:@"HTTPServerURLString"];
//        [UserDefault synchronize];
    }];
}

#pragma mark - Private method

- (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width {
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height - width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width - width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}

@end
