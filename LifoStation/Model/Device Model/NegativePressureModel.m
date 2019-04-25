//
//  NegativePressureModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/22.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "NegativePressureModel.h"

@implementation NegativePressureModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"state":@"State",
              @"treatTime":@"TreatTime",
              @"showTime":@"ShowTime",
              @"solution":@"Solution",
              @"workMode":@"WorkMode",
              @"workState":@"WorkState",
              @"pressure":@"FacePressure"
              }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
- (NSArray *)getParameterArray {
    NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
    [paramArray addObject:[NSString stringWithFormat:@"%@mmHg",self.pressure]];
    [paramArray addObject:self.workStateString];
    return [paramArray copy];
}
- (NSString *)workStateString {
    switch (self.workState) {
        case NegativePressureWorkState_Drainage:
            return @"引流模式";
            break;
        case NegativePressureWorkState_Soak:
            return @"浸泡模式";
            break;
        case NegativePressureWorkState_Wash:
            return @"清洗模式";
            break;
        default:
            return nil;
            break;
    }
}
- (NSString *)workModeString {
    switch (self.workMode) {
        case NegativePressureWorkMode_Continue:
            return @"连续模式";
            break;
        case NegativePressureWorkMode_Dynamic:
            return @"动态模式";
            break;
        case NegativePressureWorkMode_Interval:
            return @"间隔模式";
            break;
        default:
            return nil;
            break;
    }
}
- (NSString *)getTimeShowingText {
    switch (self.solution) {
        case 0xA:
            return @"连续模式";
            break;
        case 0xB:
            return @"间隔模式";
            break;
        case 0xC:
            return @"动态模式";
            break;
        case 0xD:
        case 0xE:
        case 0xF:
            return self.showTime;
            break;
            
        default:
            return nil;
            break;
    }
}
- (BOOL)hasLeftTime {
    switch (self.solution) {
        case 0xA:
        case 0xB:
        case 0xC:
            return NO;
            break;
        case 0xD:
        case 0xE:
        case 0xF:
            return YES;
            break;
            
        default:
            return NO;
            break;
    }
}
@end
