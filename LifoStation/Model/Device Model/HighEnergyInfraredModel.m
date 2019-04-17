//
//  HighEnergyInfraredModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/17.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "HighEnergyInfraredModel.h"

@implementation HighEnergyInfraredModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"state":@"State",
              @"treatTime":@"TreatTime",
              @"showTime":@"ShowTime",
              @"workMode":@"WorkMode"
              }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
- (NSArray *)getParameterArray {
    NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
    [paramArray addObject:[NSString stringWithFormat:@"工作模式:%@",self.workMode]];
    return [paramArray copy];
}
@end
