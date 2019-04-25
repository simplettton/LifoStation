//
//  TwoElectCell.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/28.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
#import "MachineModel.h"
@interface TwoElectCell : UICollectionViewCell;
@property (nonatomic, assign) CellStyle style;
//1 左上
@property (weak, nonatomic) IBOutlet UIView *patientView;
@property (weak, nonatomic) IBOutlet UILabel *patientLabel;
@property (weak, nonatomic) IBOutlet UIButton *patientButton;

//2 左下
@property (weak, nonatomic) IBOutlet UIView *focusView;
@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;

@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (nonatomic, strong) FLAnimatedImageView *deviceView;
@property (nonatomic, strong) UIImageView *staticDeviceView;

//3右下
@property (nonatomic, strong) AAChartView *chartView;


@property (nonatomic, strong) MachineModel *machine;
- (void)configureWithModel:(MachineModel *)machine;
- (void)updateDeviceImage:(NSString *)name;
@end
