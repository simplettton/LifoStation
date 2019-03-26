//
//  TaskDetailView.h
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/27.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskModel.h"
@interface TaskDetailView : UIView
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@property (weak, nonatomic) IBOutlet UILabel *treatAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *medicalNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatDateLabel;

@property (nonatomic, strong) TaskModel *model;
-(instancetype)initWithModel:(TaskModel *)model;
@end
