//
//  UIView+Tap.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/24.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "UIView+Tap.h"
#import <objc/runtime.h>
static const void* tagValue = &tagValue;

@interface UIView()
@property (nonatomic, copy) void (^tapAction)(id);
@end

@implementation UIView (Tap)

- (void)addTapBlock:(void (^)(id))tapAction {
    self.tapAction = tapAction;
    if (![self gestureRecognizers]) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tap];
    }
}
- (void)tap {
    if (self.tapAction) {
        self.tapAction(self);
    }
}
- (void)setTapAction:(void (^)(id))tapAction {
    objc_setAssociatedObject(self, tagValue, tapAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(id))tapAction {
    return objc_getAssociatedObject(self, tagValue);
}
@end
