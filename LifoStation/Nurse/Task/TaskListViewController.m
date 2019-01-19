//
//  TaskListViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/26.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TaskListViewController.h"
#import "TaskDetailView.h"
#import "DeviceSelectView.h"
#import "LostRecordView.h"
#import "TaskCell.h"
#import "UIView+TYAlertView.h"
#import <Masonry/Masonry.h>
@interface TaskListViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *titleOne;
@property (weak, nonatomic) IBOutlet UILabel *titleTwo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *taillingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastBeforeContraint;

@property (weak, nonatomic) IBOutlet UILabel *titleThree;
@property (weak, nonatomic) IBOutlet UILabel *titleFour;
@property (weak, nonatomic) IBOutlet UILabel *titleFive;
@property (weak, nonatomic) IBOutlet UILabel *titleSix;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (nonatomic, assign) int taskTag;
@end

@implementation TaskListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
    // Do any additional setup after loading the view.
}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.taskTag = UnfinishedTaskList;

}
#pragma mark - segmented control action

- (IBAction)segmentedControlAction:(UISegmentedControl *)sender {
    NSInteger index = sender.selectedSegmentIndex;
    switch (index) {
        case 0:
        {
            self.taskTag = UnfinishedTaskList;
            self.titleFour.hidden = NO;
//            [self.titleSix mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.trailing.equalTo(self.titleView.mas_trailing).offset(-294);
//
//            }];
            self.taillingConstraint.constant = 163;
            self.lastBeforeContraint.constant = 60;
        }
            break;
        case 1:
        {
            self.taskTag = FinishedTaskList;
            self.titleFour.hidden = YES;
//            [self.titleSix mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.trailing.equalTo(self.titleView.mas_trailing).offset(-294-77);
//            }];
            self.taillingConstraint.constant = 163+58;
             self.lastBeforeContraint.constant = 60+15;
        }
            break;
        default:
            break;
    }
    //更新约束
//    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
//    }];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    return UITableViewAutomaticDimension;
    return 56;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* CellIdentifier;
    if (self.taskTag == UnfinishedTaskList) {
        CellIdentifier = @"UnfinishedTaskCell";
    } else {
        CellIdentifier = @"FinishedTaskCell";
    }
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[TaskCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [cell.sendButton addTarget:self action:@selector(showDeviceSelectView:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (void)showDeviceSelectView:(id)sender {
    DeviceSelectView *view = [DeviceSelectView createViewFromNib];
    [view showInWindow];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dataDic = @{@"name":@"xiaoming",@"gender":@"男",@"department":@"外科"};
    TaskDetailView *view = [[TaskDetailView alloc]initWithDic:dataDic];
    [view showInWindow];
    
}
#pragma mark - UITableView Edit
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.dataArray removeObjectAtIndex:indexPath.row];
//    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.taskTag == UnfinishedTaskList) {
        return YES;
    } else {
        return NO;
    }
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *finishAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"完成", @"") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [tableView setEditing:NO animated:YES];  // 这句很重要，退出编辑模式，隐藏左滑菜单
        LostRecordView *view = [LostRecordView createViewFromNib];
        [view showInWindow];
    }];
    finishAction.backgroundColor = UIColorFromHex(0x08BF91);
    return @[finishAction];
}


@end