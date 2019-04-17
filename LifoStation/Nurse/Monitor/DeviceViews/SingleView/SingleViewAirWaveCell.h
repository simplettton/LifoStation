//
//  SingleViewAirWaveCell.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/15.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirWaveView.h"

@interface SingleViewAirWaveCell : UICollectionViewCell
@property (nonatomic, assign) CellStyle style;

@property (weak, nonatomic) IBOutlet UIView *bodyContentView;
//1 左上
@property (weak, nonatomic) IBOutlet UIView *patientView;
@property (weak, nonatomic) IBOutlet UILabel *patientLabel;
@property (weak, nonatomic) IBOutlet UIButton *patientButton;
//2 右上
@property (weak, nonatomic) IBOutlet UIView *parameterView;

/** 3 alert */
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *alertMessageLabel;
@property (nonatomic,strong)NSTimer *alertTimer;

//4 左下
@property (weak, nonatomic) IBOutlet UIView *focusView;
@property (weak, nonatomic) IBOutlet UILabel *leftTimeLabel;


@property (strong, nonatomic) AirWaveView *bodyView;
- (void)configureWithAirBagType:(AirBagType)type message:(NSString *)message;
- (void)configureWithCellStyle:(CellStyle)style airBagType:(AirBagType)type message:(NSString *)message;
@end
