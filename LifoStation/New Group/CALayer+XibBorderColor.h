//
//  CALayer+XibBorderColor.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/21.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (XibBorderColor)
- (void)setBorderColorFromUIColor:(UIColor *)borderColorFromUIColor;
@end
