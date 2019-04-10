//
//  AlertView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/15.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AlertView.h"
#import "UIView+TYAlertView.h"
@interface AlertView()

@end
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
- (instancetype)initWithData:(NSMutableArray *)alertArray return:(returnStringBlock)returnEvent {
    if (self = [super init]) {
        AlertView *view = [AlertView createViewFromNib];
        view.returnEvent = returnEvent;
        view.dataArray = alertArray;
        return view;
    }
    return self;
}
#pragma mark - tableview datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
//    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }

    cell.textLabel.text = _dataArray[indexPath.row][@"error"];

    cell.textLabel.textColor = UIColorFromHex(0x787878);
    cell.textLabel.font = [UIFont systemFontOfSize:16];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *cpuid = _dataArray[indexPath.row][@"cpuid"];
    self.returnEvent(cpuid);
    [self hideView];
}
@end
