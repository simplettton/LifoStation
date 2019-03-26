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
typedef NS_ENUM(NSInteger,machineState) {
    START = 0,
    PAUSE = 1,
    STOP = 2
};
@interface MachineModel : JSONModel
@property (nonatomic, strong) NSString *cpuid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
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
@property (nonatomic, strong) NSDictionary<Optional> *msg_treatParameter;
@property (nonatomic, strong) NSDictionary<Optional> *msg_realTimeData;

@property (nonatomic, strong) NSString<Optional> *msg_alertMessage;


@end
