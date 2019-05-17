//
//  DepartmentListViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/7.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DepartmentListViewController.h"
#import "LoginViewController.h"
#import "AddMachineViewController.h"
#import "AddDepartmentView.h"
#import "DepartmentModel.h"
#import "MainViewController.h"
#define NAME_LABEL_TAG 10
#define EDIT_BUTTON_TAG 20

@interface DepartmentListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) DepartmentModel *editDepartment;
@property (nonatomic, strong) NSMutableArray *datas;
@property (weak, nonatomic) IBOutlet UIView *noDataView;

@end

@implementation DepartmentListViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
    // Do any additional setup after loading the view.
}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
//    NSMutableArray *names = [NSMutableArray arrayWithObjects:@"疼痛科",@"神经科",@"中医科",@"肿瘤科",@"康复科",@"呼吸内科",@"营养科",nil];
//    for (NSString *name in names) {
//        DepartmentModel *department = [[DepartmentModel alloc]initWithDictionary:@{@"Name":name,@"Uid":@"1"} error:nil];
//        [self.datas addObject:department];
//
//    }


    self.navigationItem.hidesBackButton = YES;
    [self initTableHeaderAndFooter];
}
- (void)initTableHeaderAndFooter {
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    header.stateLabel.textColor =UIColorFromHex(0xABABAB);
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    [self refresh];
}
- (void)refresh {
    [_datas removeAllObjects];
    //通过department 的name查找uuid的字典
    NSMutableDictionary *oppositeDictionary = [[NSMutableDictionary alloc]init];
    //key是科室名 value是uuid
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DepartmentController/List")
                                  params:@{}
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result intValue] == 1) {
                                         if ([responseObject.content count] > 0) {
                                             for (NSDictionary *dic in responseObject.content) {
                                                 DepartmentModel *department = [[DepartmentModel alloc]initWithDictionary:dic error:nil];
                                                 [self.datas addObject:department];
                                                 [oppositeDictionary setObject:department.uuid forKey:department.name];
                                                
                                             }
                                             self.noDataView.hidden = YES;
                                         } else {
                                             self.noDataView.hidden = NO;
                                         }
                                         [Constant sharedInstance].departmentList = self.datas;
                                         [Constant sharedInstance].departmentOppositeDic = oppositeDictionary;
                                         [self.tableView reloadData];
                                     }
                                 }
                                 failure:nil];
}
- (IBAction)backToMachineList:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}
- (IBAction)backToAddMachineViewController:(id)sender {
    BOOL hasOneInNavigationStack = NO;
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[AddMachineViewController class]]) {
            [self.navigationController popToViewController:viewController animated:NO];
            hasOneInNavigationStack = YES;
            break;
        }
    }
    if (!hasOneInNavigationStack) {

        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AddMachineViewController *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"AddMachineViewController"];
        [self.navigationController pushViewController:viewController animated:NO];
    }
    
}
#pragma mark - TableView datasource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_datas count];
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    
    UILabel *nameLabel = [cell viewWithTag:NAME_LABEL_TAG];
    DepartmentModel *department = _datas[indexPath.row];
    nameLabel.text = department.name;
    UIButton *editButton = [cell viewWithTag:EDIT_BUTTON_TAG];
    [editButton addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    DepartmentModel *department = self.datas[indexPath.row];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"删除", @"") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"此操作不可撤销，确认删除科室？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DepartmentController/Delete")
                                          params:@{@"DepartmentId":department.uuid}
                                        hasToken:YES
                                         success:^(HttpResponse *responseObject) {
                                             if ([responseObject.result integerValue] == 1) {
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

        [tableView setEditing:NO animated:YES];  // 这句很重要，退出编辑模式，隐藏左滑菜单
        
    }];
    deleteAction.backgroundColor = UIColorFromHex(0xFF3B30);
    return @[deleteAction];
}
#pragma mark - Action
- (IBAction)AddAction:(id)sender {
    AddDepartmentView *view = [[AddDepartmentView alloc]initWithDic:nil return:^(NSString *name) {
//        weakself(self);
//        [weakSelf.datas addObject:name];
//        [weakSelf.tableView reloadData];
        [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DepartmentController/Add")
                                      params:@{@"Name":name}
                                    hasToken:YES
                                     success:^(HttpResponse *responseObject) {
                                         if ([responseObject.result intValue] == 1) {
                                             [self refresh];
                                         }
                                     }
                                     failure:nil];

    }] ;
    [view showInWindowWithBackgoundTapDismissEnable:YES];
}
- (void)editAction:(UIButton *)sender {
    //获取某个cell的数据
    UIView *contentView = [(UIView *)sender superview];
    UITableViewCell *cell = (UITableViewCell* )[contentView superview];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    DepartmentModel *department = self.datas[indexpath.row];
    self.editDepartment = department;

    AddDepartmentView *view = [[AddDepartmentView alloc]initWithDic:[department toDictionary]  return:^(NSString *name) {
        [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DepartmentController/ReName")
                                      params:@{@"DepartmentId":self.editDepartment.uuid,
                                               @"NewName":name
                                               }
                                    hasToken:YES
                                     success:^(HttpResponse *responseObject) {
                                         if ([responseObject.result intValue] == 1) {
                                             [self refresh];
                                         }
                                     }
                                     failure:nil];
    }];
    [view showInWindowWithBackgoundTapDismissEnable:YES];
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

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [[NSMutableArray alloc]init];
    }
    return _datas;
}
- (IBAction)routineButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"AdminToNurse2" sender:nil];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AdminToNurse2"]) {
        MainViewController *vc = (MainViewController *)segue.destinationViewController;
        vc.isAdminRole = YES;
    }
}
@end
