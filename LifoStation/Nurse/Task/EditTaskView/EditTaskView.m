//
//  EditTaskView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "EditTaskView.h"
#import "UIView+TYAlertView.h"
#import "PatientModel.h"
#import "EditTaskCell.h"
@interface EditTaskView()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) NSInteger selectedIndex;
@end
@implementation EditTaskView
{
    int page;
    int totalPage;  //总页数
    BOOL isRefreshing; //是否正在下拉刷新或者上拉加载
    BOOL isFilteredList; //是否筛选
    NSMutableDictionary *filterparam;//筛选关键字
    NSMutableArray *datas;
}
- (instancetype)initWithDic:(NSDictionary *)dic return:(returnBlock)returnEvent {
    if (self = [super init]) {
        EditTaskView *view = [EditTaskView createViewFromNib];
        view.returnEvent = returnEvent;
        return view;
    }
    return self;
}
- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (IBAction)saveAction:(id)sender {
    
    [self hideView];
    PatientModel *patient = datas[_selectedIndex];
    self.returnEvent(patient.uuid);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initAll];
}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    //隐藏键盘手势
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    [self initTableHeaderAndFooter];
    
    self.searchBar.backgroundImage = [[UIImage alloc]init];
    self.searchBar.tintColor = UIColorFromHex(0x5E97FE);
    self.searchBar.delegate = self;
    UITextField * searchField = [_searchBar valueForKey:@"_searchField"];
    [searchField setValue:[UIFont systemFontOfSize:15 weight:UIFontWeightLight] forKeyPath:@"_placeholderLabel.font"];
    

    datas = [[NSMutableArray alloc]initWithCapacity:20];
    
}
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
- (void)endRefresh {
    if (page == 0) {
        [self.tableView.mj_header endRefreshing];
    }
    [self.tableView.mj_footer endRefreshing];
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
                                             //                                             [self hideNodataView];
                                         }else{
                                             [datas removeAllObjects];
                                             self.tableView.tableHeaderView.hidden = YES;
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.tableView reloadData];
                                             });
                                             if (isFilteredList) {
                                                 [BEProgressHUD showMessage:@"没有找到该病人"];
                                             }else{
                                                 //                                                 [self showNodataViewWithTitle:@"暂无记录"];
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

-(void)hideKeyBoard {
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
//    return 60;
    return UITableViewAutomaticDimension;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [datas count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditTaskCell *cell = [[NSBundle mainBundle]loadNibNamed:@"EditTaskView" owner:self options:nil].lastObject;
    cell.selectionImageView.hidden = indexPath.row == self.selectedIndex?NO:YES;
    PatientModel *patient = datas[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.medicalNumberLabel.text = patient.medicalNumber;
    cell.nameLabel.text = patient.personName;
    cell.genderLabel.text = patient.gender;
    cell.ageLabel.text = patient.age;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
    [tableView reloadData];
}
@end
