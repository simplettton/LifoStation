//
//  Constant.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/14.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,CellStyle) {
    CellStyleOnline,
    CellStyleOffLine,
    CellStyleAlert,
    CellStyleUnauthorized
};
typedef NS_ENUM(NSInteger,MachineState) {
    MachineStateRunning = 0,
    MachineStatePause   = 1,
    MachineStateStop    = 2
};
@interface Constant : NSObject
{
    NSMutableArray *machineTypeList;
    NSMutableArray *departmentList;
}
+ (Constant *)sharedInstance;
@property (nonatomic, retain) NSMutableArray *machineTypeList;
@property (nonatomic, strong) NSMutableDictionary *machineTypeDic;
@property (nonatomic, strong) NSMutableDictionary *departmentDic;
@property (nonatomic, strong) NSMutableDictionary *typeDic;
@property (nonatomic, strong) NSMutableDictionary *departmentOppositeDic;
@property (nonatomic, retain) NSMutableArray *departmentList;
@end
