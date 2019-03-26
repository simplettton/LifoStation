//
//  RecordCell.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/3.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *medicalNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *machineTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatmentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatDateLabel;
@end
