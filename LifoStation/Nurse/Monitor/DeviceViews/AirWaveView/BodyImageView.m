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
- (instancetype)initWithView:(UIImageView *)view {
    if (self = [super init]) {
        self.frame = view.frame;
        self.tag = view.tag;
    }
    return self;
}
- (void)changeGreenColor {
    if ([self.image.accessibilityIdentifier isEqualToString:AddStr(self.bodyName, @"yellow")]) {
        self.image = [UIImage imageNamed:self.bodyName withColor:@"green"];
        self.image.accessibilityIdentifier = AddStr(self.bodyName,@"green");
    } else {
        self.image = [UIImage imageNamed:self.bodyName withColor:@"yellow"];
        self.image.accessibilityIdentifier = AddStr(self.bodyName,@"yellow");
    }

}
- (void)changeColor:(NSString *)color {
    self.image = [UIImage imageNamed:self.bodyName withColor:color];
    self.image.accessibilityIdentifier = AddStr(self.bodyName,color);
}
- (void)closeTimer {
    if (self.changeColorTimer) {
        [self.changeColorTimer invalidate];
        self.changeColorTimer = nil;
    }
}
@end
