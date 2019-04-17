//
//  AirwaveModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/16.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

/** 治疗方法 */
typedef NS_ENUM(NSInteger,AirWaveTreatWay){
    AirWaveTreatWay_Standard  = 1,
    AirWaveTreatWay_Gradient  = 2,
    AirWaveTreatWay_Parameter = 3,
    AirWaveTreatWay_Solution  = 4
};
/** AB优先级 */
typedef NS_ENUM(NSInteger,ABPriority){
    ABPriority_AFirst = 0,
    ABPriority_BFirst = 1,
    ABPriority_ABTogether = 2
};
/** 梯度等级 */
typedef NS_ENUM(NSInteger,GradientLevel){
    GradientLevel_Custom         = 0,
    GradientLevel_FirstLevel     = 1,
    GradientLevel_SecondLevel    = 2,
    GradientLevel_ThirdLevel     = 3
};
/** 气囊状态 */
typedef NS_ENUM(NSUInteger,AirPortState){
    AirPortState_UnWorking       = 0,
    AirPortState_Working         = 1,
    AirPortState_KeepingAir      = 2
};
/** 气囊类型 */
typedef NS_ENUM(NSInteger,AirPortType){
    AirPortType_Leg3         = 0,
    AirPortType_Arm3         = 1,
    AirPortType_Leg4         = 2,
    AirPortType_Arm4         = 3,
    AirPortType_Abdomen      = 4,
    AirPortType_Leg6         = 5,
    AirPortType_Leg8         = 6,
    AirPortType_HandRecovery = 7,
    AirPortType_Hand1        = 8,
    AirPortType_Foot1        = 9,
    AirPortType_Unconnected  = 10
};
@interface AirwaveModel : JSONModel
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *treatTime;
@property (nonatomic, strong) NSString *showTime;

@property (nonatomic, strong) NSArray<NSNumber *> *press;//设定压力值 （显示只取最大值）实时包参数包共有
@property (nonatomic, assign) NSInteger APortType;//A气囊类型
@property (nonatomic, assign) NSInteger BPortType;//B气囊类型
@property (nonatomic, strong) NSArray<NSNumber*> *portEnable;//气囊使能(对应规则，从左到右，从下到上)

//实时信息
@property (nonatomic, strong) NSString *currentPress;//当前腔压力
@property (nonatomic, strong) NSArray *portState;//各腔充气状态
@property (nonatomic, strong) NSString *backTime;//血液回盈时间

- (NSArray *)getParameterArray;
@end
