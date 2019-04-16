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
              @"appendLightSource":@"AppendLightSource"
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
    [paramArray addObject:[NSString stringWithFormat:@"能量:%@%%",self.energyLevel]];
    [paramArray addObject:[NSString stringWithFormat:@"剂量:%@J/cm²",self.dosage]];
    return paramArray ;
}
@end
