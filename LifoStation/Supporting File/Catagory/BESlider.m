//
//  BESlider.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "BESlider.h"

@implementation BESlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


// 控制slider的宽和高，这个方法才是真正的改变slider滑道的高的
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectMake(0, 0, CGRectGetWidth(self.frame), 8);
}

//// 改变滑块的触摸范围
//- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
//{
//    return CGRectInset([super thumbRectForBounds:bounds trackRect:rect value:value], 10, 10);
//}
@end
