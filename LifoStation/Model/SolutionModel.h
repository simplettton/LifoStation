//
//  SolutionModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/18.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@interface SolutionModel : JSONModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *machineType;
@property (nonatomic, strong) NSString *machineTypeName;
@property (nonatomic, strong) NSString *originalParamList;
@property (nonatomic, strong) NSString *mainModeName;
@property (nonatomic, strong) NSString *treatTime;
@property (nonatomic, strong) NSString *note;

/** 解析后的数组 */
@property (nonatomic, strong) NSMutableArray *paramList;
@end
