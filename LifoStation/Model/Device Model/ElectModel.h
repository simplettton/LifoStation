//
//  ElectModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/25.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

typedef NS_ENUM(NSInteger,ElectModulationWave) {
    ElectModulationWave_Zhengxianbo = 0,
    ElectModulationWave_Fangbo      = 1,
    ElectModulationWave_Juchibo     = 2,
    ElectModulationWave_Sanjiaobo   = 3,
    ElectModulationWave_Maichongbo  = 4,
    ElectModulationWave_Jianbo      = 5,
    ElectModulationWave_Tixingbo    = 6,
    ElectModulationWave_Zhishubo    = 7,
    ElectModulationWave_Shanxingbo  = 8
};
/** 电疗 */
//模型包含模型时的使用, 被包含的模型需要声明protocol
@protocol ElectChannelModel <NSObject>
@end

@interface ElectChannelModel :JSONModel
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *treatTime;
@property (nonatomic, strong) NSString *showTime;
@property (nonatomic, strong) NSString *amplitude;
@property (nonatomic, strong) NSString *modulationWaveIndex;

@end

@interface ElectModel : JSONModel
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *treatTime;
@property (nonatomic, strong) NSString *showTime;
@property (nonatomic, strong) ElectChannelModel *currentChannel;
@property (nonatomic, strong) NSArray<ElectChannelModel> * channelArray;

- (NSArray *)getParameterArray;
- (NSString *)getGifName;
+ (NSString *)getShowingTimeWithRunningParameter:(ElectModel *)runningParameter treatParameter:(ElectModel *)treatParameter;
@end



