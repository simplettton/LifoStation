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
#import "NegativePressureModel.h"
#import "SputumExcretionModel.h"
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
                break;
            case MachineType_NegativePressure:
            {
                NSError *error;
                NegativePressureModel *machineParameter = [[NegativePressureModel alloc]initWithDictionary:dic error:&error];
                paramArray = [machineParameter getParameterArray];
            }
                
                break;
            case MachineType_SputumExcretion:
            {
                NSError *error;
                //获取雾化或排痰状态显示不同参数
                SputumExcretionModel *treatParameter = [[SputumExcretionModel alloc]initWithDictionary:machine.msg_treatParameter error:&error];
                SputumExcretionModel *machineParameter = [[SputumExcretionModel alloc]initWithDictionary:dic error:&error];
                paramArray = [machineParameter getParameterArray:treatParameter];
            }
                break;
            default:
                break;
        }
        return paramArray;
    }
    return nil;
}
/** 根据machine的运行状态返回设备模型 */
- (id)getMachineParameterModel:(MachineModel *)machine {
    NSString *machineType = machine.groupCode;
    NSDictionary *parameterDic;
    if ([machine.state integerValue] == MachineStateRunning) {
        if (machine.msg_realTimeData) {
            parameterDic = machine.msg_realTimeData;
        }
    }
    else {
        if (machine.msg_treatParameter) {
            parameterDic = machine.msg_treatParameter;
        }
    }
    switch ([machineType integerValue]) {
        case MachineType_Humidifier:
        {
            HumidifierModel *machineParameter = [[HumidifierModel alloc]initWithDictionary:parameterDic error:nil];
            return machineParameter;
        }
            break;
            
        case MachineType_AirWave:
        {
            NSError *error;
            
            AirwaveModel *machineParameter = [[AirwaveModel alloc]initWithDictionary:parameterDic error:&error];
            return machineParameter;
        }
            
            break;
        case MachineType_HighEnergyInfrared:
        {
            NSError *error;
            HighEnergyInfraredModel *machineParameter = [[HighEnergyInfraredModel alloc]initWithDictionary:parameterDic error:&error];
            
            return machineParameter;
        }
            break;
            
        case MachineType_Light:
        {
            NSError *error;
            LightModel *machineParameter = [[LightModel alloc]initWithDictionary:parameterDic error:&error];
            return machineParameter;
            
        }
            break;
        case MachineType_NegativePressure:
        {
            NSError *error;
            NegativePressureModel *machineParameter = [[NegativePressureModel alloc]initWithDictionary:parameterDic error:&error];
            return machineParameter;
        }
            break;
        case MachineType_SputumExcretion:
        {
            NSError *error;
            SputumExcretionModel *machineParameter = [[SputumExcretionModel alloc]initWithDictionary:parameterDic error:&error];
            return machineParameter;
        }
            break;
        default:
            return nil;
            break;
            
    }
}
#pragma mark - 表格数据
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

#pragma mark - 显示时间
/** 实时包的时间 */
- (NSString *)getTimeShowingText:(MachineModel *)machine {

    if ([machine.state integerValue] != MachineStateStop) {
        //运行和暂停的时候显示实时信息 若一开始是暂停状态 没有machine.msg_realTimeData 则显示服务器给的lefttime
        if ([machine.state integerValue] == MachineStatePause && !machine.msg_realTimeData) {
            return [self getHourAndMinuteFromSeconds:machine.leftTime];
        } else {
            switch ([machine.groupCode integerValue]) {
                    //负压的时间显示 如果是ABC方案显示工作模式 如果是DEF显示倒计时
                case MachineType_NegativePressure:
                {
                    NegativePressureModel *treatParamter = [[NegativePressureModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
                    if (treatParamter.hasLeftTime) {
                        NSString *showTime = [NSString stringWithFormat:@"%@",machine.msg_realTimeData[@"ShowTime"]];
                        return [self getHourAndMinuteFromSeconds:showTime];
                    } else {
                        return [treatParamter getTimeShowingText];
                    }
                }
                    break;
                    //排痰的时间显示 如果是雾化模式显示雾化正计时时间 如果是排痰模式显示排痰倒计时时间倒计时
                case MachineType_SputumExcretion:
                {
                    SputumExcretionModel *treatParameter = [[SputumExcretionModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
                    SputumExcretionModel *runningParameter = [[SputumExcretionModel alloc]initWithDictionary:machine.msg_realTimeData error:nil];
                    if (runningParameter) {
                        if (treatParameter.isInFuzzy) {
                            return [self getHourAndMinuteFromSeconds:runningParameter.fuzzyShowTime];
                        } else {
                            return [self getHourAndMinuteFromSeconds:runningParameter.outPhlemShowTime];
                        }
                    } else {
                        //没有实时包则返回设置包的时间设置参数treatTime
                        return [self getHourAndMinuteFromSeconds:[NSString stringWithFormat:@"%ld",[treatParameter.treatTime integerValue]*60]];
                    }
                }
                    
                    break;
                    
                default:
                {
                    NSString *showTime = [NSString stringWithFormat:@"%@",machine.msg_realTimeData[@"ShowTime"]];
                    return [self getHourAndMinuteFromSeconds:showTime];
                }
                    break;
            }
        }

    } else {
        switch ([machine.groupCode integerValue]) {
            case MachineType_SputumExcretion:
            {
                SputumExcretionModel *treatParameter = [[SputumExcretionModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
                return [self getHourAndMinuteFromSeconds:[NSString stringWithFormat:@"%ld",[treatParameter.treatTime integerValue]*60]];
            }
                break;
            default:
            {
                NSString *treatTime = [NSString stringWithFormat:@"%ld",[machine.msg_treatParameter[@"TreatTime"]integerValue]*60];
                return [self getHourAndMinuteFromSeconds:treatTime];
            }
                
                break;
        }
    }

}
- (NSString *)getHourAndMinuteFromSeconds:(NSString *)totalTime {
    NSInteger seconds = [totalTime integerValue];
    
    //format of hour
    NSString *HourString = [NSString stringWithFormat:@"%02ld",seconds/3600];
    NSString *minuterString = [NSString stringWithFormat:@"%02ld",(seconds % 3600)/60];
    NSString *secondString = [NSString stringWithFormat:@"%02ld",seconds%60];
    NSString *formatTime = [NSString stringWithFormat:@"%@:%@:%@",HourString,minuterString,secondString];
    return formatTime;
}
#pragma mark - 中间视图资源名字获取
- (NSString *)getDeviceImageName:(MachineModel *)machine {
    NSString *machineType = machine.groupCode;
    switch ([machineType integerValue]) {
        case MachineType_Humidifier: return @"shihua"; break;
        case MachineType_HighEnergyInfrared: return @"gnhw"; break;
        case MachineType_NegativePressure:  return @"negativePressure"; break;
        
        case MachineType_Light:
        {
            LightModel *treatParamter = [self getMachineParameterModel:machine];
            if (treatParamter) {
                return [treatParamter getLightName];//没有任何参数包和实时包的时候显示蓝光
            } else {
                return @"blight";
            }
        }
            break;
        case MachineType_SputumExcretion:
        {
            NSError *error;
            SputumExcretionModel *treatParameter = [[SputumExcretionModel alloc]initWithDictionary:machine.msg_treatParameter error:&error];
            if (treatParameter) {
                return [treatParameter getGifName];
            } else {
                return @"paitan";//防止treatParameter为nil
            }
        }
            break;
        default:
            return nil;
            break;
    }
}
#pragma mark - 设备状态获取
- (NSString *)getMachineState:(MachineModel *)machine {
    //排痰状态获取根据三种状态（排痰雾化吸痰）叠加获取
    if ([machine.groupCode integerValue] == MachineType_SputumExcretion) {
        SputumExcretionModel *treatmentParameter = [[SputumExcretionModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
        if (treatmentParameter) {
            return treatmentParameter.state;
        }
    } else {
        return [NSString stringWithFormat:@"%@",machine.msg_treatParameter[@"State"]];
    }
    return nil;
}
#pragma mark - 设备状态文字获取
- (NSString *)getStateShowingText:(MachineModel *)machine {
    NSDictionary *machineStateDic = @{
                                      @"0":@"运行中",
                                      @"1":@"暂停中",
                                      @"2":@"空闲中",
                                      @"3":@"空",
                                      @"255":@"离线"
                                      };
    return machineStateDic[machine.state];
}
@end
