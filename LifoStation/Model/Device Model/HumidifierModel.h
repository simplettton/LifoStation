//
//  SHIHUAModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/12.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
/** 湿化 */
@interface HumidifierModel : JSONModel
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *treatTime;
@property (nonatomic, strong) NSString *showTime;

@property (nonatomic, strong) NSString *temperature;//温度
@property (nonatomic, strong) NSString *flow;//流量
@property (nonatomic, strong) NSString *oxygen;//氧浓度
- (NSArray *)getParameterArray;

@end
