//
//  SingleViewAirWaveCell.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/15.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "SingleViewAirWaveCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Tap.h"
@interface SingleViewAirWaveCell()
/** titleView */
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;



@property (strong, nonatomic) AirWaveView *bodyView;
@end
@implementation SingleViewAirWaveCell
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    //子控件还为nil
    if (self = [super initWithCoder:aDecoder]) {

    }
    return self;
}
- (void)awakeFromNib {
    //子控件设置好了 type属性还没有设置好
    [super awakeFromNib];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
}
- (void)layoutSubviews {
    //type属性已经设置好了
    [super layoutSubviews];

}
- (void)configureWithCellStyle:(CellStyle)style AirBagType:(AirBagType)type message:(NSString *)message {
    
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
            
            /** 不在线设备隐藏按钮 */
            self.parameterView.hidden = YES;
            self.timeLabel.hidden = YES;
            self.startButton.hidden = YES;
            break;
        case CellStyleAlert:
            self.layer.borderWidth = 2.0f;
            self.layer.borderColor = UIColorFromHex(0xFBA526).CGColor;
            self.alertView.hidden = NO;
            self.alertMessageLabel.text = message;
            break;
        default:
            break;
    }
    //配置AirView
    if(!self.bodyView) {
        AirWaveView *bodyView = (AirWaveView *)[[AirWaveView alloc]initWithAirBagType:type];
        bodyView.frame = CGRectMake(199, 72, 363, 500);
        self.bodyView = bodyView;
        [self.bodyContentView addSubview:bodyView];
    }
    
    self.bodyView.hidden = NO;
    //报警信息置顶
    if (message != nil) {
        //报警时隐藏中间的bodyView
        self.bodyView.hidden = YES;
        [self.bodyContentView bringSubviewToFront:self.alertView];
//        [self.alertView.layer addAnimation:[self opacityForever_Animation:0.5] forKey:nil];
    } else {
//        [self.alertView.layer removeAllAnimations];
    }
}
#pragma mark === 永久闪烁的动画 ======
-(CABasicAnimation *)opacityForever_Animation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.repeatCount = 10000000000;
    animation.duration = time;
//    animation.repeatCount = 6;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];///没有的话是均匀的动画。
    return animation;
}
@end
