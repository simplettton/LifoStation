//
//  SingleViewAirWaveCell.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/15.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirWaveView.h"
#import "MachineModel.h"
@interface SingleViewAirWaveCell : UICollectionViewCell
@property (nonatomic, assign) AirBagType type;
//1 左上
@property (weak, nonatomic) IBOutlet UIView *patientView;
@property (weak, nonatomic) IBOutlet UILabel *patientLabel;
@property (weak, nonatomic) IBOutlet UIButton *patientButton;

//2 左下
@property (weak, nonatomic) IBOutlet UIView *focusView;
@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
//中央视图
@property (nonatomic, strong) AirWaveView *deviceView;
@property (nonatomic, strong) MachineModel *machine;
@property (nonatomic, assign) CellStyle style;

- (void)configureWithModel:(MachineModel *)machine;
@end
