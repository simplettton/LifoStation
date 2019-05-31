//
//  Constant.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/14.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "Constant.h"

@implementation Constant
@synthesize machineTypeList;
@synthesize machineTypeDic;
@synthesize departmentList;
@synthesize departmentDic;
@synthesize departmentOppositeDic;
@synthesize typeDic;
@synthesize deviceArray;
@synthesize manager;

+ (Constant *)sharedInstance
{
    static Constant *sharedInstance;
    
    @synchronized(self)
    {
        if (!sharedInstance)
            sharedInstance = [[Constant alloc] init];

        return sharedInstance;
    }
}
- (UIColor *)getAlertColorWithLevel:(NSNumber *)level {
    if ([level integerValue] == MachineAlertLevel_High) {
        /** 一级报警红色 */
        return UIColorFromHex(0xe8535f);
    } else {
        /** 二级三级报警黄色 */
        return UIColorFromHex(0xE69723);
        //        return UIColorFromHex(0xFB6E26);
    }
}
@end
