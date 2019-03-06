//
//  TreatParameterCell.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/2/27.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TreatParameterCell.h"

@implementation TreatParameterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.borderView.layer.borderWidth = 0.5f;
    self.borderView.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
    self.valueLabel.preferredMaxLayoutWidth = self.valueLabel.frame.size.width;
    self.valueLabel.numberOfLines = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
