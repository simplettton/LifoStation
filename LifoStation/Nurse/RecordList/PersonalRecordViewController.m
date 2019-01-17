//
//  PersonalRecordViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PersonalRecordViewController.h"
#import "RecordCell.h"
//dropdata
#import "GHDropMenu.h"
#import "UIView+Extension.h"
#import "NSArray+Bounds.h"
@interface PersonalRecordViewController ()<UITableViewDelegate,UITableViewDataSource,GHDropMenuDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PersonalRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];

}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - Tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"Cell";
    RecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[RecordCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - Filter
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
@end
