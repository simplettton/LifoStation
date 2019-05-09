//
//  MagneticModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/25.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MagneticModel.h"

@implementation MagneticModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"stateArray":@"State",
              @"treatTimeArray":@"TreatTime",
              @"showTimeArray":@"ShowTime",
              @"coilTypeArray":@"CoilType",
              @"temperatureArray":@"Temperature"
              }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (NSString *)state {
    if ([self.stateArray containsObject:[NSNumber numberWithInteger:MachineStateRunning]]) {
        return [NSString stringWithFormat:@"%ld",MachineStateRunning];
    } else if ([self.stateArray containsObject:[NSNumber numberWithInteger:MachineStatePause]]) {
        return [NSString stringWithFormat:@"%ld",MachineStatePause];
    } else {
        return [NSString stringWithFormat:@"%ld",MachineStateStop];
    }
}

- (NSString *)temperature {
    if (self.showTimeArray) {
        //实时包温度 服务器传过来是乘以100了 解析的时候要除以100处理
        int maxTemperature = [[self.temperatureArray valueForKeyPath:@"@max.intValue"]intValue];
        return [NSString stringWithFormat:@"%.2f",maxTemperature/100.0];
    } else {
        int maxTemperature = [[self.temperatureArray valueForKeyPath:@"@max.intValue"]intValue];
        return [NSString stringWithFormat:@"%d",maxTemperature];
    }
}

- (NSString *)treatTime {
    NSMutableArray *validArray = [[NSMutableArray alloc]init];
    //根据线圈类型coilType取出有效数据
    [self.treatTimeArray enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.coilTypeArray[idx] integerValue] > 0) {
            [validArray addObject:obj];
        }
    }];
    if ([validArray count] > 0) {
        int maxTime = [[validArray valueForKeyPath:@"@max.intValue"]intValue];
        return [NSString stringWithFormat:@"%d",maxTime];
    } else {
        return @"0";
    }
}

- (NSArray *)getParameterArray {
    NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
    //实时包
    if (self.showTimeArray) {
        [paramArray addObject:[NSString stringWithFormat:@"温度:%@℃",self.temperature]];
    } else {
        //参数包 温度分为六档可调
        NSArray *temperatureArray = @[@"36",@"38",@"41",@"45",@"49",@"53"];
        NSInteger index = [self.temperature integerValue];
        [paramArray addObject:[NSString stringWithFormat:@"温度:%@℃",temperatureArray[index]]];
    }

    return paramArray;
}
+ (NSString *)getShowingTimeWithRunningParameter:(MagneticModel *)runningParameter treatParameter:(MagneticModel *)treatParameter {
    NSMutableArray *validArray = [[NSMutableArray alloc]init];
    [runningParameter.showTimeArray enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([treatParameter.state integerValue ] == MachineStateRunning) {
            if ([treatParameter.coilTypeArray[idx] integerValue] > 0 && [treatParameter.stateArray[idx]integerValue] == MachineStateRunning) {
                [validArray addObject:obj];
            }
        } else {
            if ([treatParameter.coilTypeArray[idx] integerValue] > 0 && [treatParameter.stateArray[idx]integerValue] == MachineStatePause) {
                [validArray addObject:obj];
            }
        }

    }];

    if ([validArray count] > 0) {
        int maxTime = [[validArray valueForKeyPath:@"@max.intValue"]intValue];
        return [NSString stringWithFormat:@"%d",maxTime];
    } else {
        return @"0";
    }
}
@end
