//
//  AboutViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/5/15.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/SystemInfoController/GetVersion") params:@{} hasToken:YES success:^(HttpResponse *responseObject) {
        if ([responseObject.result integerValue] == 1) {
            NSDictionary *dic = responseObject.content;
            NSString *version = [dic objectForKey:@"SoftWaveFullVersion"];
            self.versionLabel.text = version;
            
        }
    } failure:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
@end
