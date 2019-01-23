//
//  AirWaveView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/17.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,AirBagType) {
    AirBagTypeThree,
    AirBagTypeEight
};
@interface AirWaveView : UIView
@property (nonatomic, assign) AirBagType type;
- (instancetype)initWithAirBagType:(AirBagType)type;
@property (strong, nonatomic) UIView *bodyView;

@end
