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

#import "TaskParentViewController.h"
#import "TaskModel.h"
#import "TaskParameterModel.h"
@interface ProcessingTaskViewController ()<UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate,UISearchBarDelegate>
@property (nonatomic, strong) BaseSearchBar *searchBar;
@property (nonatomic, strong) UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@end

@implementation ProcessingTaskViewController
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
    
    TaskParentViewController *parentViewController = (TaskParentViewController *)self.parentViewController;
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    self.searchBar = parentViewController.searchBar;
    self.searchButton = parentViewController.searchButton;
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
    [mutableParams setObject:@3 forKey:@"State"];
    
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
                                             [self getNetworkDataWithHeader:isPullingDown];
                                             self.noDataView.hidden = YES;
                                         } else {
                                             [datas removeAllObjects];
                                             self.tableView.tableHeaderView.hidden = YES;
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
                   @"State":@3
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
                                                 TaskModel *task = [[TaskModel alloc]initWithDictionary:dic error:nil];
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
#pragma mark - tableview delegate
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 2;
    return [datas count];
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewAutomaticDimension;
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
        if (task.isOrderTick) {   //正计时显示- 颜色变为黑色
            cell.leftTimeLabel.text = @"-";
            cell.leftTimeLabel.textColor = UIColorFromHex(0x212121);
        } else {
            cell.leftTimeLabel.text = [self getHourAndMinuteFromSeconds:task.leftTime];
            cell.leftTimeLabel.textColor = UIColorFromHex(0x00935E);
        }

        //空气波持续治疗时间特殊处理
        if ([task.solution.treatTime isEqualToString:@"601"]) {
            [cell.treatmentButton setTitle:@"治疗时间：持续治疗" forState:UIControlStateNormal];
        } else {
            [cell.treatmentButton setTitle:[NSString stringWithFormat:@"治疗时间：%@min",task.solution.treatTime] forState:UIControlStateNormal];
        }
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
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *edit = [[UIMenuItem alloc] initWithTitle:@"病人替换"
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
    TaskModel *task = datas[self.selectedIndex];
    EditTaskView *view = [[EditTaskView alloc]initWithDic:@{} return:^(NSString *patientId) {
        LxDBAnyVar(patientId);
        [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/TaskController/ChangePatient") params:@{@"TaskId":task.uuid,@"PatientId":patientId} hasToken:YES success:^(HttpResponse *responseObject) {
            if ([responseObject.result integerValue] == 1) {
                [BEProgressHUD showMessage:@"已完成病人替换"];
                [self refresh];
            }
        } failure:nil];
    }] ;
    [view showInWindowWithBackgoundTapDismissEnable:YES];
}

- (void)finish:(id)sender {
        TaskModel *task = datas[self.selectedIndex];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"此操作不可撤销，确认完成任务？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/TaskController/Finish")
                                          params:@{@"TaskId":task.uuid}
                                        hasToken:YES
                                         success:^(HttpResponse *responseObject) {
                                             if ([responseObject.result intValue] == 1) {
                                                 [BEProgressHUD showMessage:@"已完成任务"];
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
}
- (void)cancel:(id)sender {
    TaskModel *task = datas[self.selectedIndex];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"此操作不可撤销，确认取消任务？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
- (NSString *)getHourAndMinuteFromSeconds:(NSNumber *)totalTime {
    NSInteger seconds = [totalTime integerValue];
    
    //format of hour
    NSString *HourString = [NSString stringWithFormat:@"%02ld",seconds/3600];
    NSString *minuterString = [NSString stringWithFormat:@"%02ld",(seconds % 3600)/60];
    NSString *fomatTime = [NSString stringWithFormat:@"%@:%@",HourString,minuterString];
    return fomatTime;
}
@end
