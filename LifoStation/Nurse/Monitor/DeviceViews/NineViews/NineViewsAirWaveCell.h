//
//  NineViewsAirWaveCell.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/18.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirWaveView.h"
#import "MachineModel.h"
@interface NineViewsAirWaveCell : UICollectionViewCell

//1 左上
@property (weak, nonatomic) IBOutlet UILabel *patientLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UILabel *treatAddressLabel;
//2 左下
@property (weak, nonatomic) IBOutlet UIView *focusView;
@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
//中央视图
@property (nonatomic, strong) AirWaveView *deviceView;
@property (nonatomic, assign) CellStyle style;
@property (nonatomic, strong) MachineModel *machine;
- (void)configureWithModel:(MachineModel *)machine;
@end
