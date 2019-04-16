//
//  GUANGZIModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/12.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
/** 光子 */
@interface LightModel : JSONModel
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *treatTime;
@property (nonatomic, strong) NSString *showTime;

@property (nonatomic, strong) NSString *temperature;//实时包为人体温度，参数包为设定温度
@property (nonatomic, strong) NSString *energyLevel;//能量
@property (nonatomic, strong) NSString *dosage;//剂量
@property (nonatomic, assign) NSInteger mainLightSource;//主光源
@property (nonatomic, assign) NSInteger appendLightSource;//附件光源
- (NSArray *)getParameterArray;
@end
