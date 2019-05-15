//
//  TaskCell.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/26.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TaskCell.h"

@implementation TaskCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //设置治疗方案按钮的样式
    [self.treatmentButton setBackgroundColor:UIColorFromHex(0xf0f0f0)];
    [self.treatmentButton.layer setMasksToBounds:YES];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.treatmentButton.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = self.treatmentButton.bounds;
    maskLayer.path = maskPath.CGPath;
    self.treatmentButton.layer.mask = maskLayer;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (BOOL)canBecomeFirstResponder {
    return YES;
}
@end
