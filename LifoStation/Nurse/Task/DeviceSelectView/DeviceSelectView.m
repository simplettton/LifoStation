//
//  DeviceSelectView.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/27.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DeviceSelectView.h"
#import "DeviceItemCell.h"
#import "UIView+Tap.h"
#import "UIView+TYAlertView.h"
#import "DeviceItemCell.h"
#import "MachineModel.h"
@interface DeviceSelectView()<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger selectedMachineType;
@property (weak, nonatomic) IBOutlet UIView *offlineLine;
@property (weak, nonatomic) IBOutlet UIView *onlineLine;
@property (weak, nonatomic) IBOutlet UIView *offlineView;
@property (weak, nonatomic) IBOutlet UIView *onlineView;
@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *offlineLabel;
@property (nonatomic, assign) BOOL isOnline;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *hiddentitles;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@end
@implementation DeviceSelectView
{
    int page;
    int totalPage;  //总页数
    BOOL isRefreshing; //是否正在下拉刷新或者上拉加载
    BOOL isFilteredList; //是否筛选
    NSMutableDictionary *filterparam;//筛选关键字
    NSMutableArray *datas;
}

- (instancetype)initWithModel:(TaskModel *)task return:(returnDicBlock)returnEvent {
    if (self = [super init]) {
        DeviceSelectView *view = [DeviceSelectView createViewFromNib];
        view.task = task;
        view.returnEvent = returnEvent;
        return view;
    }
    return self;
}
- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (IBAction)search:(id)sender {
    if ([self.searchBar.text length] > 0) {
        isFilteredList = YES;
        NSMutableDictionary *paramDic = [[NSMutableDictionary alloc]initWithCapacity:20];
        [paramDic setObject:self.searchBar.text forKey:@"Name"];
        filterparam = paramDic;
        [self refreshDataWithHeader:YES];
    } else {
        isFilteredList = NO;
        [self.tableView.mj_header beginRefreshing];
    }
}
- (void)endRefresh {
    if (page == 0) {
        [self.tableView.mj_header endRefreshing];
    }
    [self.tableView.mj_footer endRefreshing];
}
- (IBAction)download:(id)sender {
    [self hideView];

    MachineModel *machine = datas[self.selectedIndex];
    NSDictionary *dic = @{@"TaskId":self.task.uuid,@"Cpuid":machine.cpuid};
    self.returnEvent(dic);

}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self initAll];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)initAll {
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    filterparam = [[NSMutableDictionary alloc]initWithCapacity:20];
    /** 注册新定义cell */
    [self.tableView registerNib:[UINib nibWithNibName:@"DeviceItemCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DeviceItemCell"];
//    [self.tableView registerClass:[DeviceItemCell class] forCellReuseIdentifier:@"offlineCell"];
    self.tableView.tableFooterView = [[UIView alloc]init];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    _isOnline = true;
    [self initTableHeaderAndFooter];

    //searchbar style
    self.searchBar.backgroundImage = [[UIImage alloc]init];//去除边框线
    self.searchBar.tintColor = UIColorFromHex(0x5E97FE);//出现光标
    self.searchBar.delegate = self;
    UITextField * searchField = [_searchBar valueForKey:@"_searchField"];
    [searchField setValue:[UIFont systemFontOfSize:15 weight:UIFontWeightLight] forKeyPath:@"_placeholderLabel.font"];
    [self.onlineView addTapBlock:^(id obj) {
        _isOnline = true;
        self.selectedMachineType = online;
        self.onlineLabel.textColor = UIColorFromHex(0x1890FF);
        self.onlineLine.hidden = NO;
        self.offlineLabel.textColor = UIColorFromHex(0x616161);
        self.offlineLine.hidden= YES;
        for (UILabel *title in self.hiddentitles) {
            title.hidden = (self.selectedMachineType == offline);
        }
        [self refresh];
    }];
    
    [self.offlineView addTapBlock:^(id obj) {
        _isOnline = false;
        self.selectedMachineType = offline;
        self.offlineLabel.textColor = UIColorFromHex(0x1890FF);
        self.offlineLine.hidden = NO;
        self.onlineLabel.textColor = UIColorFromHex(0x616161);
        self.onlineLine.hidden= YES;
        for (UILabel *title in self.hiddentitles) {
            title.hidden = (self.selectedMachineType == offline);
        }
        [self refresh];
    }];
}
- (void)initTableHeaderAndFooter {

    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    header.stateLabel.textColor =UIColorFromHex(0xABABAB);
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    [self refresh];
    
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
- (void)refreshDataWithHeader:(BOOL)isPullingDown {
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    if (isFilteredList) {
        params = filterparam;
    }
    if (_isOnline) {
        [params setObject:@1 forKey:@"IsOnline"];
    } else {
        [params setObject:@0 forKey:@"IsOnline"];
    }
    [params setObject:self.task.solution.machineType forKey:@"MachineType"];
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/List?Action=Count")
                                  params:params
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result intValue] == 1) {
                                         [self endRefresh];
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
                                             if (self.isOnline) {
                                                 self.downloadButton.hidden = NO;
                                             }
                                            

                                             [self getNetworkDataWithHeader:isPullingDown];
                                             //                                             [self hideNodataView];
                                         }else{
                                             [datas removeAllObjects];
                                             if (self.isOnline) {
                                                 self.downloadButton.hidden = YES;
                                             }
                                             self.tableView.tableHeaderView.hidden = YES;
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.tableView reloadData];
                                             });
                                             if (isFilteredList) {
                                                 [BEProgressHUD showMessage:@"没有找到该设备"];
                                             }else{
                                                 
                                                 [BEProgressHUD showMessage:@"暂无记录"];
                                             }
                                             
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
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    if (isFilteredList) {
        [filterparam setObject:[NSNumber numberWithInt:page] forKey:@"Page"];
        params = filterparam;
    } else {
        [params setObject:[NSNumber numberWithInt:page] forKey:@"Page"];
    }
    if (_isOnline) {
        [params setObject:@1 forKey:@"IsOnline"];
    } else {
        [params setObject:@0 forKey:@"IsOnline"];
    }
    [params setObject:self.task.solution.machineType forKey:@"MachineType"];
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/List")
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
                                         LxDBAnyVar(content);
                                         if (content) {
                                             for (NSDictionary *dic in content) {
                                                 NSError *error;
                                                 MachineModel *machine = [[MachineModel alloc]initWithDictionary:dic error:&error];

                                                 [datas addObject:machine];
                                             }
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.tableView reloadData];
                                             });
                                         }
                                     }
                                     
                                 } failure:nil];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideKeyBoard];
}

- (void)hideKeyBoard {
    [self endEditing:YES];
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
#pragma mark - tableview datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceItemCell" forIndexPath:indexPath];
    
    //离线隐藏
    cell.statusLabel.hidden = (self.selectedMachineType == offline);
    cell.usageLabel.hidden = (self.selectedMachineType == offline);
    cell.leftTimeLabel.hidden = (self.selectedMachineType == offline);
    cell.selectionImageView.hidden = (self.selectedMachineType == offline);
    cell.bellButton.hidden = (self.selectedMachineType == offline);

    self.downloadButton.hidden = (self.selectedMachineType == offline);
    if (self.selectedMachineType == online) {
        cell.selectionImageView.hidden = indexPath.row == self.selectedIndex? NO:YES;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    MachineModel *machine = datas[indexPath.row];
    if ([machine.departmentName length] == 0) {
        cell.departmentLabel.text = @"未分组";
    } else {
        cell.departmentLabel.text = machine.departmentName;
    }

    cell.deviceNameLabel.text = machine.name;
    if ([machine.state integerValue] == STOP) {
        cell.statusLabel.text = @"空闲";
    } else {
        cell.statusLabel.text = @"使用中";
        cell.statusLabel.text = [NSString stringWithFormat:@"%@ min",machine.leftTime];
    }
    //类似4min 格式
    cell.leftTimeLabel.text = [self changeSecondToTimeString:machine.leftTime];
    cell.bellButton.tag = indexPath.row;
    [cell.bellButton addTarget:self action:@selector(ringAction:) forControlEvents:UIControlEventTouchUpInside];

    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
    [tableView reloadData];
}
- (void)ringAction :(id)sender {

    MachineModel *machine = datas[[sender tag]];
    NSString *cpuid = machine.cpuid;
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/Beep")
                                  params:@{
                                           @"Cpuid":cpuid,
                                           @"LongBeep":@0
                                           }
                                hasToken:YES success:^(HttpResponse *responseObject) {
                                    
                                } failure:nil];
}
- (NSString *)changeSecondToTimeString:(NSString *)second {
    
    NSInteger minute = [second integerValue]/60;

    if (second != 0) {
        if (minute < 1) {
            minute = 1;
        }
    }

    NSString *timeString = [NSString stringWithFormat:@"%ld min",minute];
    return timeString;
}
@end
