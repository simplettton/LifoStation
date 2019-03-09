//
//  ProcessingTaskViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/7.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ProcessingTaskViewController.h"
#import "PopoverTreatwayController.h"
#import "AddLocationView.h"
#import "TaskDetailView.h"
#import "UIView+Tap.h"
#import "UIView+TYAlertView.h"
#import "EditTaskView.h"
#import "TaskCell.h"
@interface ProcessingTaskViewController ()<UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ProcessingTaskViewController

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

    return 56;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* CellIdentifier;
    CellIdentifier = @"ProcessingTaskCell";
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[TaskCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.treatmentButton addTarget:self action:@selector(showPopover:) forControlEvents:UIControlEventTouchUpInside];
    [cell.moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.locationImageView addTapBlock:^(id obj) {
        AddLocationView *view = [AddLocationView createViewFromNib];
        view.titleLabel.text = @"添加位置";
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
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *edit = [[UIMenuItem alloc] initWithTitle:@"修改"
                                                  action:@selector(edit:)];
    UIMenuItem *finish = [[UIMenuItem alloc] initWithTitle:@"完成"
                                                  action:@selector(finish:)];
    UIMenuItem *cancel = [[UIMenuItem alloc] initWithTitle:@"取消" action:@selector(cancel:)];
    [menu setArrowDirection:UIMenuControllerArrowUp];
    [menu setMenuItems:[NSArray arrayWithObjects:edit,finish,cancel, nil]];
    [menu setTargetRect:sender.frame inView:sender.superview];
    [menu setMenuVisible:YES animated: YES];
}

- (void)edit:(id)sender {
    EditTaskView *view = [EditTaskView createViewFromNib];
    [view showInWindow];
}

- (void)finish:(id)sender {

        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"此操作不可撤销，确认完成任务？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:confirmAction];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {}];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];

}
- (void)cancel:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"此操作不可撤销，确认取消任务？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:confirmAction];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
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

///**
// * 通过这个方法告诉UIMenuController它内部应该显示什么内容
// * 返回YES，就代表支持action这个操作
// */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    //打印, 将一个方法转换成字符串 你就会看到许多方法
    NSLog(@"%@",NSStringFromSelector(action));

    if (action == @selector(edit:)
        || action == @selector(finish:)
        || action == @selector(cancel:)) {
        return YES;
    }

    return NO;
}
//
////监听事情需要对应的方法 冒号之后传入的是UIMenuController
//- (void)cut:(UIMenuController *)menu
//{
//    NSLog(@"%s %@", __func__, menu);
//}
//
//- (void)copy:(UIMenuController *)menu
//{
//    NSLog(@"%s %@", __func__, menu);
//}
//
//- (void)paste:(UIMenuController *)menu
//{
//    NSLog(@"%s %@", __func__, menu);
//}

#pragma mark - Popover
-(void)showPopover:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ShowProcessingTreatment" sender:sender];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowProcessingTreatment"]) {
        PopoverTreatwayController *destination = (PopoverTreatwayController *)segue.destinationViewController;
        UIPopoverPresentationController *popover = destination.popoverPresentationController;
        popover.delegate = self;
        
        //        if ([datas count]>0) {
        //获取某个cell的数据
//        UIView *contentView = [(UIView *)sender superview];
//
//        TaskCell *cell = (TaskCell*)[contentView superview];
        
//        NSIndexPath* index = [self.tableView indexPathForCell:cell];
        
        //            TaskModel *task = [datas objectAtIndex:index.row];
        //
        //            destination.treatParamDic = task.treatParam;
        //            destination.treatmentScheduleName = task.treatmentScheduleName;
        UIButton *button = sender;
        popover.sourceView = button;
        popover.sourceRect = button.bounds;
        //        }
    }
}
@end
