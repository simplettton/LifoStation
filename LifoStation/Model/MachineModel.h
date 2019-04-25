//
//  MachineModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/14.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "PatientModel.h"
/** 图表头文件 */
#import "AAChartKit.h"
typedef NS_ENUM(NSInteger,machineState) {
    START = 0,
    PAUSE = 1,
    STOP = 2
};
@interface MachineModel : JSONModel
@property (nonatomic, strong) NSString *cpuid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *groupCode;
@property (nonatomic, strong) NSString *state;
//剩余时间
@property (nonatomic, strong) NSString<Optional> *leftTime;
@property (nonatomic, assign) BOOL hasLicense;
@property (nonatomic, assign) BOOL isfocus;
@property (nonatomic, assign) BOOL isonline;

@property (nonatomic, strong) NSString<Optional> *departmentId;
@property (nonatomic, strong) NSString<Optional> *departmentName;
@property (nonatomic, strong) PatientModel<Optional> *patient;

//消息订阅模型
@property (nonatomic, strong) NSDictionary *msg_treatParameter;
@property (nonatomic, strong) NSDictionary *msg_realTimeData;

@property (nonatomic, strong) NSString *msg_alertMessage;

//报警信息超时定时器 3s取消报警信息
@property (nonatomic, strong) NSTimer *outTimeTimer;

//报警信息出现/消失定时器
@property (nonatomic, strong) NSTimer *alertTimer;
@property (nonatomic, strong) NSMutableArray *chartDataArray;

//光子特有
@property (nonatomic, strong) NSString *lightSource;
@end
