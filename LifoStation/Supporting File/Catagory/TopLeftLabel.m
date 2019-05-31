//
//  TopLeftLabel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/5/23.
//  Copyright © 2019 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TopLeftLabel.h"

@implementation TopLeftLabel
- (id)initWithFrame:(CGRect)frame {
    return [super initWithFrame:frame];
}
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    textRect.origin.y = bounds.origin.y;
    return textRect;
}
-(void)drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

@end
