//
//  TaskModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/13.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PatientModel.h"
#import "JSONModel.h"
#import "MachineModel.h"
#import "SolutionModel.h"
@interface TaskModel : JSONModel
@property (nonatomic, strong) NSString *uuid;
@property(nonatomic,copy)NSNumber<Optional> *state;
@property (nonatomic, strong) NSString *creatTime;
@property (nonatomic, strong) NSString *finishTime;

@property (nonatomic, strong) PatientModel *patient;
@property (nonatomic, strong) NSString *creatorName;
@property (nonatomic, strong) NSString *operatorName;
@property (nonatomic, strong) NSString *suggest;

@property (nonatomic, strong) MachineModel<Optional> *machine;
@property (nonatomic, strong) NSNumber *leftTime;
@property (nonatomic, strong) SolutionModel *solution;

/** 已完成处方报告专用 */
@property (nonatomic, strong) NSArray *warnning;
@property (nonatomic, strong) NSString *realTreatTime;
@end
