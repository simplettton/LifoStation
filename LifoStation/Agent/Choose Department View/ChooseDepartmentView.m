//
//  ChooseDepartmentView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/4.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ChooseDepartmentView.h"
#import "UIView+TYAlertView.h"
#import "DepartmentItemCell.h"
@interface ChooseDepartmentView()

@end
@implementation ChooseDepartmentView {
    NSMutableArray *datas;
}
- (instancetype)initWithDic:(NSDictionary *)dic return:(returnBlock)returnEvent {
    if (self = [super init]) {
        NSString *name = [dic objectForKey:@"department"];
        NSArray *departmentArray = @[@"疼痛科",@"神经科",@"中医科",@"肿瘤科",@"康复科",@"呼吸内科",@"营养科"];
        ChooseDepartmentView *view = [ChooseDepartmentView createViewFromNib];
        view.selectedIndex = [departmentArray indexOfObject:name];
        //scrollview滑动至选中的
        [view.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:view.selectedIndex inSection:0];
            [view.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        });
        view.returnEvent = returnEvent;
        return view;
    }
    return self;
}

- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initAll];
}
- (void)initAll {
    self.tableView.tableFooterView = [[UIView alloc]init];
    datas = [[NSMutableArray alloc]initWithCapacity:20];
    datas = [NSMutableArray arrayWithObjects:@"疼痛科",@"神经科",@"中医科",@"肿瘤科",@"康复科",@"呼吸内科",@"营养科",nil];
    if (self.selectedIndex) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}
#pragma mark - tableview datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42.5;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [datas count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DepartmentItemCell *cell = [[NSBundle mainBundle]loadNibNamed:@"ChooseDepartmentView" owner:self options:nil].lastObject;
    cell.selectionImageView.hidden = (indexPath.row == self.selectedIndex? NO :YES);
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = UIColorFromHex(0xF8F8F8);
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.departmentLabel.text = datas[indexPath.row];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
    [self.tableView reloadData];
    self.returnEvent(datas[indexPath.row]);
    [self hideView];
    
    
    
}

@end
