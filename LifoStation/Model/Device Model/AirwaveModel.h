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
typedef NS_ENUM(NSUInteger,AirbagState){
    AirbagState_UnWorking       = 0,
    AirbagState_Working         = 1,
    AirbagState_KeepingAir      = 2
};
/** 气囊类型 */
typedef NS_ENUM(NSInteger,AirbagType){
    AirbagType_Leg3         = 0,
    AirbagType_Arm3         = 1,
    AirbagType_Leg4         = 2,
    AirbagType_Arm4         = 3,
    AirbagType_Abdomen      = 4,
    AirbagType_Leg6         = 5,
    AirbagType_Leg8         = 6,
    AirbagType_HandRecovery = 7,
    AirbagType_Hand1        = 8,
    AirbagType_Foot1        = 9,
    AirbagType_Unconnected  = 10
};
@interface AirwaveModel : JSONModel
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *treatTime;
@property (nonatomic, strong) NSString *showTime;

@property (nonatomic, strong) NSArray<NSNumber *> *press;
@property (nonatomic, assign) NSInteger APortType;
@property (nonatomic, assign) NSInteger BPortType;

//实时信息
@property (nonatomic, strong) NSString *currentPress;
@property (nonatomic, strong) NSArray *portState;
//血液回盈时间
@property (nonatomic, strong) NSString *backTime;

- (NSArray *)getParameterArray;
@end
