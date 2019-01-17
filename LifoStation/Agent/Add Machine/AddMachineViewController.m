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

#define TYPE_ITEM_ORIGIN_X 20
#define TYPE_ITEM_Height 30
#define TYPE_ITEM_INTERVAL 48
@interface AddMachineViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
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
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.navigationItem.hidesBackButton = YES;
    [self initMachineTypeScrollView];
}
- (IBAction)backToMachineList:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}
#pragma mark - ScrollView
- (void)initMachineTypeScrollView {
    
    NSMutableArray *typeList = [NSMutableArray arrayWithObjects:@{@"name":@"空气波治疗仪"},@{@"name":@"光子治疗仪"},@{@"name":@"中频电治疗仪"},@{@"name":@"脉冲磁"},@{@"name":@"红外设备"},@{@"name":@"湿化"},@{@"name":@"负压"},nil];
    typeModelArray = [[NSMutableArray alloc]initWithCapacity:20];
    
    CGFloat contentsizeWidth = TYPE_ITEM_ORIGIN_X;
    for (NSDictionary *dataDic in typeList) {
        NSError *error;

        MachineTypeModel *type = [[MachineTypeModel alloc]initWithDictionary:dataDic error:&error];
        [typeModelArray addObject:type];
        contentsizeWidth += type.titleWidth + TYPE_ITEM_ORIGIN_X +TYPE_ITEM_INTERVAL;
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
        
        button.tag = 1000 + i;
        button.frame = CGRectMake(XPostion, YPositon, titleSize.width, titleSize.height);
        [button addTarget:self action:@selector(selectDevice:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        XPostion = CGRectGetMaxX(button.frame) + TYPE_ITEM_INTERVAL;

    }
    UIButton *firstButton = [self.scrollView viewWithTag:1000];
    [self selectDevice:firstButton];

}
-(void)selectDevice:(UIButton *)sender {
    
    selectedDeviceTag = [sender tag];
    
    for (int i = 1000; i<1000 + [typeModelArray count]; i++) {
        UIButton *btn = (UIButton *)[self.scrollView viewWithTag:i];
        //配置选中按钮
        if ([btn tag] == [(UIButton *)sender tag]) {
            btn.backgroundColor = UIColorFromHex(0x6DA3E0);
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            btn.backgroundColor = UIColorFromHex(0xf8f8f8);
            [btn setTitleColor:UIColorFromHex(0x212121) forState:UIControlStateNormal];
        }
    }
}
#pragma mark - TableView datasource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"Cell";
    AddMachineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[AddMachineCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //    cell.editButton.tag = indexPath.row;
    [cell.ringButton addTarget:self action:@selector(ringAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.departmentView addTapBlock:^(id obj) {
        ChooseDepartmentView  *view = [[ChooseDepartmentView alloc]initWithDic:@{@"department":cell.departmentNameLabel.text} return:^(NSString *selectedDepartment) {
            NSLog(@"选择了%@",selectedDepartment);
            
            cell.departmentNameLabel.text = selectedDepartment;
        }];
        [view showInWindow];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)ringAction :(id)sender {
    
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

@end
