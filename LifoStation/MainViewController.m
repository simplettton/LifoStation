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
@property (weak, nonatomic) IBOutlet UIView *videoView;


@property (weak, nonatomic) IBOutlet UIView *treatmentRecordView;


@property (weak, nonatomic) IBOutlet UITextField *x;
@property (weak, nonatomic) IBOutlet UITextField *y;
@property (weak, nonatomic) IBOutlet UITextField *w;
@property (weak, nonatomic) IBOutlet UITextField *h;

@property (weak, nonatomic) IBOutlet UILabel *centerx;
@property (weak, nonatomic) IBOutlet UILabel *centery;
@property (weak, nonatomic) IBOutlet UILabel *ewidth;
@property (weak, nonatomic) IBOutlet UILabel *height;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTap];
}
- (IBAction)calculate:(id)sender {
    
    _centerx.text = [NSString stringWithFormat:@"centerx %f",((_x.text.floatValue +0.5 * _w.text.floatValue) / 181.5)];
    
    _centery.text = [NSString stringWithFormat:@"centery %f",((_y.text.floatValue +0.5 * _h.text.floatValue) / 249)];
    
    _ewidth.text = [NSString stringWithFormat:@"equalwidth: %f",(_w.text.floatValue  / 363)];
    
    _height.text = [NSString stringWithFormat:@"equalheight: %f",(_h.text.floatValue  / 498)];
    NSLog(@"%@",[NSString stringWithFormat:@"%@%@%@%@",_centerx.text,_centery.text,_ewidth.text,_height.text]);
    _x.text = @"";
    _y.text = @"";
    _w.text = @"";
    _h.text = @"";
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
    [self.deviceMonitorView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowDeviceMonitor" sender:nil];
    }];
    [self.videoView addTapBlock:^(id obj) {
        [self performSegueWithIdentifier:@"ShowVideo" sender:nil];
    }];
    
}

@end
