//
//  TimeLineModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/10.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TimeLineModel.h"

@implementation TimeLineModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:@{
                                                                 @"title":@"Msg",
                                                                 @"timeStamp":@"Time"
                                                                 }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end
