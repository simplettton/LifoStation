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
/**  bodyContentView */
@property (weak, nonatomic) IBOutlet UIView *controllButtonView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *unauthorizedView;

@property (strong, nonatomic) IBOutletCollection(id) NSArray *bodyContents;


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
    switch (self.style) {
            /** 在线设备 */
        case CellStyleOnline:
            self.titleView.backgroundColor = UIColorFromHex(0x7DC05E);
            self.titleLabel.textColor = [UIColor whiteColor];
            self.statusImageView.image = [UIImage imageNamed:@"wifi_white"];
            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            self.bodyView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            for (UIView* view in self.bodyContents) {
                view.hidden = NO;
            }
            break;
            /** 离线设备 */
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
            self.bodyView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            for (UIView* view in self.bodyContents) {
                view.hidden = NO;
            }
            break;
            /** 有报警信息的设备 */
        case CellStyleAlert:
            self.titleView.backgroundColor = UIColorFromHex(0x7DC05E);
            self.titleLabel.textColor = [UIColor whiteColor];
            self.statusImageView.image = [UIImage imageNamed:@"wifi_white"];
            self.layer.borderWidth = 2.0f;
            self.layer.borderColor = UIColorFromHex(0xFBA526).CGColor;
            self.alertView.hidden = NO;
            self.bodyView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            for (UIView* view in self.bodyContents) {
                view.hidden = NO;
            }
            break;
        case CellStyleUnauthorized:
            self.titleView.backgroundColor = UIColorFromHex(0xfbfbfb);
            self.titleLabel.textColor = UIColorFromHex(0x8a8a8a);
            self.statusImageView.image = [UIImage imageNamed:@"wifiOff"];
            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            
            for (UIView* view in self.bodyContents) {
                view.hidden = YES;
            }
            self.alertView.hidden = YES;
            self.bodyView.hidden = YES;
            self.unauthorizedView.hidden = NO;
            break;
        default:
            break;
    }

}
- (void)configureWithCellStyle:(CellStyle)style AirBagType:(AirBagType)type message:(NSString *)message {
 
    //配置AirView

    AirWaveView *bodyView = (AirWaveView *)[[AirWaveView alloc]initWithAirBagType:type];
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = self.bodyContentView.bounds.size.height;
    bodyView.frame = CGRectMake((width-363)/2, (height-498)/2, 363, 498);
    if(self.bodyView){
        [self.bodyView removeFromSuperview];
    }
    self.bodyView = bodyView;
    [self.bodyContentView addSubview:bodyView];

    
    //报警信息置顶
    if (message != nil) {
        self.alertMessageLabel.text = message;
        self.alertView.hidden = NO;
        [self.bodyContentView bringSubviewToFront:self.alertView];
        if(!self.alertTimer) {
            self.alertTimer = [NSTimer timerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(startFlashingAlertView)
                                                    userInfo:nil
                                                     repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.alertTimer forMode:NSDefaultRunLoopMode];
        }

    } else {
        self.alertView.hidden = YES;
        if (self.alertTimer) {
            [self.alertTimer invalidate];
            self.alertTimer = nil;
        }
    }
    
    if (style == CellStyleUnauthorized) {
        self.bodyView.hidden = YES;
    }
}
- (void)startFlashingAlertView {
    if (self.alertView.isHidden) {
        self.alertView.hidden = NO;
    } else {
        self.alertView.hidden = YES;
    }
}

@end
