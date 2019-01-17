//
//  AirWaveView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/17.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AirWaveView.h"

@implementation AirWaveView
- (instancetype)initWithAirBagType:(AirBagType)type {
    if ([super init]) {
        if (type == AirBagTypeThree) {
            AirWaveView *view = [[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
            return view;
        }
        else if (type == AirBagTypeEight) {
            AirWaveView *view = [[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].lastObject;
            return view;
        }
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.type == AirBagTypeThree) {
        self.bodyViewThree = [[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
        self.bodyViewThree.frame = self.bounds;
        [self addSubview:self.bodyViewThree];
    }
    else if (self.type == AirBagTypeEight) {
        self.bodyViewEight = [[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].lastObject;
        self.bodyViewEight.frame = self.bounds;
        [self addSubview:self.bodyViewEight];
    }

}
@end
