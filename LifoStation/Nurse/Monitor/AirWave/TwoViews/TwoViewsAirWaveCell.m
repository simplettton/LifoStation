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
    AirWaveView *bodyView = [[AirWaveView alloc]initWithAirBagType:self.type];
    bodyView.frame = self.bodyView.bounds;
    [self.bodyContentView addSubview:bodyView];
    NSLog(@"self.type:%ld",(long)self.type);
}


@end
