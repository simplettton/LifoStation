//
//  SettingsViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/24.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import "ChooseLanguageView.h"
#import "UIView+Tap.h"
#import "UIView+TYAlertView.h"
#import "LoginViewController.h"
@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIView *changePasswordView;
@property (weak, nonatomic) IBOutlet UIView *contactView;
@property (weak, nonatomic) IBOutlet UIView *languageView;
@property (weak, nonatomic) IBOutlet UIView *logoutView;
@property (weak, nonatomic) IBOutlet UIView *aboutView;
@property (weak, nonatomic) IBOutlet UIView *alertSettingView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hospitalAndDepartmentLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view adaptScreenWidthWithType:AdaptScreenWidthTypeConstraint exceptViews:nil];
    NSString *hospital = [UserDefault objectForKey:@"Hospital"];
    NSString *name = [UserDefault objectForKey:@"PersonName"];
    NSString *department = [NSString stringWithFormat:@" %@",[UserDefault objectForKey:@"Department"]];
    self.nameLabel.text = name;
    self.hospitalAndDepartmentLabel.text = AddStr(hospital,department );
    [self addTap];
    
}
- (void)addTap {
    [self.changePasswordView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ChangePassword" sender:nil];
    }];
    [self.contactView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowContactInformation" sender:nil];
    }];
    [self.languageView addTapBlock:^(id obj) {
        ChooseLanguageView *view = [ChooseLanguageView createViewFromNib];
        [view showInWindowWithBackgoundTapDismissEnable:YES];
    }];
    [self.logoutView addTapBlock:^(id obj) {
        [self presentLogoutAlert];
    }];
    [self.alertSettingView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowAlertSetting" sender:nil];
    }];
    [self.aboutView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowAboutInformation" sender:nil];
    }];
}
- (void)presentLogoutAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"退出后不会删除任何历史数据，下次登录依然可以使用本账号。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* logoutAction = [UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [UserDefault setBool:NO forKey:@"IsLogined"];
        [UserDefault synchronize];
    
        [[[UIApplication sharedApplication].delegate window].rootViewController removeFromParentViewController];
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *vc = (LoginViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [UIView transitionWithView:[[UIApplication sharedApplication].delegate window]
                          duration:0.25
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [[UIApplication sharedApplication].delegate window].rootViewController = vc;
                        }
                        completion:nil];
        
        [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];
    }];
    
    [alert addAction:logoutAction];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x6DA3E0);
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x3A87C7);
}

@end
