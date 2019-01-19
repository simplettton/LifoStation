//
//  MachineListViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/4.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MachineListViewController.h"
#import "MachineCell.h"
#import "EditMachineViewController.h"
#import "LoginViewController.h"

//dropdata
#import "GHDropMenu.h"
#import "UIView+Extension.h"
#import "NSArray+Bounds.h"
@interface MachineListViewController ()<UITableViewDelegate,UITableViewDataSource,GHDropMenuDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation MachineListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
}

- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.searchBar.backgroundImage = [[UIImage alloc]init];
    self.searchBar.tintColor = UIColorFromHex(0x5E97FE);
    UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
    searchField.textColor = UIColorFromHex(0x212121);
    [searchField setValue:[UIFont systemFontOfSize:15 weight:UIFontWeightLight] forKeyPath:@"_placeholderLabel.font"];
}

#pragma mark - TableView datasource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"Cell";
    MachineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MachineCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
//    cell.editButton.tag = indexPath.row;
    [cell.editButton addTarget:self action:@selector(editDevice:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)editDevice:(UIButton *)sender {

    //获取某个cell的数据
    UIView *contentView = [(UIView *)sender superview];
    MachineCell *cell = (MachineCell* )[contentView superview];
    [self performSegueWithIdentifier:@"EditDeviceInformation" sender:cell];
}
#pragma mark - Filter drop menu
- (IBAction)filterDropMenu:(id)sender {
    GHDropMenuModel *configuration = [[GHDropMenuModel alloc]init];
    
    configuration.titles = [self createFilterDropMenuData];
    /** 配置筛选菜单是否记录用户选中 默认NO */
    configuration.recordSeleted = YES;
    
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
    NSArray *row1 = @[@"全部",@"空气波",@"电疗",@"光子"];
    NSMutableArray *dataArray1 = [NSMutableArray array];
    for (NSInteger index = 0 ; index < row1.count; index++) {
        GHDropMenuModel *dropMenuModel = [[GHDropMenuModel alloc]init];
        dropMenuModel.tagName = [row1 by_ObjectAtIndex:index];
//        //默认选择全部
//        if (index == 0) {
//            dropMenuModel.tagSeleted = YES;
//        }
        [dataArray1 addObject:dropMenuModel];
    }
    
    NSArray *row2 = @[@"全部",@"疼痛科",@"神经科",@"设备科"];
    NSMutableArray *dataArray2 = [NSMutableArray array];
    for (NSInteger index = 0 ; index < row2.count; index++) {
        GHDropMenuModel *dropMenuModel = [[GHDropMenuModel alloc]init];
        dropMenuModel.tagName = [row2 by_ObjectAtIndex:index];
//        //默认选择全部
//        if (index == 0) {
//            dropMenuModel.tagSeleted = YES;
//        }
        [dataArray2 addObject:dropMenuModel];
    }
    
    
    /** 设置构造右侧弹出筛选菜单每行的标题 */
    NSArray *sectionHeaderTitles = @[@"设备种类",@"科室"];
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
    NSLog(@"%@",[NSString stringWithFormat:@"筛选结果 : %@",string]);
}

- (IBAction)deleteAction:(id)sender {
    if (self.tableView.editing) {
        
        //完成删除之后的操作
        self.deleteButton.titleLabel.text = @"删除";
        [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        
//        NSMutableArray *deleteArray = [NSMutableArray array];
        
//        //header跟着tableview 左移
//        CGRect frame = self.tableView.tableHeaderView.frame;
//        frame.origin.x -= 36;
//        self.tableView.tableHeaderView.frame = frame;
//
//        for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
//
//            [deleteArray addObject:datas[indexPath.row]];
//
//            NSString *cpuid = [datas[indexPath.row]objectForKey:@"cpuid"];
//
//            [[NetWorkTool sharedNetWorkTool]POST:[HTTPServerURLString stringByAppendingString:@"Api/DBDevice/Delete"]
//                                          params:@{
//                                                   @"cpuid":cpuid
//                                                   }
//                                        hasToken:YES
//                                         success:^(HttpResponse *responseObject) {
//                                             if ([responseObject.result intValue]==1) {
//                                                 dispatch_async(dispatch_get_main_queue(), ^{
//
//                                                     [self refresh];
//
//                                                     //完成删除后不给选中cell
//                                                     for (DeviceTableViewCell *cell in self.tableView.visibleCells) {
//                                                         cell.selectionStyle = UITableViewCellSelectionStyleNone;
//                                                     }
//
//                                                 });
//                                             }else{
//                                                 NSString *error = responseObject.errorString;
//                                                 dispatch_async(dispatch_get_main_queue(), ^{
//                                                     [SVProgressHUD showErrorWithStatus:error];
//                                                     [self.tableView reloadData];
//                                                 });
//                                             }
//                                         }
//                                         failure:nil];
//
//        }
        
    }else{
        self.deleteButton.titleLabel.text = @"完成";
        [self.deleteButton setTitle:@"完成" forState:UIControlStateNormal];
        for (MachineCell *cell in self.tableView.visibleCells) {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
//        //header跟着tableview右移
//        CGRect frame = self.tableView.tableHeaderView.frame;
//        frame.origin.x += 36;
//        self.tableView.tableHeaderView.frame = frame;
    }
    
    [self.tableView setEditing:!self.tableView.editing animated:NO];
}


#pragma mark - Prepare For Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditDeviceInformation"]) {
        MachineCell *cell = (MachineCell *)sender;
        EditMachineViewController *controller = (EditMachineViewController *)segue.destinationViewController;
        controller.machineName = cell.nameLabel.text;
    }
}
#pragma mark - Logout Action
- (IBAction)logoutAction:(id)sender {
    [self presentLogoutAlert];
}
- (void)presentLogoutAlert {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"退出后不会删除任何历史数据，下次登录依然可以使用本账号。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* logoutAction = [UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [UserDefault setBool:NO forKey:@"IsLogined"];
        [UserDefault synchronize];
        
        [[[UIApplication sharedApplication].delegate window].rootViewController removeFromParentViewController];
        
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *vc = (LoginViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [UIView transitionWithView:[[UIApplication sharedApplication].delegate window]
                          duration:0.25
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [[UIApplication sharedApplication].delegate window].rootViewController = vc;
                        }
                        completion:nil];
        
        [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];
    }];
    
    [alert addAction:logoutAction];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
