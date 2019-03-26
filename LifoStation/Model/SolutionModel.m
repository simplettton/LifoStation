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
        @"treatTime":@"TreatTime"
        }];
}
@end
