//
//  TaskDetailView.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/27.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TaskDetailView.h"
#import "UIView+TYAlertView.h"

@interface TaskDetailView()


@end
@implementation TaskDetailView


- (instancetype)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        NSString *name = [dic objectForKey:@"name"];
        TaskDetailView *view = [TaskDetailView createViewFromNib];
        view.nameLabel.text = [NSString stringWithFormat:@"姓名：%@",name];
        return view;
        
    }
    return self;
}
+ (instancetype)viewWithDic:(NSDictionary* )dic {
    return [[self alloc]initWithDic:dic];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
@end
