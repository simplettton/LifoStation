//
//  ChooseLanguageView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/2.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ChooseLanguageView.h"
#import "UIView+TYAlertView.h"
#import "LanguageCell.h"
@interface ChooseLanguageView()<UITableViewDelegate,UITableViewDataSource>

@property(assign, nonatomic) NSInteger selectedIndex;
@end
@implementation ChooseLanguageView
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initAll];
}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.selectedIndex = 1;
}
- (IBAction)cancel:(id)sender {
    [self hideView];
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
    LanguageCell *cell = [[NSBundle mainBundle]loadNibNamed:@"ChooseLanguageView" owner:self options:nil].lastObject;

    if (indexPath.row == 0) {
        cell.titleLabel.text = @"简体中文";
    } else {
        cell.titleLabel.text = @"English";
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectionImageView.hidden = (indexPath.row == self.selectedIndex? NO :YES);

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
    [tableView reloadData];
}

@end
