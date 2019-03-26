//
//  DeviceSelectView.h
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/27.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskModel.h"
typedef void (^returnDicBlock) (NSDictionary*);
typedef NS_ENUM(NSInteger,deviceOnlineSelections){
    online = 0,
    offline = 1
};

@interface DeviceSelectView : UIView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) TaskModel *task;
@property (nonatomic, strong) returnDicBlock returnEvent;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (instancetype)initWithModel:(TaskModel *)task return:(returnDicBlock)returnEvent;
@end
