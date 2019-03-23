//
//  DepartmentModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/12.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@interface DepartmentModel : JSONModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uid;
@end
