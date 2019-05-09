//
//  MagneticModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/25.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
/** 脉冲磁 */
@interface MagneticModel : JSONModel
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *treatTime;
@property (nonatomic, strong) NSString *showTime;
@property (nonatomic, strong) NSString *temperature;//温度

@property (nonatomic, strong) NSArray<NSNumber *> *coilTypeArray;//线圈类型
@property (nonatomic, strong) NSArray<NSNumber *> *treatTimeArray;//治疗时间 min
@property (nonatomic, strong) NSArray<NSNumber *> *stateArray;//通道状态（6个独立）
@property (nonatomic, strong) NSArray<NSNumber *> *temperatureArray;//温度 *100后发送
@property (nonatomic, strong) NSArray<NSNumber *> *showTimeArray;//显示时间s

- (NSArray *)getParameterArray;
+ (NSString *)getShowingTimeWithRunningParameter:(MagneticModel *)runningParameter treatParameter:(MagneticModel *)treatParameter;
@end
