//
//  SingleViewAirWaveCell.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/15.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirWaveView.h"
typedef NS_ENUM(NSInteger,CellStyle) {
    CellStyleOnline,
    CellStyleOffLine,
    CellStyleAlert,
    CellStyleUnauthorized
};
@interface SingleViewAirWaveCell : UICollectionViewCell
@property (nonatomic, assign) CellStyle style;
//@property (nonatomic, assign) AirBagType type;

@property (weak, nonatomic) IBOutlet UIView *bodyContentView;
@property (weak, nonatomic) IBOutlet UIButton *patientButton;
@property (weak, nonatomic) IBOutlet UIView *parameterView;

/** alert */
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *alertMessageLabel;
@property (nonatomic,strong)NSTimer *alertTimer;
-(void)startFlashingAlertView;
/** controll button */
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

- (void)configureWithCellStyle:(CellStyle)style AirBagType:(AirBagType)type message:(NSString *)message;
@end
