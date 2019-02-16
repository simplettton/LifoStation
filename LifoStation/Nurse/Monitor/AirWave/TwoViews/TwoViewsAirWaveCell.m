//
//  TwoViewsAirWaveCell.m
//  
//
//  Created by Binger Zeng on 2019/1/17.
//

#import "TwoViewsAirWaveCell.h"
#define kBodyViewWidth 165
#define kBodyViewHeight 226
@implementation TwoViewsAirWaveCell
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ([super initWithCoder:aDecoder]) {
        
    }
    return self;
}
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
