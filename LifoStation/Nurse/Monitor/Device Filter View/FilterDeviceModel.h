//
//  FilterDeviceModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/30.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
@protocol FilterDeviceModel <NSObject>

@end

@interface FilterDeviceModel : JSONModel
//@property (nonatomic, strong) NSString *type;
//@property (nonatomic, strong) NSArray *name;
@property (nonatomic, strong) NSString *deviceGroup;
@property (nonatomic, strong) NSArray *nameList;
@property (nonatomic, strong) NSString *groupName;
@end
