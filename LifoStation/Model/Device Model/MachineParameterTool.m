//
//  MachineParameterTool.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/12.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MachineParameterTool.h"
#import "HumidifierModel.h"
#import "LightModel.h"
#import "AirwaveModel.h"
#import "HighEnergyInfraredModel.h"
@implementation MachineParameterTool
static MachineParameterTool *_instance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MachineParameterTool alloc]init];
    });;
    return _instance;
}

- (NSArray *)getParameter:(NSDictionary *)dic machine:(MachineModel *)machine {
    if (dic) {
        NSArray *paramArray = [NSArray array];
        NSString *machineType = machine.groupCode;
        switch ([machineType integerValue]) {
            case MachineType_Humidifier:
            {
                HumidifierModel *machineParameter = [[HumidifierModel alloc]initWithDictionary:dic error:nil];
//                machine.leftTime = machineParameter.showTime;
                paramArray = [machineParameter getParameterArray];
            }
                break;

            case MachineType_Light:
            {
                NSError *error;
                LightModel *machineParameter = [[LightModel alloc]initWithDictionary:dic error:&error];
                paramArray = [machineParameter getParameterArray];
            }
                break;
            case MachineType_AirWave:
            {
                NSError *error;

                AirwaveModel *machineParameter = [[AirwaveModel alloc]initWithDictionary:dic error:&error];
                paramArray = [machineParameter getParameterArray];

            }
                
                break;
            case MachineType_HighEnergyInfrared:
            {
                NSError *error;
                HighEnergyInfraredModel *machineParameter = [[HighEnergyInfraredModel alloc]initWithDictionary:dic error:&error];
  
                paramArray = [machineParameter getParameterArray];
            }
            default:
                break;
        }
        return paramArray;
    }
    return nil;
}
- (NSNumber *)getChartDataWithModel:(MachineModel *)machine {
    NSNumber *number;
    NSString *machineType = machine.groupCode;
    switch ([machineType integerValue]) {
        case MachineType_Light:
        {
            NSError *error;
            LightModel *machineParameter = [[LightModel alloc]initWithDictionary:machine.msg_realTimeData error:&error];
            NSNumber *number = [NSNumber numberWithInteger:[machineParameter.temperature integerValue]];
            return number;
        }
            break;
        default:
            break;
    }
    return number;
}
@end
