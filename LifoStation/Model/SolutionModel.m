//
//  SolutionModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/18.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "SolutionModel.h"

@implementation SolutionModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
      @{
        @"name":@"Name",
        @"uuid":@"Uid",
        @"machineType":@"MachineType",
        @"machineTypeName":@"MachineName",
        @"treatTime":@"TreatTime",
        @"mainModeName":@"MainModeName",
        @"note":@"Note",
        @"originalParamList":@"LsEdit",
        @"paramList":@"LsParam"
        }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end
