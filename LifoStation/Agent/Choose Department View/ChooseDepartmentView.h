//
//  ChooseDepartmentView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/4.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^returnBlock) (NSString*);
@interface ChooseDepartmentView : UIView<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)returnBlock returnEvent;
@property(assign, nonatomic) NSInteger selectedIndex;
-(instancetype)initWithDic:(NSDictionary* )dic return:(returnBlock)returnEvent;
@end
