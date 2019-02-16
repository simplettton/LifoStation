//
//  SelectDateView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/2/16.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectDateView : UIView
@property (nonatomic, copy) void(^confirmBlock) (NSDictionary*);
- (instancetype)initWithDic:(NSDictionary *)dic commitBlock:(void(^)(NSDictionary *selection))commitBlock;

@end
