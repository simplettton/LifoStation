//
//  DepartmentModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/12.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DepartmentModel.h"

@implementation DepartmentModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"name":@"Name",
              @"uuid":@"Uid"
              }];
}
@end