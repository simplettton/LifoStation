//
//  FourViewsAirWaveCell.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/18.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "FourViewsAirWaveCell.h"

@implementation FourViewsAirWaveCell

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
- (IBAction)showPatientInfoView:(id)sender {
    
}

@end
