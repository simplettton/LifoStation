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
@property (nonatomic, strong) NSMutableArray <Optional> *paramList;
@property (nonatomic, strong) NSString *mainModeName;
@property (nonatomic, strong) NSString *treatTime;
@end
