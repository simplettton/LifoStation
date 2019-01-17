//
//  AddMachineCell.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/7.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddMachineCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *ringButton;
@property (weak, nonatomic) IBOutlet UIView *departmentView;
@property (weak, nonatomic) IBOutlet UILabel *departmentNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end
