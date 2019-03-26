//
//  TaskModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/13.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TaskModel.h"

@implementation TaskModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"uuid":@"Uid",
              @"state":@"State",
              @"creatTime":@"CreatTime",
              @"finishTime":@"FinishTime",
              
              @"patient":@"Patient",
              @"creatorName":@"CreatorName",
              @"operatorName":@"OperatorName",
              @"suggest":@"Suggest",
              
              @"machine":@"Device",
              @"leftTime":@"LeftTimeToOver",
              @"solution":@"Solution"
              }
            ];
}
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}
@end
