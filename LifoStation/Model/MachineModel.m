//
//  MachineModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/14.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MachineModel.h"

@implementation MachineModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
     @{
       @"cpuid":@"Cpuid",
       @"name":@"Name",
       @"type":@"MachineType",
       @"groupCode":@"DeviceGroup",
       @"state":@"MachineState",
       @"leftTime":@"LeftTimeToOver",
       @"hasLicense":@"HasLicense",
       @"isfocus":@"IsFocus",
       @"isonline":@"IsOnline",
       @"departmentId":@"DepartmentId",
       @"departmentName":@"DepartmentName",
       @"patient":@"Patient"
       }];
}
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
@end
