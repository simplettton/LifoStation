//
//  FilterDeviceModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/30.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "FilterDeviceModel.h"

@implementation FilterDeviceModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:@{
                                                                 @"deviceGroup":@"DeviceGroup",
                                                                 @"nameList":@"DeviceList",
                                                                 @"groupName":@"GroupName"
                                                                 }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end
