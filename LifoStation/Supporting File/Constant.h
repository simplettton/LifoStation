//
//  Constant.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/14.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTSessionManager.h>
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
typedef NS_ENUM(NSInteger,LightSource) {
    LightSourceNull = 0,
    LightSourceRed  = 1,
    LightSourceBlue = 2,
    LightSourceRedAndBlue = 3
};
typedef NS_ENUM(NSInteger,MachineType)
{
    MachineType_Humidifier = 112,   //湿化
    MachineType_Light = 61199,      //光子
    MachineType_AirWave = 7680      //空气波
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

/** 系统监控的设备列表 DeviceFilterView.m */
@property (nonatomic, strong) NSMutableArray *deviceArray;

/** mqtt */
@property (strong, nonatomic) MQTTSessionManager *manager;

@end
