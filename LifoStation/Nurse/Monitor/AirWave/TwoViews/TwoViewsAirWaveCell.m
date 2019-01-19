//
//  TwoViewsAirWaveCell.m
//  
//
//  Created by Binger Zeng on 2019/1/17.
//

#import "TwoViewsAirWaveCell.h"
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
    bodyView.frame = self.bodyView.frame;
    [self.bodyContentView addSubview:bodyView];
    self.bodyView = bodyView;
}

@end
