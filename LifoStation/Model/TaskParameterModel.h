//
//  taskParameterModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/23.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@interface TaskParameterModel : JSONModel
@property (nonatomic, strong) NSString *showName;
@property (nonatomic, strong) NSString *unit;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSDictionary *selectionList;
- (NSDictionary *)getParamDictionary;
@end
