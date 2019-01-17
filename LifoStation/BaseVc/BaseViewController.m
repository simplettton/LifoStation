//
//  BaseViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/8.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = backButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
