//
//  UIView+Extension.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/30.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

@property (nonatomic, assign) CGFloat be_x;
@property (nonatomic, assign) CGFloat be_y;
@property (nonatomic, assign) CGFloat be_centerX;
@property (nonatomic, assign) CGFloat be_centerY;
@property (nonatomic, assign) CGFloat be_width;
@property (nonatomic, assign) CGFloat be_height;
@property (nonatomic, assign) CGSize be_size;
@property (nonatomic, assign) CGPoint be_origin;

@property (nonatomic, assign) CGFloat be_bottom;
@property (nonatomic, assign) CGFloat be_right;

@property (nonatomic, readonly) UIViewController *be_viewController;   // 获取当前视图的Controller
@end
