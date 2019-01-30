//
//  UIView+Extension.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/30.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)
- (UIViewController *)be_viewController {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

- (CGFloat)be_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBe_bottom:(CGFloat)hm_bottom {
    CGRect frame = self.frame;
    frame.origin.y = hm_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)be_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setBe_right:(CGFloat)hm_right {
    CGRect frame = self.frame;
    frame.origin.x = hm_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)be_x {
    return self.frame.origin.x;
}

- (void)setBe_x:(CGFloat)hm_x {
    CGRect frame = self.frame;
    frame.origin.x = hm_x;
    self.frame = frame;
}

- (CGFloat)be_y {
    return self.frame.origin.y;
}

- (void)setBe_y:(CGFloat)hm_y {
    CGRect frame = self.frame;
    frame.origin.y = hm_y;
    self.frame = frame;
}

- (CGFloat)be_centerX {
    return self.center.x;
}

- (void)setBe_centerX:(CGFloat)hm_centerX {
    CGPoint center = self.center;
    center.x = hm_centerX;
    self.center = center;
}

- (CGFloat)be_centerY {
    return self.center.y;
}

- (void)setBe_centerY:(CGFloat)hm_centerY {
    CGPoint center = self.center;
    center.y = hm_centerY;
    self.center = center;
}

- (CGFloat)be_width {
    return self.frame.size.width;
}

- (void)setBe_width:(CGFloat)hm_width {
    CGRect frame = self.frame;
    frame.size.width = hm_width;
    self.frame = frame;
}

- (CGFloat)be_height {
    return self.frame.size.height;
}

- (void)setBe_height:(CGFloat)hm_height {
    CGRect frame = self.frame;
    frame.size.height = hm_height;
    self.frame = frame;
}

- (CGSize)be_size {
    return self.frame.size;
}

- (void)setBe_size:(CGSize)hm_size {
    CGRect frame = self.frame;
    frame.size = hm_size;
    self.frame = frame;
}

- (CGPoint)be_origin {
    return self.frame.origin;
}

- (void)setBe_origin:(CGPoint)hm_origin {
    CGRect frame = self.frame;
    frame.origin = hm_origin;
    self.frame = frame;
}

@end
