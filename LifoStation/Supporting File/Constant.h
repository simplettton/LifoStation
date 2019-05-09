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
    MachineStateRunning = 0,    //运行中
    MachineStatePause   = 1,    //暂停中
    MachineStateStop    = 2,    //空闲中
    MachineStateNull    = 3,    //空
    MachineStateOffLine = 0x7f127      //离线
};
typedef NS_ENUM(NSInteger,TaskState) {
    TaskState_WaittingQueue = 2,    //排队中
    TaskState_Treating = 3,         //治疗中
    TaskState_Finished = 4          //已完成
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
    MachineType_AirWave = 7680,      //空气波
    MachineType_HighEnergyInfrared = 0x1069,     //高能红外
    MachineType_NegativePressure = 17,   //负压吸引器
    MachineType_SputumExcretion = 43263,   //排痰
    MachineType_Elect = 56833,   //电疗
    MachineType_Magnetic = 538       //脉冲磁
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
