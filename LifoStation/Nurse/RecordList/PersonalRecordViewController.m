//
//  PersonalRecordViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PersonalRecordViewController.h"
#import "ReportTableViewController.h"
#import "SelectDateView.h"
#import "RecordCell.h"
//dropdata
#import "GHDropMenu.h"
#import "UIView+Extension.h"
#import "NSArray+Bounds.h"
@interface PersonalRecordViewController ()<UITableViewDelegate,UITableViewDataSource,GHDropMenuDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet UILabel *patientLabel;

@end

@implementation PersonalRecordViewController
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
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x3A87C7);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.estimatedRowHeight = 56;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    datas = [NSMutableArray arrayWithCapacity:20];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    if (self.patient.medicalNumber) {
        self.patientLabel.text = [NSString stringWithFormat:@"病历号:%@    姓名:%@",self.patient.medicalNumber,self.patient.personName];
    }

    /** 下拉刷新控件 */
    [self initTableHeaderAndFooter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideKeyBoard];
}
- (void)hideKeyBoard {
    
    [self.view endEditing:YES];
    [self.tableView endEditing:YES];
}
#pragma mark - refresh
-(void)initTableHeaderAndFooter{
    
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
    [self refreshDataWithHeader:YES];
}
- (void)loadMore {
    [self refreshDataWithHeader:NO];
}
- (void)endRefresh {
    if (page == 0) {
        [self.tableView.mj_header endRefreshing];
    }
    [self.tableView.mj_footer endRefreshing];
}
- (void)refreshDataWithHeader:(BOOL)isPullingDown {
    
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/TreatLogController/List?Action=Count")
                                  params:@{@"PatientId":self.patient.uuid}
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
                                         
                                     }
                                 } failure:nil];
    
}
- (void)getNetworkDataWithHeader:(BOOL)isPullingDown {
    if (isPullingDown) {
        page = 0;
    } else {
        page ++;
    }

    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/TreatLogController/List?Action=List")
                                  params:@{
                                           @"Page":[NSNumber numberWithInt:page],
                                           @"PatientId":self.patient.uuid
                                           }
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
                                         LxDBAnyVar(content);
                                         if (content) {
                                             for (NSDictionary *dic in content) {

                                                 [datas addObject:dic];

                                             }
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.tableView reloadData];
                                             });
                                         }
                                     }
                                     
                                 } failure:nil];
    
}
#pragma mark - Tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 2;
    return [datas count];
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"Cell";
    RecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[RecordCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *dataDic = datas[indexPath.row];
    if ([dataDic[@"TreatAddress"] length] >0) {
        cell.treatAddressLabel.text = dataDic[@"TreatAddress"];
       } else {
           cell.treatAddressLabel.text = @"-";
       }
    cell.machineTypeLabel.text = dataDic[@"MachineType"];
    cell.machineNameLabel.text = dataDic[@"DeviceName"];
    cell.treatmentTimeLabel.text = [self getHourAndMinuteFromSeconds:dataDic[@"TreatTime"]];
    cell.treatDateLabel.text = [self stringFromTimeIntervalString:dataDic[@"RecordTime"] dateFormat:@"yyyy-MM-dd"];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dataDic = datas[indexPath.row];
    NSString *taskId = dataDic[@"TaskId"];
    [self performSegueWithIdentifier:@"personalToReport" sender:taskId];
    
}
#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"personalToReport"]) {
        ReportTableViewController *vc = (ReportTableViewController *)segue.destinationViewController;
        vc.taskId = sender;
    }
}
#pragma mark - Filter
- (IBAction)showTimeFilter:(id)sender {
    SelectDateView *view = [SelectDateView createViewFromNib];
    [view showInWindowWithBackgoundTapDismissEnable:YES];
}
- (IBAction)filterDropMenu:(id)sender {
    GHDropMenuModel *configuration = [[GHDropMenuModel alloc]init];
    
    configuration.titles = [self creaFilterDropMenuData];
    configuration.recordSeleted = NO;
    configuration.titleViewBackGroundColor = UIColorFromHex(0xf8f8f8);
    
    weakself(self);
    GHDropMenu *dropMenu = [GHDropMenu creatDropFilterMenuWidthConfiguration:configuration dropMenuTagArrayBlock:^(NSArray * _Nonnull tagArray) {
        [weakSelf getStrWith:tagArray];
        
    }];
    dropMenu.delegate = self;
    dropMenu.durationTime = 0.5;
    [dropMenu show];
}
- (NSArray *)creaFilterDropMenuData {
    
    NSArray *row1 = @[@"全部",@"完整",@"待补充"];
    NSMutableArray *dataArray1 = [NSMutableArray array];
    for (NSInteger index = 0 ; index < row1.count; index++) {
        GHDropMenuModel *dropMenuModel = [[GHDropMenuModel alloc]init];
        dropMenuModel.tagName = [row1 by_ObjectAtIndex:index];
        //默认选择全部
        if (index == 0) {
            dropMenuModel.tagSeleted = YES;
        }
        [dataArray1 addObject:dropMenuModel];
    }
    
    
    NSArray *row2 = @[@"全部",@"疼痛科",@"神经科",@"设备科"];
    NSMutableArray *dataArray2 = [NSMutableArray array];
    for (NSInteger index = 0 ; index < row2.count; index++) {
        GHDropMenuModel *dropMenuModel = [[GHDropMenuModel alloc]init];
        dropMenuModel.tagName = [row2 by_ObjectAtIndex:index];
        //默认选择全部
        if (index == 0) {
            dropMenuModel.tagSeleted = YES;
        }
        [dataArray2 addObject:dropMenuModel];
    }
    
    /** 设置构造右侧弹出筛选菜单每行的标题 */
    NSArray *sectionHeaderTitles = @[@"记录是否完整",@"科室"];
    NSMutableArray *sections = [NSMutableArray array];
    
    for (NSInteger index = 0; index < sectionHeaderTitles.count; index++) {
        GHDropMenuModel *dropMenuModel = [[GHDropMenuModel alloc]init];
        dropMenuModel.sectionHeaderTitle = sectionHeaderTitles[index];
        if (index == 0) {
            dropMenuModel.dataArray = dataArray1;
            /** 单选 */
            dropMenuModel.isMultiple = NO;
            dropMenuModel.filterCellType = GHDropMenuFilterCellTypeTag;
        }
        else if (index == 1) {
            dropMenuModel.dataArray = dataArray2;
            /** 单选 */
            dropMenuModel.isMultiple = NO;
            dropMenuModel.filterCellType = GHDropMenuFilterCellTypeTag;
        }
        [sections addObject:dropMenuModel];
    }
    NSMutableArray *titlesArray = [NSMutableArray array];
    NSArray *types = @[
                       @(GHDropMenuTypeFilter),
                       ];
    /** 菜单标题 */
    
    for (NSInteger index = 0 ; index < 1; index++) {
        GHDropMenuModel *dropMenuModel = [[GHDropMenuModel alloc]init];
        //        dropMenuModel.title = titles[index];
        NSNumber *typeNum = types[index];
        dropMenuModel.dropMenuType = typeNum.integerValue;
        
        //        dropMenuModel.dataArray = dataArray1;
        dropMenuModel.sections = sections;
        
        dropMenuModel.identifier = index;
        [titlesArray addObject:dropMenuModel];
    }
    return titlesArray;
}
#pragma mark - DropMenu Delegate
- (void)dropMenu:(GHDropMenu *)dropMenu dropMenuTitleModel:(GHDropMenuModel *)dropMenuTitleModel {
    self.navigationItem.title = [NSString stringWithFormat:@"筛选结果 : %@",dropMenuTitleModel.title];
}
- (void)dropMenu:(GHDropMenu *)dropMenu tagArray:(NSArray *)tagArray {
    [self getStrWith:tagArray];
}

- (void)getStrWith: (NSArray *)tagArray {
    NSMutableString *string = [NSMutableString string];
    if (tagArray.count) {
        for (GHDropMenuModel *dropMenuTagModel in tagArray) {
            if (dropMenuTagModel.tagSeleted) {
                if (dropMenuTagModel.tagName.length) {
                    [string appendFormat:@"%@",dropMenuTagModel.tagName];
                }
            }
        }
    }
    self.navigationItem.title = [NSString stringWithFormat:@"筛选结果 : %@",string];
}
- (NSString *)getHourAndMinuteFromSeconds:(NSString *)totalTime {
    NSInteger seconds = [totalTime integerValue];
    
    //format of hour
    NSString *HourString = [NSString stringWithFormat:@"%02ld",(long)seconds/3600];
    NSString *minuterString = [NSString stringWithFormat:@"%02ld",((long)seconds % 3600)/60];
    NSString *formatTime = [NSString stringWithFormat:@"%@:%@",HourString,minuterString];
    return formatTime;
}
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
