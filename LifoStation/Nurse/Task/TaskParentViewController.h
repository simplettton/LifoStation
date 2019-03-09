//
//  TaskParentViewController.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/7.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskParentViewController : UIViewController
typedef enum _TaskListType
{
    TaskListTypeWaiting = 0,
    TaskListTypeProcessing = 7,
    TaskListTypeFinished = 15,
}TaskListType;
@end
