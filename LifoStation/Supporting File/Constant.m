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
@end
