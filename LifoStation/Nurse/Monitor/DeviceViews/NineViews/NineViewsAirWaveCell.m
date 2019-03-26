//
//  NineViewsAirWaveCell.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/18.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "NineViewsAirWaveCell.h"
#define kBodyViewWidth 102
#define kBodyViewHeight 139
@implementation NineViewsAirWaveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
}
- (void)configureWithAirBagType:(AirBagType)type {
    AirWaveView *bodyView = [[AirWaveView alloc]initWithAirBagType:type];
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = self.bodyContentView.bounds.size.height;
    bodyView.frame = CGRectMake((width-kBodyViewWidth)/2, (height-kBodyViewHeight)/2, kBodyViewWidth, kBodyViewHeight);
    if(self.bodyView){
        [self.bodyView removeFromSuperview];
    }
    self.bodyView = bodyView;
    [self.bodyContentView addSubview:bodyView];
}

@end
