//
//  ReportTableViewController.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/10.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskModel.h"
@interface ReportTableViewController : UITableViewController
@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, strong) TaskModel *taskModel;
@end
