//
//  DepartmentDeviceModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/30.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import "FilterDeviceModel.h"
@interface DepartmentDeviceModel : JSONModel
@property (nonatomic, strong) NSString *department;
@property (nonatomic, strong) NSString *departmentId;
@property (nonatomic, strong) NSArray <FilterDeviceModel> *devices;
@end
