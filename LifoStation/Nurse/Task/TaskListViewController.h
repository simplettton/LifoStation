//
//  TaskListViewController.h
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/26.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
typedef enum _TaskListType
{
    UnfinishedTaskList = 1,
    FinishedTaskList = 2
}TaskListType;
@interface TaskListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@end
