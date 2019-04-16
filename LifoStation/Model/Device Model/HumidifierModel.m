//
//  SHIHUAModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/12.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "HumidifierModel.h"

@implementation HumidifierModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
             @"state":@"State",
             @"treatTime":@"TreatTime",
             @"showTime":@"ShowTime",
             @"temperature":@"Temperature",
             @"flow":@"Traffic",
             @"oxygen":@"OxygenRatio"
 
             }];
}
- (NSArray *)getParameterArray {
    NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
    [paramArray addObject:[NSString stringWithFormat:@"湿度:%@L/min",self.flow]];
    [paramArray addObject:[NSString stringWithFormat:@"氧浓度:%@%%",self.oxygen]];
    if (self.showTime) {
        //实时包温度 服务器传过来是乘以10了 解析的时候要除以10处理
        NSInteger temperature = [self.temperature integerValue];
        //保留一位小数
        [paramArray addObject:[NSString stringWithFormat:@"温度:%.1f℃",temperature/10.0]];
    } else {
        [paramArray addObject:[NSString stringWithFormat:@"温度:%@℃",self.temperature]];
    }


    return paramArray ;
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end
