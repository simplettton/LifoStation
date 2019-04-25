//
//  AddMachineViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/5.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddMachineViewController.h"
#import "AddMachineCell.h"
#import "LoginViewController.h"

#import "UIView+Tap.h"
#import "ChooseDepartmentView.h"
#import "UIView+TYAlertView.h"

#import "MachineTypeModel.h"
#import "DepartmentModel.h"

#define TYPE_ITEM_ORIGIN_X 20
#define TYPE_ITEM_Height 30
#define TYPE_ITEM_INTERVAL 48
@interface AddMachineViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSString *firstDepartment;
@property (nonatomic, strong) NSMutableArray *datas;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@end

@implementation AddMachineViewController
{
    NSMutableArray *typeModelArray;
    NSInteger selectedDeviceTag;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}
- (void)getMachineTypeList {
    NSMutableArray *typeList = [[NSMutableArray alloc]init];
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/MachineController/GetSupportMachineList")
                                  params:@{}
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result integerValue] == 1) {
                                         if ([responseObject.content count]>0) {
                                             for (NSDictionary *dic in responseObject.content) {
                                                 MachineTypeModel *machine = [[MachineTypeModel alloc]initWithDictionary:dic error:nil];
                                                 [typeList addObject:machine];

                                             }
                                             [Constant sharedInstance].machineTypeList = typeList;
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self initMachineTypeScrollView];
                                             });
                                         }
                                     }
                                 }
                                 failure:nil];
}
- (void)getDepartmentList {
    NSMutableArray *departmentList = [[NSMutableArray alloc]init];
    //通过department 的uuid查找name的字典
    NSMutableDictionary *departmentDictionary = [[NSMutableDictionary alloc]init];
    //通过department 的name查找uuid的字典
    NSMutableDictionary *oppositeDictionary = [[NSMutableDictionary alloc]init];
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DepartmentController/List")
                                  params:@{}
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result intValue] == 1) {
                                         if ([responseObject.content count] > 0) {
                                             for (NSDictionary *dic in responseObject.content) {
                                                 DepartmentModel *department = [[DepartmentModel alloc]initWithDictionary:dic error:nil];
                                                 [departmentList addObject:department];
                                                 [departmentDictionary setObject:department.name forKey:department.uuid];
                                                 [oppositeDictionary setObject:department.uuid forKey:department.name];
                                             }
                                         }
                                         else {
                                             dispatch_async(dispatch_get_main_queue(), ^{


                                                 UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                                                                message:@"未搜索到科室，请在科室管理中添加"
                                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                                 
                                                 UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
                                                                                                      handler:^(UIAlertAction * action) {
                                                                                                          
                                                                                                          
                                                                                                      }];
                                                 UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                     [self performSegueWithIdentifier:@"ShowDepartmentList" sender:nil];
                                                 }];
                                                 
                                                 [alert addAction:cancelAction];
                                                 [alert addAction:defaultAction];
                                                 [self presentViewController:alert animated:YES completion:nil];
                                             
                                             });

                                         }

                                         [Constant sharedInstance].departmentList = departmentList;
                                         [Constant sharedInstance].departmentDic = departmentDictionary;
                                         LxDBAnyVar(departmentList);
                                     }
                                 }
                                 failure:nil];
}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.navigationItem.hidesBackButton = YES;
    [self getMachineTypeList];
    [self getDepartmentList];
    [self initTableHeaderAndFooter];
}
- (void)initTableHeaderAndFooter {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    header.stateLabel.textColor =UIColorFromHex(0xABABAB);
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
}
- (void)refresh {

    NSNumber *type = [NSNumber numberWithInteger:selectedDeviceTag];
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/ListRegister")
                                  params:@{@"MachineType":type}
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                        if ([responseObject.result integerValue] == 1) {
                                                if ([responseObject.content count] > 0) {
                                                    for (NSDictionary *dic in responseObject.content) {
                                                        if (![self.datas containsObject:dic]) {
                                                            [self.datas addObject:dic];
                                                        }

                                                    }
                                                    self.noDataView.hidden = YES;
                                                } else {
                                                    [self.datas removeAllObjects];
                                                    self.noDataView.hidden = NO;
                                                }
                                            [self.tableView reloadData];
                                            }
                                    }
                                 failure:nil];
}

- (IBAction)backToMachineList:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}
#pragma mark - ScrollView
- (void)initMachineTypeScrollView {
    
    NSMutableArray *typeList = [Constant sharedInstance].machineTypeList;
    
    typeModelArray = [[NSMutableArray alloc]initWithCapacity:20];
    
    CGFloat contentsizeWidth = TYPE_ITEM_ORIGIN_X;
    for (MachineTypeModel *type in typeList) {
        [typeModelArray addObject:type];

    }

    self.scrollView.contentSize = CGSizeMake(contentsizeWidth, self.scrollView.bounds.size.height);
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    //初始坐标
    CGFloat YPositon = self.scrollView.bounds.size.height/2 - TYPE_ITEM_Height/2;
    CGFloat XPostion = TYPE_ITEM_ORIGIN_X;
    for (int i = 0; i < [typeModelArray count]; i++) {
        MachineTypeModel *type = typeModelArray[i];
        UIButton *button = [[UIButton alloc]init];
        CGSize titleSize = [type.name sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:button.titleLabel.font.fontName size:button.titleLabel.font.pointSize]}];
        titleSize.height = TYPE_ITEM_Height;
        titleSize.width += 20;
        [button setTitle:type.name forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
        [button setTitleColor:UIColorFromHex(0X212121) forState:UIControlStateNormal];
        [button setBackgroundColor:UIColorFromHex(0xf8f8f8)];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 5.0f;
        
        button.tag = [type.typeCode integerValue];
        button.frame = CGRectMake(XPostion, YPositon, titleSize.width, titleSize.height);
        [button addTarget:self action:@selector(selectDevice:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        XPostion = CGRectGetMaxX(button.frame) + TYPE_ITEM_INTERVAL;
        
        contentsizeWidth += titleSize.width +TYPE_ITEM_INTERVAL;

    }
    //根据button更新scrollview的宽度
    self.scrollView.contentSize = CGSizeMake(contentsizeWidth, self.scrollView.bounds.size.height);
    MachineTypeModel *firstType = typeModelArray[0];
    UIButton *firstButton = [self.scrollView viewWithTag:[firstType.typeCode integerValue]];
    [self selectDevice:firstButton];

}
- (void)selectDevice:(UIButton *)sender {
    
    selectedDeviceTag = [sender tag];
    for (MachineTypeModel *type in typeModelArray) {
        UIButton *btn = (UIButton *)[self.scrollView viewWithTag:[type.typeCode integerValue]];
        //配置选中按钮
        if ([btn tag] == [(UIButton *)sender tag]) {
            btn.backgroundColor = UIColorFromHex(0x6DA3E0);
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            btn.backgroundColor = UIColorFromHex(0xf8f8f8);
            [btn setTitleColor:UIColorFromHex(0x212121) forState:UIControlStateNormal];
        }
    }
    [self refresh];
}
#pragma mark - TableView datasource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_datas count];
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"Cell";
    AddMachineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[AddMachineCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if ([self.datas count] > 0) {
        NSDictionary *dataDic = [self.datas objectAtIndex:indexPath.row];
        [cell.ringButton setTitle:[dataDic objectForKey:@"Cpuid"] forState:UIControlStateNormal];
        [cell.ringButton addTarget:self action:@selector(ringAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.nameTextField.text = dataDic[@"Name"];
        
        NSArray *departmentList = [Constant sharedInstance].departmentList;
        if ([departmentList count]>0) {
            DepartmentModel *department = departmentList[0];
            cell.departmentNameLabel.text = department.name ;
        }

        [cell.departmentView addTapBlock:^(id obj) {
            ChooseDepartmentView  *view = [[ChooseDepartmentView alloc]initWithDic:@{@"department":cell.departmentNameLabel.text} return:^(NSString *selectedUuid) {
                cell.departmentNameLabel.text = [[Constant sharedInstance]departmentDic][selectedUuid];
                
            }];
            [view showInWindowWithBackgoundTapDismissEnable:YES];
        }];
       
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - Action
- (void)ringAction :(id)sender {
    AddMachineCell *cell = (AddMachineCell *)[[sender superview]superview];
    NSString *cpuid = cell.ringButton.titleLabel.text;
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/Beep")
                                  params:@{
                                           @"Cpuid":cpuid,
                                           @"LongBeep":@0
                                           }
                                hasToken:YES success:^(HttpResponse *responseObject) {
                                    
                                } failure:nil];
}
- (IBAction)save:(id)sender {
    NSArray *cells = self.tableView.visibleCells;
    NSMutableArray *saveArray = [NSMutableArray array];
    
    if ([cells count] > 0) {
        for (AddMachineCell *cell in cells) {
            if (cell.nameTextField.text.length > 0) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:20];
                [dic setObject:cell.ringButton.titleLabel.text forKey:@"Cpuid"];
                [dic setObject:cell.nameTextField.text forKey:@"DeviceName"];
                NSString *departmentName = cell.departmentNameLabel.text;
                
                
                NSString *uuid = [[Constant sharedInstance]departmentOppositeDic][departmentName];
                [dic setObject:uuid forKey:@"DepartmentId"];
                [saveArray addObject:dic];
            }
        }
        if ([saveArray count]>0) {
            [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/Register")
                                          params:@{@"ListData":saveArray}
                                        hasToken:YES
                                         success:^(HttpResponse *responseObject) {
                                             if ([responseObject.result integerValue] == 1) {
                                                 [BEProgressHUD showMessage:@"录入成功"];
                                                 [self refresh];
                                             }
                                         }
                                         failure:nil];
        }
 
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
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [[NSMutableArray alloc]init];
    }
    return _datas;
}
@end
