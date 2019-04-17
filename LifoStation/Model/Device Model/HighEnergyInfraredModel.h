//
//  HighEnergyInfraredModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/17.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
/** 高能红外 */
@interface HighEnergyInfraredModel : JSONModel
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *treatTime;
@property (nonatomic, strong) NSString *showTime;

@property (nonatomic, strong) NSString *workMode;//工作模式
- (NSArray *)getParameterArray;
@end
