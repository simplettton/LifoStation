//
//  AirwaveModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/16.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AirwaveModel.h"

@implementation AirwaveModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
      @{
        @"state":@"State",
        @"treatTime":@"TreatTime",
        @"showTime":@"ShowTime",
        
        @"press":@"Press",
        @"APortType":@"AportType",
        @"BPortType":@"BPortType",
        
        @"currentPress":@"CurrentPress",
        @"portState":@"PortState",
        @"backTime":@"BackToFullTime"
      }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
- (NSArray *)getParameterArray {
    NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
    //解析压力值
    if (self.currentPress) {
        [paramArray addObject:[NSString stringWithFormat:@"%@mmHg",self.currentPress]];
        [paramArray addObject:[NSString stringWithFormat:@"%@min",self.backTime]];
    } else {
        //求press数组中的最大值当做设置的压力值 因为梯度模式8个压力值不一致 高级参数模式 8个值都是自定义的
        int max = [[self.press valueForKeyPath:@"@max.intValue"]intValue];
        [paramArray addObject:[NSString stringWithFormat:@"%dmmHg",max]];
    }
    return paramArray;
}

@end
