//
//  DepartmentDeviceModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/30.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DepartmentDeviceModel.h"

@implementation DepartmentDeviceModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:@{
                                                                 @"department":@"Department",
                                                                 @"departmentId":@"DepartmentId",
                                                                 @"devices":@"Group"
                                                                 }];
}
@end
