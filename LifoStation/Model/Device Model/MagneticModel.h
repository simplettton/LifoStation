//
//  MagneticModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/25.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
/** 脉冲磁 */
@interface MagneticModel : JSONModel
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *treatTime;
@property (nonatomic, strong) NSString *showTime;

@property (nonatomic, strong) NSString *temperature;//温度
@end
