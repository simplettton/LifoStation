//
//  CALayer+XibBorderColor.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/21.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "CALayer+XibBorderColor.h"

@implementation CALayer (XibBorderColor)
- (void)setBorderColorFromUIColor:(UIColor *)borderColorFromUIColor {
    self.borderColor = borderColorFromUIColor.CGColor;
    
}

@end
