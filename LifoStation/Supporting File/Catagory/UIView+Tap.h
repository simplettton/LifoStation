//
//  UIView+Tap.h
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/24.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Tap)
- (void)addTapBlock:(void(^)(id obj))tapAction;
@end
