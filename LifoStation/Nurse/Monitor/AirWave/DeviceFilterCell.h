//
//  DeviceFilterCell.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/2/15.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceFilterCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrow;

@end
