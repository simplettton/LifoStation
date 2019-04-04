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
#import "ReportTableViewController.h"

#import "TaskParentViewController.h"
#import "TaskModel.h"
@interface FinishedTaskViewController ()<UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate,UISearchBarDelegate>
@property (nonatomic, strong) BaseSearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@end

@implementation FinishedTaskViewController
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
    [self initAll];
}

- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.estimatedRowHeight = 56;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    TaskParentViewController *parentViewController = (TaskParentViewController *)self.parentViewController;
    parentViewController.searchBar.delegate = self;
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    self.searchBar = parentViewController.searchBar;
    [self initTableHeaderAndFooter];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x3A87C7);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
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
        [self search:nil];
    }else{
        isFilteredList = NO;
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
    [mutableParams setObject:@4 forKey:@"State"];
    
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
                                             self.tableView.tableHeaderView.hidden = NO;
                                             self.noDataView.hidden = YES;
                                             [self getNetworkDataWithHeader:isPullingDown];
                                            
                                         }else{
                                             [datas removeAllObjects];
                                             self.tableView.tableHeaderView.hidden = YES;
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.tableView reloadData];
                                             });
                                             self.noDataView.hidden = NO;
                                             
                                         }
                                         
                                     } else {
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
                   @"State":@4
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
                                             LxDBAnyVar(content);
                                             for (NSDictionary *dic in content) {
                                                 TaskModel *task = [[TaskModel alloc]initWithDictionary:dic error:nil];
                                                 [datas addObject:task];
                                                 NSInteger index = [datas indexOfObject:task];
                                                 
                                                 [self getParamList:task atIndex:index];
                                             }
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.tableView reloadData];
                                             });
                                         }
                                     }
                                     
                                 } failure:nil];
    
}
- (void)getParamList :(TaskModel *)task atIndex:(NSInteger)index {
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/SolutionController/ListOne") params:@{@"SolutionId":task.solution.uuid} hasToken:YES success:^(HttpResponse *responseObject) {
        if ([responseObject.result integerValue] == 1) {
            NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
            [paramArray addObject:@{@"showName":@"治疗模式",@"value":[NSString stringWithFormat:@"%@",responseObject.content[@"MainModeName"]]}];
            [paramArray addObject:@{@"showName":@"治疗时间",@"value":[NSString stringWithFormat:@"%@分钟",responseObject.content[@"TreatTime"]]}];
            
            NSArray *array = responseObject.content[@"LsEdit"];
            if ([array count]>0) {
                for (NSDictionary *dataDic in array) {
                    [paramArray addObject:@{@"showName":dataDic[@"ShowName"],@"value":[NSString stringWithFormat:@"%@%@",dataDic[@"DefaultValue"],dataDic[@"Unit"]]}];
                }
            }
            task.solution.paramList = paramArray;
            [datas replaceObjectAtIndex:index withObject:task];
        }
    } failure:nil];
    
}
#pragma mark - SearchBar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length == 0) {
        [self refresh];
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self search:nil];
}
- (IBAction)search:(id)sender {
    if ([self.searchBar.text length] > 0) {
        isFilteredList = YES;
        NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]initWithCapacity:20];
        [paramDic setObject:self.searchBar.text forKey:@"Key"];
        filterparam = paramDic;
        [self refreshDataWithHeader:YES];
    } else {
        isFilteredList = NO;
        [self.tableView.mj_header beginRefreshing];
    }
    
}
#pragma mark - tableview delegate
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [datas count];
//    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        return UITableViewAutomaticDimension;
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
    

    if ([datas count]>0) {
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
                view.titleLabel.text = @"编辑位置";
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
                
                view.titleLabel.text = @"添加位置";
                [view showInWindowWithBackgoundTapDismissEnable:YES];
            }];
        }
        cell.finishDateLabel.text = [self stringFromTimeIntervalString:task.finishTime dateFormat:@"yyyy-MM-dd"];
        [cell.treatmentButton setTitle:[NSString stringWithFormat:@"治疗时间：%@分钟",task.solution.treatTime] forState:UIControlStateNormal];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TaskModel *task = datas[indexPath.row];

    TaskDetailView *view = [[TaskDetailView alloc]initWithModel:task];
    [view showInWindowWithBackgoundTapDismissEnable:YES];
    
}

#pragma mark - Action
- (void)moreAction:(UIButton *)sender {
    TaskCell *cell = (TaskCell *)[[sender superview]superview];
    self.selectedIndex = [self.tableView indexPathForCell:cell].row;
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
    TaskModel *task = datas[self.selectedIndex];
    EditTaskView *view = [[EditTaskView alloc]initWithDic:@{} return:^(NSString *patientId) {
        LxDBAnyVar(patientId);
        [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/TaskController/ChangePatient") params:@{@"TaskId":task.uuid,@"PatientId":patientId} hasToken:YES success:^(HttpResponse *responseObject) {
            if ([responseObject.result integerValue] == 1) {
                [BEProgressHUD showMessage:@"已完成编辑信息"];
                [self refresh];
            }
        } failure:nil];
    }] ;
    [view showInWindowWithBackgoundTapDismissEnable:YES];
}
- (void)add:(id)sender {
    TaskModel *task = datas[self.selectedIndex];
    AddAdviceView *view = [[AddAdviceView alloc]initWithContent:task.suggest return:^(NSString *newAdvice) {
        [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/TaskController/AddSuggest")
                                      params:@{@"TaskId":task.uuid,
                                               @"Suggest":newAdvice
                                               }
                                    hasToken:YES
                                     success:^(HttpResponse *responseObject) {
                                         if ([responseObject.result intValue] == 1) {
                                             [BEProgressHUD showMessage:@"已添加医嘱"];
                                             [self refresh];
                                         }
                                     }
                                     failure:nil];
    }] ;
    [view showInWindowWithBackgoundTapDismissEnable:YES];
}
- (void)checkReport:(id)sender {
    TaskModel *task = datas[self.selectedIndex];
    [self performSegueWithIdentifier:@"TaskToReport" sender:task.uuid];
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
        UIView *contentView = [(UIView *)sender superview];
        TaskCell *cell = (TaskCell*)[contentView superview];
        NSIndexPath *index = [self.tableView indexPathForCell:cell];
        TaskModel *task = [datas objectAtIndex:index.row];
        destination.paramList = task.solution.paramList;
        UIButton *button = sender;
        popover.sourceView = button;
        popover.sourceRect = button.bounds;
    } else if ([segue.identifier isEqualToString:@"TaskToReport"]) {
        ReportTableViewController *vc = (ReportTableViewController *)segue.destinationViewController;
        vc.taskId = sender;
    }
}
#pragma mark - Private Method
//时间戳字符串转化为日期或时间
- (NSString *)stringFromTimeIntervalString:(NSString *)timeString dateFormat:(NSString*)dateFormat
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone: [NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateFormat];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}
@end
