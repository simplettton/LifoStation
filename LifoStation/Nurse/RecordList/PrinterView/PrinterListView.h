//
//  PrinterListView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/29.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrinterListView : UIView<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *taskId;
- (instancetype)initWithData:(NSString *)taskId;
@end
