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
    CellStyleAlert
};
@interface SingleViewAirWaveCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *patientButton;
@property (weak, nonatomic) IBOutlet AirWaveView *bodyView;
@property (weak, nonatomic) IBOutlet UIView *bodyContentView;
@property (nonatomic, assign) CellStyle style;
@property (weak, nonatomic) IBOutlet UIView *parameterView;

- (void)configureWithCellStyle:(CellStyle)style AirBagType:(AirBagType)type;
@end
