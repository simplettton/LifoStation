//
//  FinishedTaskViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/7.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "FinishedTaskViewController.h"
#import "PopoverTreatwayController.h"
#import "UIView+Tap.h"
#import "AddLocationView.h"
#import "AddAdviceView.h"
#import "EditTaskView.h"
#import "TaskDetailView.h"
#import "DeviceSelectView.h"
#import "UIView+TYAlertView.h"
#import "TaskCell.h"
@interface FinishedTaskViewController ()<UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation FinishedTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
    // Do any additional setup after loading the view.
}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    /** 下拉刷新控件 */
    [self initTableHeaderAndFooter];
    
}
#pragma mark - refresh
-(void)initTableHeaderAndFooter{
    
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    header.stateLabel.textColor =UIColorFromHex(0xABABAB);
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    
    //    [self.tableView.mj_header beginRefreshing];
    
    //上拉加载
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
    self.tableView.mj_footer = footer;
}
- (void)refresh {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 结束刷新
        [self.tableView.mj_header endRefreshing];
    });
}
- (void)loadMore {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 结束刷新
        [self.tableView.mj_footer endRefreshing];
    });
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
    CellIdentifier = @"FinishedTaskCell";
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[TaskCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    

    [cell.treatmentButton addTarget:self action:@selector(showPopover:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
//    [cell becomeFirstResponder];
    
    [cell.locationLabel addTapBlock:^(id obj) {
        AddLocationView *view = [AddLocationView createViewFromNib];
        view.titleLabel.text = @"编辑位置";
        [view showInWindow];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dataDic = @{@"name":@"xiaoming",@"gender":@"男",@"department":@"外科"};
    TaskDetailView *view = [[TaskDetailView alloc]initWithDic:dataDic];
    [view showInWindow];
    
}

#pragma mark - Action
- (void)moreAction:(UIButton *)sender {
    UITableViewCell *cell = (UITableViewCell *)[[sender superview]superview];
    [cell becomeFirstResponder];
    UIMenuItem *edit = [[UIMenuItem alloc] initWithTitle:@"编辑信息"
                                                  action:@selector(edit:)];
    UIMenuItem *add= [[UIMenuItem alloc] initWithTitle:@"添加医嘱"
                                                    action:@selector(add:)];
    UIMenuItem *checkReport = [[UIMenuItem alloc] initWithTitle:@"查看报告" action:@selector(checkReport:)];
    [[UIMenuController sharedMenuController] setArrowDirection:UIMenuControllerArrowUp];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:edit,add,checkReport, nil]];
    [[UIMenuController sharedMenuController] setTargetRect:sender.frame inView:sender.superview];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated: YES];
}

- (void)edit:(id)sender {
    EditTaskView *view = [EditTaskView createViewFromNib];
    [view showInWindow];
}
- (void)add:(id)sender {
    AddAdviceView *view = [AddAdviceView createViewFromNib];
    [view showInWindow];
}
- (void)checkReport:(id)sender {
    [self performSegueWithIdentifier:@"TaskToReport" sender:nil];
}
#pragma mark - 第一响应者 + UIMenuController
/**
 * 说明控制器可以成为第一响应者
 * 因为控制器是因为比较特殊的对象,它找控制器的方法,不找label的方法
 */
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Popover
-(void)showPopover:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ShowFinishedTreatment" sender:sender];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowFinishedTreatment"]) {
        PopoverTreatwayController *destination = (PopoverTreatwayController *)segue.destinationViewController;
        UIPopoverPresentationController *popover = destination.popoverPresentationController;
        popover.delegate = self;
        
        UIButton *button = sender;
        popover.sourceView = button;
        popover.sourceRect = button.bounds;
        //        }
    }
}
@end
