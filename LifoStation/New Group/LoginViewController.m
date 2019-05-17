//
//  LoginViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/20.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "MachineTypeModel.h"
//md5加密头文件
#import<CommonCrypto/CommonDigest.h>
#import "SetNetWorkView.h"
#import "AppDelegate.h"
#define NurseLicense 1
#define AdminLicense 8
#define DoctorAndNurseLicense 3
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *remenberNameSwitch;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/SystemInfoController/GetVersion") params:@{} hasToken:YES success:^(HttpResponse *responseObject) {
        if ([responseObject.result integerValue] == 1) {
            NSDictionary *dic = responseObject.content;
            NSString *version = [dic objectForKey:@"SoftWaveFullVersion"];
            self.versionLabel.text = [NSString stringWithFormat:@"当前版本%@",version];
            
        }
    } failure:nil];
    
    //编辑框下横线
    [self setBorderWithView:self.userView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0Xbbbbbb) borderWidth:1.0];
    [self setBorderWithView:self.passwordView top:NO left:NO bottom:YES right:NO borderColor:UIColorFromHex(0XBBBBBB) borderWidth:1.0];
    
    //用户名显示
    NSString *userName = [UserDefault objectForKey:@"UserName"];
    BOOL hasRememberUserName = [UserDefault boolForKey:@"HasRememberName"];
    self.userNameTextField.text = hasRememberUserName ? userName : @"";
    
    [self.passwordTextField setSecureTextEntry:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}
#pragma mark - hide keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self hideKeyBoard];
}
- (void)hideKeyBoard {
    [self.view endEditing:YES];
}
#pragma mark - login
- (IBAction)login:(id)sender {
    
    if (self.userNameTextField.text.length == 0 || self.passwordTextField.text.length == 0) {
        [BEProgressHUD showMessage:@"用户名或密码不能为空"];
        return;
    } else if (self.passwordTextField.text.length <6) {
        [BEProgressHUD showMessage:@"密码不小于6位"];
        return;
    }
    [self showLoginIndicator];
    [self loginCheck];
}
- (void)showLoginIndicator {
    [BEProgressHUD showLoading:@"正在登录中..."];
}
- (void)loginCheck {
    [self hideKeyBoard];
    if ([self.remenberNameSwitch isOn])
    {
        [UserDefault setBool:YES forKey:@"HasRememberName"];
    }
    else
    {
        [UserDefault setBool:NO forKey:@"HasRememberName"];
    }
    [UserDefault synchronize];
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    __block UINavigationController *controller;
    NSString *userName = self.userNameTextField.text;
    NSString *pwd = self.passwordTextField.text;
    __block NSString *roleString = [[NSString alloc]init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/UserController/Login")
                                      params:@{
                                                 @"UserName":userName,
                                                 @"Pwd":[self md5:pwd]
                                             }
                                    hasToken:NO
                                     success:^(HttpResponse *responseObject) {
                                         if ([responseObject.result intValue] == 1) {
                                             NSDictionary *content = responseObject.content;
                                             
                                             NSInteger license = [[responseObject.content objectForKey:@"License"]integerValue];


                                             if (license == NurseLicense || license == DoctorAndNurseLicense) {
                                                 roleString = @"Nurse";
                                                 controller =  [mainStoryBoard instantiateViewControllerWithIdentifier:@"NurseNavigation"];
                                             } else if (license == AdminLicense) {
                                                 roleString = @"Agent";
                                                 controller =  [mainStoryBoard instantiateViewControllerWithIdentifier:@"AgentNavigation"];
                                             } else {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [BEProgressHUD showMessage:@"该账号权限无法登陆系统"];
                                                 });
                                             }
                                             NSString *token = [responseObject.content objectForKey:@"Token"];
                                             NSString *department = [responseObject.content objectForKey:@"Department"];
                                             NSString *personName = [responseObject.content objectForKey:@"PersonName"];
                                             NSString *hospital = [responseObject.content objectForKey:@"Hospital"];


                                             if (controller) {
                                                 //登录成功保存token role
                                                 [UserDefault setBool:YES forKey:@"IsLogined"];
                                                 [UserDefault setObject:roleString forKey:@"Role"];
                                                 [UserDefault setObject:token forKey:@"Token"];
                                                 
                                                 
                                                 [UserDefault setObject:hospital forKey:@"Hospital"];
                                                 [UserDefault setObject:token forKey:@"Token"];
                                                 [UserDefault setObject:personName forKey:@"PersonName"];
                                                 [UserDefault setObject:userName forKey:@"UserName"];
                                                 [UserDefault setObject:department forKey:@"Department"];
                                                 [UserDefault synchronize];
                                                 [self getMachineTypeList];
                                                 
                                                 [self performSelector:@selector(initRootViewController:) withObject:controller afterDelay:0.25];
                                             }
                                         }
                                     }
                                     failure:^(NSError *error) {
                                         [BEProgressHUD hideHUD];
                                     }];

    });

}
- (void)getMachineTypeList {
    NSMutableArray *typeList = [[NSMutableArray alloc]init];
    NSMutableDictionary *typeDic = [[NSMutableDictionary alloc]init];
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/MachineController/GetSupportMachineList")
                                  params:@{}
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result integerValue] == 1) {
                                         if ([responseObject.content count]>0) {
                                             for (NSDictionary *dic in responseObject.content) {
                                                 MachineTypeModel *machine = [[MachineTypeModel alloc]initWithDictionary:dic error:nil];
                                                 [typeDic setObject:machine.name forKey:machine.typeCode];
                                                 [typeList addObject:machine];
                                                 
                                             }
                                             [Constant sharedInstance].machineTypeList = typeList;
                                             [Constant sharedInstance].machineTypeDic = typeDic;
                                             NSDictionary *type = [typeDic copy];
                                             [UserDefault setObject:type forKey:@"MachineTypeDic"];
                                             [UserDefault synchronize];
                                             LxDBAnyVar(type);
                                         }
                                     }
                                 }
                                 failure:nil];
}
- (void)initRootViewController:(UINavigationController *)controller {
    [BEProgressHUD showLoading:@"正在登陆中"];
    //登录成功后保存账户信息
    [self saveUserInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *myDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [myDelegate.window.rootViewController removeFromParentViewController];
        [UIView transitionWithView:myDelegate.window
                          duration:0.25
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            myDelegate.window.rootViewController = controller;
                        } completion:^(BOOL finished) {
                            if (finished) {
                                [BEProgressHUD hideHUD];
                            }
                        }];
        [myDelegate.window makeKeyAndVisible];
        [BEProgressHUD hideHUD];
    });
}
- (void)saveUserInfo {
    
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
- (NSString *) md5:(NSString *) input {
    
    const char *cStr = [input UTF8String];
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5( cStr, (uint32_t)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        
        [output appendFormat:@"%02x", digest[i]];
    LxDBAnyVar(output);
    return  output;
    
}
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
