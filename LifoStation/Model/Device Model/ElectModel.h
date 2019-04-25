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
@interface ElectModel : JSONModel
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *treatTime;
@property (nonatomic, strong) NSString *showTime;

@property (nonatomic, assign) NSInteger modulationWaveIndex;
- (NSString *)getGifName;
@end
