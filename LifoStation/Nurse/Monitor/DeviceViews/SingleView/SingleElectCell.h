//
//  SingleElectCell.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/27.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
#import "MachineModel.h"
@interface SingleElectCell : UICollectionViewCell
@property (nonatomic, assign) CellStyle style;
//1 左上
@property (weak, nonatomic) IBOutlet UIView *patientView;
@property (weak, nonatomic) IBOutlet UILabel *patientLabel;
@property (weak, nonatomic) IBOutlet UIButton *patientButton;

//2 左下
@property (weak, nonatomic) IBOutlet UIView *focusView;
@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
//中间视图
@property (nonatomic, strong) FLAnimatedImageView *deviceView;
@property (nonatomic, strong) UIImageView *staticDeviceView;
//3右下
@property (nonatomic, strong) AAChartView *chartView;
@property (nonatomic, strong) MachineModel *machine;
- (void)configureWithModel:(MachineModel *)machine;
- (void)updateDeviceImage:(NSString *)name;
@end
