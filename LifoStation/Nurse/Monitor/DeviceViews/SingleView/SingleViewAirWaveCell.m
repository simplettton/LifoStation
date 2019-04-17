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
#import "FLAnimatedImage.h"
#define kBodyViewWidth 363
#define kBodyViewHeight 498
@interface SingleViewAirWaveCell()

/** titleView */
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
/**  bodyContentView */
@property (weak, nonatomic) IBOutlet UIImageView *unauthorizedView;

@property (strong, nonatomic) IBOutletCollection(id) NSArray *bodyContents;


@end
@implementation SingleViewAirWaveCell
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    //子控件还为nil
    if (self = [super initWithCoder:aDecoder]) {

    }
    return self;
}
- (void)configureWithCellStyle:(CellStyle)style airBagType:(AirBagType)type message:(NSString *)message {
    self.style = style;
    [self configureCellStyle];
    //配置AirView
    
    AirWaveView *bodyView = (AirWaveView *)[[AirWaveView alloc]initWithAirBagType:type];
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = self.bodyContentView.bounds.size.height;
    bodyView.frame = CGRectMake((width-kBodyViewWidth)/2, (height-kBodyViewHeight)/2, kBodyViewWidth, kBodyViewHeight);
    if(self.bodyView){
        [self.bodyView removeFromSuperview];
    }
    self.bodyView = bodyView; 
    [self.bodyContentView addSubview:bodyView];
    
    if (self.style == CellStyleUnauthorized) {
        self.bodyView.hidden = YES;
    }
}
- (void)configureCellStyle {
    switch (self.style) {
            /** 在线设备 */
        case CellStyleOnline:
            
            
            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            for (UIView* view in self.bodyContents) {
                view.hidden = [view isEqual:self.alertView];
            }
            self.bodyView.hidden = NO;
            self.statusImageView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            
            break;
            /** 离线设备 */
        case CellStyleOffLine:
            self.statusImageView.hidden = YES;
            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            
            /** 不在线设备隐藏按钮 */
            for (UIView* view in self.bodyContents) {
                view.hidden = ![view isEqual:self.focusView];
            }
            self.leftTimeLabel.hidden = YES;
            self.focusView.hidden = NO;
            self.bodyView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            break;
            /** 有报警信息的设备 */
        case CellStyleAlert:
            self.statusImageView.hidden = NO;
            self.layer.borderWidth = 2.0f;
            self.layer.borderColor = UIColorFromHex(0xFBA526).CGColor;
            self.bodyView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            for (UIView* view in self.bodyContents) {
                view.hidden = NO;
            }
            break;
        case CellStyleUnauthorized:
            
            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            
            for (UIView* view in self.bodyContents) {
                view.hidden = YES;
            }
            
            self.bodyView.hidden = YES;
            self.unauthorizedView.hidden = NO;
            break;
        default:
            break;
    }
}
- (void)awakeFromNib {
    //子控件设置好了 type属性还没有设置好
    [super awakeFromNib];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
//    [self showGifImageWithFLAnimatedImage];
//    [self showGifImageWithFLAnimatedImage1];
}
- (void)layoutSubviews {
    //type属性已经设置好了
    [super layoutSubviews];
    switch (self.style) {
            /** 在线设备 */
        case CellStyleOnline:

            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            for (UIView* view in self.bodyContents) {
                if (![view isEqual:self.alertView]) {
                    view.hidden = NO;
                }
            }
            self.bodyView.hidden = NO;
            self.statusImageView.hidden = NO;
            self.unauthorizedView.hidden = YES;

            break;
            /** 离线设备 */
        case CellStyleOffLine:
            self.statusImageView.hidden = YES;
            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            
            /** 不在线设备隐藏按钮 */
            for (UIView* view in self.bodyContents) {
                view.hidden = YES;
            }
            self.leftTimeLabel.hidden = YES;
            self.focusView.hidden = NO;
            self.bodyView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            break;
            /** 有报警信息的设备 */
        case CellStyleAlert:
            self.statusImageView.hidden = NO;
            self.layer.borderWidth = 2.0f;
            self.layer.borderColor = UIColorFromHex(0xFBA526).CGColor;
            self.bodyView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            for (UIView* view in self.bodyContents) {
                view.hidden = NO;
            }
            break;
        case CellStyleUnauthorized:

            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            
            for (UIView* view in self.bodyContents) {
                view.hidden = YES;
            }
            self.bodyView.hidden = YES;
            self.unauthorizedView.hidden = NO;
            break;
        default:
            break;
    }

}
- (void)configureWithAirBagType:(AirBagType)type message:(NSString *)message {
 
    //配置AirView

    AirWaveView *bodyView = (AirWaveView *)[[AirWaveView alloc]initWithAirBagType:type];
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = self.bodyContentView.bounds.size.height;
    bodyView.frame = CGRectMake((width-kBodyViewWidth)/2, (height-kBodyViewHeight)/2, kBodyViewWidth, kBodyViewHeight);
    if(self.bodyView){
        [self.bodyView removeFromSuperview];
    }
    self.bodyView = bodyView;
    [self.bodyContentView addSubview:bodyView];


    
    if (self.style == CellStyleUnauthorized) {
        self.bodyView.hidden = YES;
    }
}

@end
