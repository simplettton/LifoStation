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
    if (self = [super init]) {
        if (type == AirBagTypeThree) {
            self = [[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].lastObject;
        }
        else if (type == AirBagTypeEight) {
            self = [[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
        }
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
//    if (self.type == AirBagTypeThree) {
//        self.bodyViewThree = [[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].lastObject;
//        self.bodyViewThree.frame = self.bounds;
//        [self addSubview:self.bodyViewThree];
//    }
//    else if (self.type == AirBagTypeEight) {
//        self.bodyViewEight = [[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
//        self.bodyViewEight.frame = self.bounds;
//        [self addSubview:self.bodyViewEight];
//    }
}
//- (void)configureBodyViewWithType:(AirBagType)type {
//    if (self.type == AirBagTypeThree) {
//        self.bodyViewThree = [[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].lastObject;
//        self.bodyViewThree.frame = self.bounds;
//        [self addSubview:self.bodyViewThree];
//    }
//    else if (self.type == AirBagTypeEight) {
//        self.bodyViewEight = [[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
//        self.bodyViewEight.frame = self.bounds;
//        [self addSubview:self.bodyViewEight];
//    }
//}
@end
