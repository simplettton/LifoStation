//
//  FourElectCell.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/20.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
#import "MachineModel.h"
@interface FourElectCell : UICollectionViewCell
@property (nonatomic, assign) CellStyle style;
//1 左上
@property (weak, nonatomic) IBOutlet UIView *patientView;
@property (weak, nonatomic) IBOutlet UILabel *patientLabel;
@property (weak, nonatomic) IBOutlet UIButton *patientButton;
//2 左下
@property (weak, nonatomic) IBOutlet UIView *focusView;
@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;

@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *middleView;
@property (nonatomic, strong) FLAnimatedImageView *deviceView;
- (void)configureWithCellStyle:(CellStyle)style machineType:(NSInteger)typdeCode dataDic:(NSDictionary *)dic message:(NSString *)message;
- (void)configureWithModel:(MachineModel *)machine;
@end
