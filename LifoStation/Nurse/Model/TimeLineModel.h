//
//  TimeLineModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/10.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@interface TimeLineModel :JSONModel
@property (nonatomic,copy)NSString *title;
@property (nonatomic,copy)NSString *timeStamp;
@end
