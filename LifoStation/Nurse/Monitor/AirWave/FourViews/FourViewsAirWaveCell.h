//
//  FourViewsAirWaveCell.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/18.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirWaveView.h"
@interface FourViewsAirWaveCell : UICollectionViewCell
@property (nonatomic, assign) AirBagType type;

@property (weak, nonatomic) IBOutlet AirWaveView *bodyView;

@property (weak, nonatomic) IBOutlet UIView *bodyContentView;
@property (weak, nonatomic) IBOutlet UIButton *patientButton;
@property (weak, nonatomic) IBOutlet UIView *focusView;

- (void)configureWithAirBagType:(AirBagType)type;
@end
