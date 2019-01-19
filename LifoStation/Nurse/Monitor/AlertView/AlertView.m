//
//  AlertView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/15.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AlertView.h"
#import "UIView+TYAlertView.h"
@implementation AlertView
- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initAll];
}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
}
#pragma mark - tableview datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    UILabel *detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 13, 382, 21)];
    detailLabel.text = @"2018/12/12 15:32 内科-23床 [光子设备1] 风扇异常";
    detailLabel.textColor = UIColorFromHex(0x787878);
    detailLabel.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:detailLabel];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
