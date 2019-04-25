//
//  MagneticModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/25.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MagneticModel.h"

@implementation MagneticModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"state":@"State",
              @"treatTime":@"TreatTime",
              @"showTime":@"ShowTime",
              @"solution":@"Solution",
              @"temperature":@"Temperature"
              }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end
