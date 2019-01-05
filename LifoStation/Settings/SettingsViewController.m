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
@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIView *changePasswordView;
@property (weak, nonatomic) IBOutlet UIView *contactView;
@property (weak, nonatomic) IBOutlet UIView *languageView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTap];
    // Do any additional setup after loading the view.
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
        [view showInWindow];
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
//    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x6DA3E0);
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x3A87C7);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
