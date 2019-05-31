//
//  SputumExcretionModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/24.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "SputumExcretionModel.h"

@implementation SputumExcretionModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
                            @{
                              @"state":@"State",
                              @"outPhlemState":@"OutPhlegmState",
                              @"fuzzyState":@"FuzzyState",
                              @"attractState":@"AttractState",
                              
                              @"outPhlemShowTime":@"ShowTime_OutPhledm",
                              @"fuzzyShowTime":@"ShowTime_Fuzzy",
                              @"treatTime":@"OutPhlegmTime",
                              @"showTime":@"ShowTime",
                              
                              @"isInFuzzy":@"IsInFuzzy",
                              @"pressure":@"Pressure",
                              @"fuzzyLevel":@"FuzzyLevel",
                              @"frequency":@"Frequency",
                              @"standOrUserDefinedFrequency":@"StandOrUserDefinedFrequency",
                              @"gradientOrCircleFrequencyindex":@"LaderOrCircleFrequencyIndex",
                              @"mode":@"Mode"
                              }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
- (NSString *)SetFrequency {
    NSArray *circleFrequencyArray = @[@"5-11",@"7-13",@"9-15"];
    NSArray *gradientFrequencyArray = @[@"5-7-9-11",@"7-9-11-13",@"9-11-13-15"];
    switch (self.mode) {
        case OutPhlegm_Standard:
        case OutPhlegm_UserDefined:
            return self.standOrUserDefinedFrequency;
            break;
        case OutPhlegm_Circle:
            return circleFrequencyArray[self.gradientOrCircleFrequencyindex];
            break;
        case OutPhlegm_Gradient:
            return gradientFrequencyArray[self.gradientOrCircleFrequencyindex];
            break;
        default:
            return nil;
            break;
    }
}
- (NSArray *)getParameterArray:(SputumExcretionModel *)treatParameter {
    if (treatParameter.isInFuzzy) {
        NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
        [paramArray addObject:[NSString stringWithFormat:@"雾化等级:%@",self.fuzzyLevel]];
        if (treatParameter.attractState == MachineStateRunning) {
            [paramArray addObject:@"吸痰中"];
        }
        return paramArray;
    } else {
        NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
        [paramArray addObject:[NSString stringWithFormat:@"%@mmHg",self.pressure]];
        NSString *frequency;
        //判断是否在运行状态
        if (self.frequency) {
            frequency = self.frequency;
        } else {
            frequency = self.SetFrequency;
        }
        [paramArray addObject:[NSString stringWithFormat:@"%@Hz",frequency]];
        return paramArray;
    }
}
- (NSString *)getGifName {
    if (self.isInFuzzy) {
        return @"fuzzy";
    } else {
        return @"paitan";
    }
}
//根据 排痰、雾化、吸痰三个状态判断当前机器总状态
- (NSString *)state {
    if (self.outPhlemState == MachineStateRunning || self.fuzzyState == MachineStateRunning || self.attractState == MachineStateRunning) {
        return [NSString stringWithFormat:@"%ld",(long)MachineStateRunning];
    } else if (self.outPhlemState == MachineStatePause || self.fuzzyState == MachineStatePause) {
        return [NSString stringWithFormat:@"%ld",(long)MachineStatePause];

    } else {
        return [NSString stringWithFormat:@"%ld",(long)MachineStateStop];
    }
}
@end
