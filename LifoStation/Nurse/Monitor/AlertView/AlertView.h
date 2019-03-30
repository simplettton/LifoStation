//
//  AlertView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/15.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^returnStringBlock) (NSString *);
@interface AlertView : UIView<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) returnStringBlock returnEvent;
@property (nonatomic, strong) NSMutableArray *dataArray;
- (instancetype)initWithData:(NSMutableArray *)alertArray return:(returnStringBlock)returnEvent;
@end
