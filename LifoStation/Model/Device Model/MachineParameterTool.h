//
//  MachineParameterTool.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/12.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MachineModel.h"
@interface MachineParameterTool : NSObject
+ (instancetype)sharedInstance;
- (NSArray *)getParameter:(NSDictionary *)dic machine:(MachineModel *)machine;
- (NSNumber *)getChartDataWithModel:(MachineModel *)machine;
@end
