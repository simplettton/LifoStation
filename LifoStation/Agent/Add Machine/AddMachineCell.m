//
//  AddMachineCell.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/7.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddMachineCell.h"

@implementation AddMachineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.ringButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
