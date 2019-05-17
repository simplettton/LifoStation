//
//  PatientListViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/25.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PatientListViewController.h"
#import "AddPatientViewController.h"
#import "PersonalRecordViewController.h"
#import "PatientCell.h"
#import "UIView+TYAlertView.h"
#import <MMAlertView.h>
//dropdata
#import "GHDropMenu.h"
#import "UIView+Extension.h"
#import "NSArray+Bounds.h"
@interface PatientListViewController ()<GHDropMenuDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@end

@implementation PatientListViewController
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
    if (datas) {
        if (self.patient) {
            for (PatientModel *patient in datas) {
                if ([patient.medicalNumber isEqualToString:self.patient.medicalNumber]) {
                    
                    NSInteger index = [datas indexOfObject:patient];
                    
                    [datas replaceObjectAtIndex:index withObject:self.patient];
                    
                    [self.tableView reloadData];
                    
                    break;
                }
            }
        } else if (self.hasNewPatient) {
            [self refresh];
        }
    }
}
- (void)initAll {
    
    //navigation 返回导航栏的样式
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    //UITbleView设置
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 5, 0, 20);
    self.tableView.estimatedRowHeight = 53;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    self.searchBar.delegate = self;
    [self initTableHeaderAndFooter];
    
    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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
- (void)initTableHeaderAndFooter {
    
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    header.stateLabel.textColor =UIColorFromHex(0xABABAB);
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
    
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
- (void)refreshDataWithHeader:(BOOL)isPullingDown {
    NSDictionary *params = [[NSDictionary alloc]init];
    if (isFilteredList) {
        params = (NSDictionary *)filterparam;
    }
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/PatientController/List?Action=Count")
                                  params:params
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
                   @"Page":[NSNumber numberWithInt:page]
                   };
    }
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/PatientController/List?Action=List")
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
                                                 PatientModel *patient = [[PatientModel alloc]initWithDictionary:dic error:nil];
                                                 [datas addObject:patient];
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
#pragma mark - Table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
//    return 65;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [datas count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    PatientCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[PatientCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    PatientModel *patient = datas[indexPath.row];
    cell.medicalNumberLabel.text = patient.medicalNumber;
    cell.nameLabel.text = patient.personName;
    cell.treatAddressLabel.text = ((patient.treatAddress == nil)||([patient.treatAddress isEqualToString:@""])) ? @"-" : patient.treatAddress;

    cell.genderLabel.text = (patient.gender == nil) ? @"-" : patient.gender;
    cell.ageLabel.text = (patient.age == nil) ? @"-" : patient.age;
    cell.registeredDateLabel.text = [self stringFromTimeIntervalString:patient.registeredDate dateFormat:@"yyyy-MM-dd"];
    cell.editButton.tag = indexPath.row;
    [cell.editButton addTarget:self action:@selector(editPatientInfomation:) forControlEvents:UIControlEventTouchUpInside];
    [cell.treatRecordButton addTarget:self action:@selector(showTreatRecord:) forControlEvents:UIControlEventTouchUpInside];

    cell.treatAddressLabel.numberOfLines=0;  //可多行显示
    cell.treatAddressLabel.lineBreakMode=NSLineBreakByWordWrapping;//拆行

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//    //点击事件
//    MMPopupItemHandler block = ^(NSInteger index){
//        switch (index) {
//            case 0:
//                [self performSegueWithIdentifier:@"AddNewPatient" sender:nil];
//                break;
//            case 1:
//                [self performSegueWithIdentifier:@"ShowPersonalRecord" sender:nil];
//                break;
//            default:
//                break;
//        }
//    };
//
//    MMPopupCompletionBlock completeBlock = ^(MMPopupView *popupView, BOOL finished){
//
//    };
//
//    NSArray *items =
//    @[MMItemMake(@"修改信息", MMItemTypeNormal, block),
//      MMItemMake(@"查看治疗记录", MMItemTypeNormal, block),
//      MMItemMake(@"取消", MMItemTypeNormal, block)];
//
//    [[[MMAlertView alloc] initWithTitle:@""
//                                 detail:@""
//                                  items:items]
//     showWithBlock:completeBlock];
}
#pragma mark - Action
- (void)editPatientInfomation:(UIButton *)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    PatientModel *patient = datas[indexPath.row];

    [self performSegueWithIdentifier:@"EditPatient" sender:patient];
    
}
- (void)showTreatRecord:(UIButton *)sender {
    PatientCell *cell = (PatientCell *)[[sender superview]superview];
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    PatientModel *patient = datas[index];
    [self performSegueWithIdentifier:@"ShowPersonalRecord" sender:patient];
}
#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditPatient"]) {
        AddPatientViewController *controller = (AddPatientViewController *)segue.destinationViewController;
        controller.patient = sender;
    } else if ([segue.identifier isEqualToString:@"ShowPersonalRecord"]) {
        PersonalRecordViewController *vc = (PersonalRecordViewController *)segue.destinationViewController;
        PatientModel *patient = (PatientModel *)sender;
        vc.patient = patient;
    }
}
#pragma mark - filter drop menu
- (IBAction)filterDropMenu:(id)sender {
    GHDropMenuModel *configuration = [[GHDropMenuModel alloc]init];
    
    configuration.titles = [self createFilterDropMenuData];
    /** 配置筛选菜单是否记录用户选中 默认NO */
    configuration.recordSeleted = NO;
    
    weakself(self);
    GHDropMenu *dropMenu = [GHDropMenu creatDropFilterMenuWidthConfiguration:configuration dropMenuTagArrayBlock:^(NSArray * _Nonnull tagArray) {
        [weakSelf getStrWith:tagArray];
        
    }];
    dropMenu.delegate = self;
    dropMenu.durationTime = 0.5;
    [dropMenu show];

}
- (NSArray *)createFilterDropMenuData {
    
    
    /** 构造右侧弹出筛选菜单第一行数据 */
    NSArray *row1 = @[@"全部",@"疼痛科",@"神经科",@"设备科"];
    NSMutableArray *dataArray4 = [NSMutableArray array];
    for (NSInteger index = 0 ; index < row1.count; index++) {
        GHDropMenuModel *dropMenuModel = [[GHDropMenuModel alloc]init];
        dropMenuModel.tagName = [row1 by_ObjectAtIndex:index];
        //默认选择全部
        if (index == 0) {
            dropMenuModel.tagSeleted = YES;
        }
        [dataArray4 addObject:dropMenuModel];
    }
    
    
    /** 设置构造右侧弹出筛选菜单每行的标题 */
    NSArray *sectionHeaderTitles = @[@"科室"];
    NSMutableArray *sections = [NSMutableArray array];
    
    for (NSInteger index = 0; index < sectionHeaderTitles.count; index++) {
        GHDropMenuModel *dropMenuModel = [[GHDropMenuModel alloc]init];
        dropMenuModel.sectionHeaderTitle = sectionHeaderTitles[index];
        if (index == 0) {
            dropMenuModel.dataArray = dataArray4;
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
        dropMenuModel.sections = sections;
        
        dropMenuModel.identifier = index;
        [titlesArray addObject:dropMenuModel];
    }
    return titlesArray;
}
#pragma mark - 筛选代理方法
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

//日期字符转为时间戳
-(NSString *)timeStampFromTimeString:(NSString *)timeString dataFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    //    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateFormat];
    
    //日期转时间戳
    NSDate *date = [formatter dateFromString:timeString];
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    NSString* timeStamp = [NSString stringWithFormat:@"%ld",timeSp];
    return timeStamp;
}
@end
