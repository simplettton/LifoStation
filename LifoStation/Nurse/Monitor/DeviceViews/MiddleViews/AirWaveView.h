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
    leftup1tag   =1017,leftup2tag   =1016,leftup3tag   =1015,lefthandtag  =1014,leftdown1tag =1013,leftdown2tag =1012,leftdown3tag =1011,
    leftfoottag  =1010,rightup1tag  =1027,rightup2tag  =1026,rightup3tag  =1025,righthandtag =1024,rightdown1tag=1023,rightdown2tag=1022,
    rightdown3tag=1021,rightfoottag =1020,middle1tag   =1033,middle2tag   =1032,middle3tag   =1031,middle4tag   =1030,
    
    rightleg1tag =47,rightleg2tag =46,rightleg3tag =45,rightleg4tag =44,rightleg5tag =43,rightleg6tag =42,rightleg7tag =41,
    leftleg1tag  =1007,leftleg2tag  =1006,leftleg3tag  =1005,leftleg4tag  =1004,leftleg5tag  =1003,leftleg6tag  =1002,leftleg7tag  =1001, disconnectViewtag = 999
    
};
typedef NS_ENUM(NSUInteger,BodyIndex)
{
    leftfootIndex=0, leftup3Index=5, leftdown3Index=1, lefthandIndex=4, middle4Index=8, rightfootIndex=12, rightup3Index=17, rightdown3Index = 13, righthandIndex = 16
};
@interface AirWaveView : UIView
@property (nonatomic, assign) AirBagType type;

@property (strong, nonatomic) UIView *bodyView;
@property (strong, nonatomic) IBOutletCollection(BodyImageView) NSArray *bodyImages;
@property (nonatomic, assign) NSInteger APortType;
@property (nonatomic, assign) NSInteger BPortType;
- (instancetype)initWithParameter:(AirwaveModel*)machineParameter;
- (void)resetBodyPartColor:(MachineModel *)machine;
- (void)updateViewWithModel:(MachineModel *)machine;
- (void)changeAllBodyPartsToGrey;
@end
