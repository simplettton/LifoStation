//
//  GUANGZIModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/12.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "LightModel.h"

@implementation LightModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"state":@"State",
              @"treatTime":@"TreatTime",
              @"temperature":@"Temperature",
              @"showTime":@"ShowTime",
              @"energyLevel":@"Power",
              @"dosage":@"PowerPercent",
              @"mainLightSource":@"MainLightSource",
              @"appendLightSource":@"AppendLightSource",
              @"isTemperatureOpen":@"IsTemperatureOpen"
              }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
- (NSArray *)getParameterArray {
    NSArray *lightSource = @[@"无",@"红光",@"蓝光",@"红蓝光"];
    NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
    [paramArray addObject:[NSString stringWithFormat:@"附件光源:%@",lightSource[self.appendLightSource]]];
    [paramArray addObject:[NSString stringWithFormat:@"温度:%@℃",self.temperature]];
    [paramArray addObject:[NSString stringWithFormat:@"能量:%@",self.energyLevel]];
    [paramArray addObject:[NSString stringWithFormat:@"剂量:%@J/cm²",self.dosage]];
    return paramArray ;
}
- (NSString *)getLightName {
    NSInteger lightSource;
    /** 主光源为空的时候显示附件光源 */
    if (self.mainLightSource != LightSourceNull)
    {
        lightSource = self.mainLightSource;
    } else {
        lightSource = self.appendLightSource;
    }
    switch (lightSource) {
        case LightSourceNull:
            return @"rlight";
            break;
        case LightSourceRed:
            return @"rlight";
            break;
        case LightSourceBlue:
            return @"blight";
            break;
            //红蓝光是先蓝光
        case LightSourceRedAndBlue:
            return @"blight";
            break;
        default:
            return nil;
            break;
    }
}
@end
