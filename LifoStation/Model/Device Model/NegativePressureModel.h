//
//  NegativePressureModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/22.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
typedef NS_ENUM(NSInteger,NegativePressureWorkMode)
{
    NegativePressureWorkMode_Continue = 0,//连续
    NegativePressureWorkMode_Interval = 1,//间歇
    NegativePressureWorkMode_Dynamic = 2//动态
};
typedef NS_ENUM(NSInteger,NegativePressureWorkState)
{
    NegativePressureWorkState_Drainage = 0,//引流
    NegativePressureWorkState_Soak = 1,//浸泡
    NegativePressureWorkState_Wash = 2//清洗
};
/** 大负压 */
@interface NegativePressureModel : JSONModel
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *treatTime;
@property (nonatomic, strong) NSString *showTime;

@property (nonatomic, assign) NSInteger solution;//方案 ABC没有倒计时 DEF有倒计时
@property (nonatomic, assign) NSInteger workMode;//工作模式 连续间隔动态
@property (nonatomic, strong) NSString *workModeString;
@property (nonatomic, assign) NSInteger workState;//工作状态 引流浸泡清洗
@property (nonatomic, strong) NSString *workStateString;
@property (nonatomic, strong) NSString *pressure;//创面压力

@property (nonatomic, assign) BOOL hasLeftTime;
- (NSArray *)getParameterArray;
- (NSString *)getTimeShowingText;

@end
