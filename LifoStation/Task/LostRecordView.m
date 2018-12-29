//
//  LostRecordView.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/28.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "LostRecordView.h"
#import "UIView+TYAlertView.h"
#import "RecordItemCell.h"
@interface LostRecordView()
@property(assign, nonatomic) NSInteger selectedIndex;
@end
@implementation LostRecordView
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
    return 60;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecordItemCell *cell = [[NSBundle mainBundle]loadNibNamed:@"LostRecordView" owner:self options:nil].lastObject;
    if (indexPath.row == self.selectedIndex) {
        cell.selectionImageView.hidden = NO;
    }
    cell.selectionImageView.hidden = (indexPath.row == self.selectedIndex? NO :YES);
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
    [self.tableView reloadData];
}
@end
