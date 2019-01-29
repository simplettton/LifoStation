//
//  DeviceListViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/29.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DeviceListViewController.h"
#import "DeviceCell.h"
#import "UIView+TYAlertView.h"
#import <MMAlertView.h>
//dropdata
#import "GHDropMenu.h"
#import "UIView+Extension.h"
#import "NSArray+Bounds.h"

#import "EditDeviceView.h"
@interface DeviceListViewController ()<UITableViewDelegate,UITableViewDataSource,GHDropMenuDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DeviceListViewController

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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentitifier = @"Cell";
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentitifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DeviceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentitifier];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //点击事件
    MMPopupItemHandler block = ^(NSInteger index){
        switch (index) {
            case 0:
            {
                EditDeviceView *view = [EditDeviceView createViewFromNib];
                [view showInWindow];
            }

                break;
            case 1:
                break;
            default:
                break;
        }
    };
    
    MMPopupCompletionBlock completeBlock = ^(MMPopupView *popupView, BOOL finished){
        
    };
    
    NSArray *items =
    @[MMItemMake(@"修改设备信息", MMItemTypeNormal, block),
      MMItemMake(@"查看治疗记录", MMItemTypeNormal, block),
      MMItemMake(@"取消", MMItemTypeNormal, block)];
    
    [[[MMAlertView alloc] initWithTitle:@""
                                 detail:@""
                                  items:items]
     showWithBlock:completeBlock];
}
#pragma mark - filter
- (IBAction)filterDropMenu:(id)sender {
    GHDropMenuModel *configuration = [[GHDropMenuModel alloc]init];
    
    configuration.titles = [self creaFilterDropMenuData];
    /** 配置筛选菜单是否记录用户选中 默认NO */
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

    NSArray *row1 = @[@"全部",@"使用中",@"空闲"];
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
    
    NSArray *row2 = @[@"全部",@"在线",@"离线"];
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
    
    NSArray *row3 = @[@"全部",@"空气波",@"电疗",@"光子"];
    NSMutableArray *dataArray3 = [NSMutableArray array];
    for (NSInteger index = 0 ; index < row3.count; index++) {
        GHDropMenuModel *dropMenuModel = [[GHDropMenuModel alloc]init];
        dropMenuModel.tagName = [row3 by_ObjectAtIndex:index];
        //默认选择全部
        if (index == 0) {
            dropMenuModel.tagSeleted = YES;
        }
        [dataArray3 addObject:dropMenuModel];
    }

    NSArray *row4 = @[@"全部",@"疼痛科",@"神经科",@"设备科"];
    NSMutableArray *dataArray4 = [NSMutableArray array];
    for (NSInteger index = 0 ; index < row4.count; index++) {
        GHDropMenuModel *dropMenuModel = [[GHDropMenuModel alloc]init];
        dropMenuModel.tagName = [row4 by_ObjectAtIndex:index];
        //默认选择全部
        if (index == 0) {
            dropMenuModel.tagSeleted = YES;
        }
        [dataArray4 addObject:dropMenuModel];
    }

    /** 设置构造右侧弹出筛选菜单每行的标题 */
    NSArray *sectionHeaderTitles = @[@"使用状态",@"设备状态",@"设备种类",@"科室"];
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
        else if (index == 2) {
            dropMenuModel.dataArray = dataArray3;
            /** 单选 */
            dropMenuModel.isMultiple = NO;
            dropMenuModel.filterCellType = GHDropMenuFilterCellTypeTag;
        }
        else if (index == 3) {
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
        
//        dropMenuModel.dataArray = dataArray1;
        dropMenuModel.sections = sections;
        
        dropMenuModel.identifier = index;
        [titlesArray addObject:dropMenuModel];
    }
    return titlesArray;
}
#pragma mark - 代理方法;
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
@end
