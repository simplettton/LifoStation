//
//  MainViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/24.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MainViewController.h"
#import "UIView+Tap.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIView *deviceManagementView;
@property (weak, nonatomic) IBOutlet UIView *demonstrationView;
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UIView *deviceMonitorView;
@property (weak, nonatomic) IBOutlet UIView *taskListView;
@property (weak, nonatomic) IBOutlet UIView *patientListView;

@property (weak, nonatomic) IBOutlet UIView *treatmentRecordView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTap];
}
#pragma mark - hide navigation bar
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)addTap {
    [self.settingsView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowSettings" sender:nil];
    }];
    [self.patientListView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowPatientList" sender:nil];
    }];
    [self.taskListView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowTaskList" sender:nil];
    }];
    [self.deviceManagementView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowDeviceList" sender:nil];
    }];
    [self.treatmentRecordView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowRecordList" sender:nil];
    }];
    
}

@end