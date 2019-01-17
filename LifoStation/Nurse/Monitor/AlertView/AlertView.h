//
//  AlertView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/15.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertView : UIView<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
