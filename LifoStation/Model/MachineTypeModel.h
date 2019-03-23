//
//  MachineTypeModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/7.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@interface MachineTypeModel : JSONModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) CGFloat titleWidth;
@end
