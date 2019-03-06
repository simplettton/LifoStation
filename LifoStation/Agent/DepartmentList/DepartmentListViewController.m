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
#define NAME_LABEL_TAG 10
#define EDIT_BUTTON_TAG 20
@interface DepartmentListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DepartmentListViewController
{
    NSMutableArray *datas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
    // Do any additional setup after loading the view.
}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    datas = [NSMutableArray arrayWithObjects:@"疼痛科",@"神经科",@"中医科",@"肿瘤科",@"康复科",@"呼吸内科",@"营养科",nil];
    self.navigationItem.hidesBackButton = YES;
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
    return [datas count];
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *nameLabel = [cell viewWithTag:NAME_LABEL_TAG];
    nameLabel.text = datas[indexPath.row];
    UIButton *editButton = [cell viewWithTag:EDIT_BUTTON_TAG];
    [editButton addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    

//    ChooseDepartmentView  *view = [[ChooseDepartmentView alloc]initWithDic:@{@"department":cell.departmentNameLabel.text} return:^(NSString *selectedDepartment) {
//        NSLog(@"选择了%@",selectedDepartment);
//
//        cell.departmentNameLabel.text = selectedDepartment;
//
//        [view showInWindow];
//    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"删除", @"") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [tableView setEditing:NO animated:YES];  // 这句很重要，退出编辑模式，隐藏左滑菜单
        
    }];
//    deleteAction.backgroundColor = UIColorFromHex(0x08BF91);
        deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction];
}
#pragma mark - Action
- (IBAction)AddAction:(id)sender {
    AddDepartmentView *view = [[AddDepartmentView alloc]initWithDic:nil return:^(NSString *name) {
        weakself(self);
        [self->datas addObject:name];
        [weakSelf.tableView reloadData];
    }] ;
    [view showInWindow];
}
- (void)editAction:(UIButton *)sender {
    //获取某个cell的数据
    UIView *contentView = [(UIView *)sender superview];
    UITableViewCell *cell = (UITableViewCell* )[contentView superview];
    UILabel *nameLabel = [cell viewWithTag:NAME_LABEL_TAG];
    NSString *departmentName = nameLabel.text;
    AddDepartmentView *view = [[AddDepartmentView alloc]initWithDic:@{@"department":departmentName} return:^(NSString *name) {
        nameLabel.text = name;
    }];
    [view showInWindow];
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
