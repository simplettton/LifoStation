//
//  AirWaveView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/17.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BodyImageView.h"
#import "AirwaveModel.h"
#import "MachineModel.h"

typedef NS_ENUM(NSInteger,AirBagType) {
    AirBagTypeThree,
    AirBagTypeEight
};
typedef NS_ENUM(NSUInteger,BodyTags)
{
    leftup1tag   =17,leftup2tag   =16,leftup3tag   =15,lefthandtag  =14,leftdown1tag =13,leftdown2tag =12,leftdown3tag =11,
    leftfoottag  =10,rightup1tag  =27,rightup2tag  =26,rightup3tag  =25,righthandtag =24,rightdown1tag=23,rightdown2tag=22,
    rightdown3tag=21,rightfoottag =20,middle1tag   =33,middle2tag   =32,middle3tag   =31,middle4tag   =30,
    
    rightleg1tag =47,rightleg2tag =46,rightleg3tag =45,rightleg4tag =44,rightleg5tag =43,rightleg6tag =42,rightleg7tag =41,
    leftleg1tag  =57,leftleg2tag  =56,leftleg3tag  =55,leftleg4tag  =54,leftleg5tag  =53,leftleg6tag  =52,leftleg7tag  =51, disconnectViewtag = 999
    
};
@interface AirWaveView : UIView
@property (nonatomic, assign) AirBagType type;

@property (strong, nonatomic) UIView *bodyView;
@property (strong, nonatomic) IBOutletCollection(BodyImageView) NSArray *bodyImages;
@property (nonatomic, assign) NSInteger APortType;
@property (nonatomic, assign) NSInteger BPortType;
- (void)flashingTest;
- (instancetype)initWithAirBagType:(AirBagType)type;
- (instancetype)initWithParameter:(AirwaveModel*)machineParameter;
- (void)updateViewWithModel:(MachineModel *)machine;

@end
