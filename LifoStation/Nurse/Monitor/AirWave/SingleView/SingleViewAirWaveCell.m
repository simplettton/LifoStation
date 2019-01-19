//
//  SingleViewAirWaveCell.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/15.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "SingleViewAirWaveCell.h"
#import "UIView+Tap.h"
@interface SingleViewAirWaveCell()
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@end
@implementation SingleViewAirWaveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
}
- (void)configureWithCellStyle:(CellStyle)style AirBagType:(AirBagType)type {
    switch (style) {
        case CellStyleOnline:
            self.titleView.backgroundColor = UIColorFromHex(0x7DC05E);
            self.titleLabel.textColor = [UIColor whiteColor];
            self.statusImageView.image = [UIImage imageNamed:@"wifi_white"];
            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            break;
        case CellStyleOffLine:
            self.titleView.backgroundColor = UIColorFromHex(0xfbfbfb);
            self.titleLabel.textColor = UIColorFromHex(0x8a8a8a);
            self.statusImageView.image = [UIImage imageNamed:@"wifiOff"];
            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            break;
        case CellStyleAlert:
            self.layer.borderWidth = 2.0f;
            self.layer.borderColor = UIColorFromHex(0xFBA526).CGColor;
            break;
        default:
            break;
    }
    
    //配置AirView
    AirWaveView *bodyView = [[AirWaveView alloc]initWithAirBagType:type];
    bodyView.frame = self.bodyView.frame;
    [self.bodyContentView addSubview:bodyView];
    self.bodyView = bodyView;
    

}
@end
