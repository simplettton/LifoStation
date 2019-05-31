//
//  WaitingTaskViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/7.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "WaitingTaskViewController.h"
#import "PopoverTreatwayController.h"

#import "AddLocationView.h"
#import "TaskDetailView.h"
#import "UIView+Tap.h"
#import "DeviceSelectView.h"
#import "UIView+TYAlertView.h"
#import "TaskCell.h"

#import "TaskParentViewController.h"
#import "TaskModel.h"
/** listone参数解析 */
#import "TaskParameterModel.h"
@interface WaitingTaskViewController ()<UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate>
@property (nonatomic, strong) BaseSearchBar *searchBar;
@property (nonatomic, strong) UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noDataView;

@end

@implementation WaitingTaskViewController
{
    int page;
    int totalPage;  //总页数
    BOOL isRefreshing; //是否正在下拉刷新或者上拉加载
    BOOL isFilteredList; //是否筛选
    NSMutableDictionary *filterparam;//筛选关键字
    NSMutableArray *datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.view adaptScreenWidthWithType:AdaptScreenWidthTypeConstraint exceptViews:nil];
    [self initAll];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x3A87C7);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.estimatedRowHeight = 56;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    TaskParentViewController *parentViewController = (TaskParentViewController *)self.parentViewController;
    self.searchBar = parentViewController.searchBar;
    self.searchButton = parentViewController.searchButton;
    self.searchBar.delegate = self;
    [self.searchButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [self initTableHeaderAndFooter];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideKeyBoard];
}
- (void)hideKeyBoard {
    
    [self.view endEditing:YES];
    [self.tableView endEditing:YES];
    [self.searchBar resignFirstResponder];
}
#pragma mark - refresh
-(void)initTableHeaderAndFooter {
    
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    header.stateLabel.textColor =UIColorFromHex(0xABABAB);
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    [self refresh];
    
    //上拉加载
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
    self.tableView.mj_footer = footer;
}
- (void)refresh {
     [self.searchBar resignFirstResponder];
    if ([self.searchBar.text length]>0) {
        isFilteredList = YES;
        NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]initWithCapacity:20];
        [paramDic setObject:self.searchBar.text forKey:@"Key"];
        filterparam = paramDic;
        [self refreshDataWithHeader:YES];
    }else{
        isFilteredList = NO;
        [filterparam removeAllObjects];
        [self refreshDataWithHeader:YES];
    }
}
- (void)loadMore {
    [self.searchBar resignFirstResponder];
    [self refreshDataWithHeader:NO];
}
- (void)endRefresh {
    if (page == 0) {
        [self.tableView.mj_header endRefreshing];
    }
    [self.tableView.mj_footer endRefreshing];
}
- (void)refreshDataWithHeader:(BOOL)isPullingDown {
    NSMutableDictionary *mutableParams = [[NSMutableDictionary alloc]init];
    if (isFilteredList) {
        mutableParams = filterparam;
    }
    [mutableParams setObject:@2 forKey:@"State"];
    
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/TaskController/List?Action=Count")
                                  params:mutableParams
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result intValue] == 1) {
                                         NSNumber *count = responseObject.content;
                                         totalPage = ([count intValue]+10-1)/10;
                                         
                                         if (totalPage <= 1) {
                                             self.tableView.mj_footer.hidden = YES;
                                         }else{
                                             self.tableView.mj_footer.hidden = NO;
                                         }
                                         
                                         if([count intValue] > 0)
                                         {
                                             [self getNetworkDataWithHeader:isPullingDown];
                                             self.noDataView.hidden = YES;
                                         } else {
                                             [datas removeAllObjects];
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.tableView reloadData];
                                             });
                                             self.noDataView.hidden = NO;
                                             
                                         }
                                         
                                     }else{
                                         if(isFilteredList){
                                             if ([self.searchBar.text length]>0) {
                                                 self.searchBar.text = @"";
                                             }
                                         }
                                     }
                                     
                                 } failure:nil];
    
}
- (void)getNetworkDataWithHeader:(BOOL)isPullingDown {
    if (isPullingDown) {
        page = 0;
    } else {
        page ++;
    }
    NSDictionary *params = [[NSDictionary alloc]init];
    if (isFilteredList) {
        [filterparam setObject:[NSNumber numberWithInt:page] forKey:@"Page"];
        params = (NSDictionary *)filterparam;
    } else {
        params = @{
                   @"Page":[NSNumber numberWithInt:page],
                   @"State":@2
                   };
    }
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/TaskController/List?Action=List")
                                  params:params
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     [self endRefresh];
                                     isRefreshing = NO;
                                     if (page == 0) {
                                         [datas removeAllObjects];
                                     }
                                     
                                     if (isRefreshing) {
                                         if (page >= totalPage) {
                                             [self endRefresh];
                                         }
                                         return;
                                     }
                                     isRefreshing = YES;
                                     
                                     if (page >= totalPage) {
                                         [self endRefresh];
                                         [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                         return;
                                     }
                                     
                                     if ([responseObject.result intValue] == 1) {
                                         NSArray *content = responseObject.content;
                                        
                                         if (content) {
                                             for (NSDictionary *dic in content) {
                                                 NSError *error;
                                                 TaskModel *task = [[TaskModel alloc]initWithDictionary:dic error:&error];

                                                 [datas addObject:task];
                                                 NSInteger index = [datas indexOfObject:task];
                                                 
                                                 [self getParamList:task atIndex:index];
                                             }
                                             if (totalPage > 1) {
                                                 //下拉多刷新一页
                                                 if (isPullingDown) {
                                                     [self getNetworkDataWithHeader:NO];
                                                 }
                                             }
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.tableView reloadData];
                                             });
                                         }
                                     }
                                 } failure:nil];
}
- (void)getParamList :(TaskModel *)task atIndex:(NSInteger)index{
    if (task.solution.uuid) {
        [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/SolutionController/ListOne") params:@{@"SolutionId":task.solution.uuid} hasToken:YES success:^(HttpResponse *responseObject) {
            if ([responseObject.result integerValue] == 1) {
                NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
                [paramArray addObject:@{@"showName":@"方案名称",@"value":[NSString stringWithFormat:@"%@",responseObject.content[@"Name"]]}];
                [paramArray addObject:@{@"showName":@"治疗模式",@"value":[NSString stringWithFormat:@"%@",responseObject.content[@"MainModeName"]]}];

                
                NSArray *array = responseObject.content[@"LsEdit"];
                if ([array count]>0) {
                    for (NSDictionary *dataDic in array) {
                        TaskParameterModel *taskParameter = [[TaskParameterModel alloc]initWithDictionary:dataDic error:nil];
                        if (![taskParameter.showName isEqualToString:@"计时方式"]) {
                            [paramArray addObject:[taskParameter getParamDictionary]];
                        }
                    }
                }
                task.solution.paramList = paramArray;
                [datas replaceObjectAtIndex:index withObject:task];
            }
        } failure:nil];
        
    }

}
#pragma mark - SearchBar delegate
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger proposedNewLength = searchBar.text.length - range.length + text.length;
    if (proposedNewLength > 30) {
        return NO;//限制长度
    }
    return YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length == 0) {
        [self refresh];
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self search:nil];
}

- (IBAction)search:(id)sender {
    [self refresh];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self search:nil];
    return YES;
}
#pragma mark - tableview delegate

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [datas count];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* CellIdentifier;
    CellIdentifier = @"UnfinishedTaskCell";
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[TaskCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    TaskModel *task = datas[indexPath.row];
    cell.personNameLabel.text = task.patient.personName;
    cell.machineTypeLabel.text = task.solution.machineTypeName;
    if ([task.patient.treatAddress length] > 0) {
        cell.locationLabel.text = task.patient.treatAddress;
        cell.locationImageView.hidden = YES;
        cell.locationLabel.hidden = NO;
        [cell.locationLabel addTapBlock:^(id obj) {
            AddLocationView *view = [[AddLocationView alloc]initWithDic:@{@"name":task.patient.treatAddress} return:^(NSString *name) {
                [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/PatientController/Update")
                                              params:@{@"PatientId":task.patient.uuid,@"TreatAddress":name}
                                            hasToken:YES
                                             success:^(HttpResponse *responseObject) {
                                                 task.patient.treatAddress = name;
                                                 [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                             }
                                             failure:nil];
            }];
            view.titleLabel.text = @"编辑治疗位置";
            [view showInWindowWithBackgoundTapDismissEnable:YES];
        }];
    } else {
        cell.locationImageView.hidden = NO;
        cell.locationLabel.hidden = YES;
        [cell.locationImageView addTapBlock:^(id obj) {
            AddLocationView *view = [[AddLocationView alloc]initWithDic:nil return:^(NSString *name) {
                [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/PatientController/Update")
                                              params:@{@"PatientId":task.patient.uuid,@"TreatAddress":name}
                                            hasToken:YES
                                             success:^(HttpResponse *responseObject) {
                                                 task.patient.treatAddress = name;
                                                 [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                             }
                                             failure:nil];
            }];
            
            view.titleLabel.text = @"添加治疗位置";
            [view showInWindowWithBackgoundTapDismissEnable:YES];
        }];
    }
    //空气波和负压持续治疗时间特殊处理
    if ([task.solution.treatTime isEqualToString:@"601"] || [task.solution.treatTime isEqualToString:@"0"]) {
        [cell.treatmentButton setTitle:@"治疗时间：持续治疗" forState:UIControlStateNormal];
    } else {
        [cell.treatmentButton setTitle:[NSString stringWithFormat:@"治疗时间：%@min",task.solution.treatTime] forState:UIControlStateNormal];
    }
    [cell.sendButton addTarget:self action:@selector(showDeviceSelectView:) forControlEvents:UIControlEventTouchUpInside];
    [cell.treatmentButton addTarget:self action:@selector(showPopover:) forControlEvents:UIControlEventTouchUpInside];


    return cell;
}
- (void)showDeviceSelectView:(id)sender {
    TaskCell *cell = (TaskCell *)[[sender superview]superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TaskModel *task = datas[indexPath.row];
    DeviceSelectView *view = [[DeviceSelectView alloc]initWithModel:task return:^(NSDictionary *dic) {
        [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/TaskController/SolutionDownload") params:dic hasToken:YES success:^(HttpResponse *responseObject) {
            if ([responseObject.result integerValue] == 1) {
                [BEProgressHUD showMessage:@"已绑定机器下发参数"];
                [self refresh];
            }
        } failure:nil];
    }];
    [view showInWindowWithBackgoundTapDismissEnable:YES];

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TaskModel *task = datas[indexPath.row];
    TaskDetailView *view = [[TaskDetailView alloc]initWithModel:task];
    [view showInWindowWithBackgoundTapDismissEnable:YES];
    
}
#pragma mark - UITableView Edit
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;

}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *cancelAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"取消", @"") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"此操作不可撤销，确认取消任务？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            TaskModel *task = datas[indexPath.row];
            [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/TaskController/Cancel")
                                          params:@{@"TaskId":task.uuid}
                                        hasToken:YES
                                         success:^(HttpResponse *responseObject) {
                                             if ([responseObject.result intValue] == 1) {
                                                 [BEProgressHUD showMessage:@"已取消任务"];
                                                 [self refresh];
                                             }
                                         }
                                         failure:nil];
        }];
        
        [alert addAction:confirmAction];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {}];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];

        [tableView setEditing:NO animated:YES];

    }];
    cancelAction.backgroundColor = UIColorFromHex(0x08BF91);
    return @[cancelAction];
}
#pragma mark - Popover
-(void)showPopover:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ShowWaitingTreatment" sender:sender];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowWaitingTreatment"]) {
        PopoverTreatwayController *destination = (PopoverTreatwayController *)segue.destinationViewController;
        UIPopoverPresentationController *popover = destination.popoverPresentationController;
        popover.delegate = self;
        
        //        if ([datas count]>0) {
        //获取某个cell的数据
        UIView *contentView = [(UIView *)sender superview];
        
        TaskCell *cell = (TaskCell*)[contentView superview];
        
        NSIndexPath *index = [self.tableView indexPathForCell:cell];
        
        TaskModel *task = [datas objectAtIndex:index.row];

        destination.paramList = task.solution.paramList;

        UIButton *button = sender;
        popover.sourceView = button;
        popover.sourceRect = button.bounds;
        //        }
    }
}
-(NSString *)changeSecondToTimeString:(NSString *)second{
    
    NSInteger minute = [second integerValue]/60;
    
    if (![second isEqualToString:@"0"]) {
        if (minute < 1) {
            minute = 1;
        }
    }
    
    NSString *timeString = [NSString stringWithFormat:@"%ld分钟",(long)minute];
    return timeString;
}
@end
