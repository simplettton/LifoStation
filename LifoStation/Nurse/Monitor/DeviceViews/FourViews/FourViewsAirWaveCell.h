//
//  FourViewsAirWaveCell.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/18.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirWaveView.h"
#import "FLAnimatedImage.h"
@interface FourViewsAirWaveCell : UICollectionViewCell
@property (nonatomic, assign) AirBagType type;
@property (weak, nonatomic) IBOutlet AirWaveView *bodyView;
@property (nonatomic, strong) AirWaveView *deviceView;


//@property (strong, nonatomic) AirWaveView *bodyView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *bodyContentView;
@property (weak, nonatomic) IBOutlet UIButton *patientButton;
@property (weak, nonatomic) IBOutlet UIView *focusView;
@property (weak, nonatomic) IBOutlet UIView *patientView;

- (void)configureWithAirBagType:(AirBagType)type;
- (void)configureWithCellStyle:(CellStyle)style machineType:(NSInteger)typdeCode dataDic:(NSDictionary *)dic message:(NSString *)message;
@end
