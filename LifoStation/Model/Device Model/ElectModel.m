//
//  ElectModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/25.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ElectModel.h"
@implementation ElectChannelModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"state":@"State",
              @"treatTime":@"TreatTime",
              @"showTime":@"ShowTime",
              @"amplitude":@"Amplitude",
              @"modulationWaveIndex":@"ModulateWaveShape"
              }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end
@implementation ElectModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
- (NSArray *)getParameterArray {
    NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
    //只有实时包有幅值参数
    if (self.currentChannel.amplitude) {
        [paramArray addObject:[NSString stringWithFormat:@"%@mA",self.currentChannel.amplitude]];
    } else {
        [paramArray addObject:@"0mA"];
    }
    return [paramArray copy];
}
- (ElectChannelModel *)currentChannel {
    NSMutableArray *stateArray = [[NSMutableArray alloc]init];
    for (ElectChannelModel *model in self.channelArray) {
        [stateArray addObject:model.state];
    }
    //有正在运行的通道
    if ([stateArray containsObject:[NSString stringWithFormat:@"%ld",(long)MachineStateRunning]]) {
        NSInteger index = [stateArray indexOfObject:[NSString stringWithFormat:@"%ld",(long)MachineStateRunning]];
        return self.channelArray[index];
    } else if ([stateArray containsObject:[NSString stringWithFormat:@"%ld",(long)MachineStatePause]]) {
        //有暂停的通道
        NSInteger index = [stateArray indexOfObject:[NSString stringWithFormat:@"%ld",(long)MachineStatePause]];
        return self.channelArray[index];
    } else if ([stateArray containsObject:[NSString stringWithFormat:@"%ld",(long)MachineStateStop]]) {
        //有结束的通道
        NSInteger index = [stateArray indexOfObject:[NSString stringWithFormat:@"%ld",(long)MachineStateStop]];
        return self.channelArray[index];
        
    } else {
         return self.channelArray[0];
    }

}
- (NSString *)treatTime {
    if (self.currentChannel.treatTime) {
        return self.currentChannel.treatTime;
        
    } else {
        return @"0";
    }
}
- (NSString *)showTime {
    if (self.currentChannel.showTime) {
        return self.currentChannel.showTime;
        
    } else {
        return @"0";
    }
}
- (NSString *)getGifName {
    NSArray *gifNameArray = @[
                              @"zhengxianbo",
                              @"fangbo",
                              @"juchibo",
                              @"sanjiaobo",
                              @"maicongbo",
                              @"jianbo",
                              @"tixingbo",
                              @"zhishubo",
                              @"sanxingbo"
                              ];
    
    if (self.currentChannel.modulationWaveIndex) {
        NSInteger index = [self.currentChannel.modulationWaveIndex integerValue];
        return gifNameArray[index];
    } else {
        return nil;
    }
}
- (NSString *)state {
    NSMutableArray *stateArray = [[NSMutableArray alloc]initWithCapacity:20];
    for (ElectChannelModel *model in self.channelArray) {
        [stateArray addObject:model.state];
    }
    //有正在运行的
    if ([stateArray containsObject:[NSString stringWithFormat:@"%ld",(long)MachineStateRunning]]) {
        return [NSString stringWithFormat:@"%ld",MachineStateRunning];
    } else if ([stateArray containsObject:[NSString stringWithFormat:@"%ld",(long)MachineStatePause]]) {
        return [NSString stringWithFormat:@"%ld",MachineStatePause];
    } else if ([stateArray containsObject:[NSString stringWithFormat:@"%ld",(long)MachineStateStop]]) {
        return [NSString stringWithFormat:@"%ld",MachineStateStop];
        
    } else {
        return [NSString stringWithFormat:@"%ld",MachineStateNull];
    }

}
+ (NSString *)getShowingTimeWithRunningParameter:(ElectModel *)runningParameter treatParameter:(ElectModel *)treatParameter {
    
    //根据状态获取的当前channel
    ElectChannelModel *currentChannel = treatParameter.currentChannel;
    if ([currentChannel.state integerValue] != MachineStateStop) {
        //runningparameter的才有showtime
        NSInteger index = [treatParameter.channelArray indexOfObject:currentChannel];
        ElectChannelModel *runningChannelModel = [runningParameter.channelArray objectAtIndex:index];
        
        return runningChannelModel.showTime;
    } else {
        return [NSString stringWithFormat:@"%ld",[currentChannel.treatTime integerValue]*60];
    }
}
@end
