//
//  BodyImageView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/25.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "BodyImageView.h"
#import "UIImage+ImageWithColor.h"
@implementation BodyImageView
/** 正在运行时候图标闪烁 */
- (void)changeGreenColor {
    if ([self.image isEqual:[UIImage imageNamed:self.bodyName withColor:@"yellow"]]) {
        self.image = [UIImage imageNamed:self.bodyName withColor:@"green"];
    } else if([self.image isEqual:[UIImage imageNamed:self.bodyName withColor:@"green"]]){
        self.image = [UIImage imageNamed:self.bodyName withColor:@"yellow"];
    }
}
@end
