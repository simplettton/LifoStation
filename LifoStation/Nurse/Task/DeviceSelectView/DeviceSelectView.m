//
//  DeviceSelectView.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/27.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DeviceSelectView.h"
#import "UIView+Tap.h"
#import "UIView+TYAlertView.h"
#import "DeviceItemCell.h"
@interface DeviceSelectView()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger selectedMachineType;
@property (weak, nonatomic) IBOutlet UIView *offlineLine;
@property (weak, nonatomic) IBOutlet UIView *onlineLine;
@property (weak, nonatomic) IBOutlet UIView *offlineView;
@property (weak, nonatomic) IBOutlet UIView *onlineView;
@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *offlineLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *hiddentitles;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@end
@implementation DeviceSelectView

- (IBAction)cancelAction:(id)sender {
    [self hideView];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self initAll];
}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    //searchbar style
    self.searchBar.backgroundImage = [[UIImage alloc]init];//去除边框线
    self.searchBar.tintColor = UIColorFromHex(0x5E97FE);//出现光标
    UITextField * searchField = [_searchBar valueForKey:@"_searchField"];
    [searchField setValue:[UIFont systemFontOfSize:15 weight:UIFontWeightLight] forKeyPath:@"_placeholderLabel.font"];
    [self.onlineView addTapBlock:^(id obj) {
        self.selectedMachineType = online;
        self.onlineLabel.textColor = UIColorFromHex(0x1890FF);
        self.onlineLine.hidden = NO;
        self.offlineLabel.textColor = UIColorFromHex(0x616161);
        self.offlineLine.hidden= YES;
        [self.tableView reloadData];
    }];
    
    [self.offlineView addTapBlock:^(id obj) {
        self.selectedMachineType = offline;
        self.offlineLabel.textColor = UIColorFromHex(0x1890FF);
        self.offlineLine.hidden = NO;
        self.onlineLabel.textColor = UIColorFromHex(0x616161);
        self.onlineLine.hidden= YES;
        [self.tableView reloadData];
    }];
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
    DeviceItemCell *cell = [[NSBundle mainBundle]loadNibNamed:@"DeviceSelectView" owner:self options:nil].lastObject;
    
    
    //离线隐藏
    cell.statusLabel.hidden = (self.selectedMachineType == offline);
    cell.usageLabel.hidden = (self.selectedMachineType == offline);
    cell.leftTimeLabel.hidden = (self.selectedMachineType == offline);
    cell.selectionImageView.hidden = (self.selectedMachineType == offline);
    cell.bellButton.hidden = (self.selectedMachineType == offline);
    for (UILabel *title in self.hiddentitles) {
        title.hidden = (self.selectedMachineType == offline);
    }
    self.downloadButton.hidden = (self.selectedMachineType == offline);
    if (self.selectedMachineType == online) {
        cell.selectionImageView.hidden = indexPath.row == self.selectedIndex? NO:YES;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
    [tableView reloadData];
}

@end
