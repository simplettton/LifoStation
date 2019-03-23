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
@property (weak, nonatomic) IBOutlet UIView *controlButtonView;
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
    [self showGifImageWithFLAnimatedImage];
}
- (void)layoutSubviews {
    //type属性已经设置好了
    [super layoutSubviews];
    switch (self.style) {
            /** 在线设备 */
        case CellStyleOnline:

            self.statusImageView.hidden = NO;
            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            self.bodyView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            for (UIView* view in self.bodyContents) {
                view.hidden = NO;
            }
            /** 第二版 */
            self.controlButtonView.hidden = YES;
            self.startButton.hidden = YES;
            break;
            /** 离线设备 */
        case CellStyleOffLine:
            self.statusImageView.hidden = YES;
            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            
            /** 不在线设备隐藏按钮 */
            self.parameterView.hidden = YES;
            self.focusView.hidden = YES;
            self.startButton.hidden = YES;
            self.bodyView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            for (UIView* view in self.bodyContents) {
                view.hidden = NO;
            }
            /** 第二版 */
            self.controlButtonView.hidden = YES;
            self.startButton.hidden = YES;
            break;
            /** 有报警信息的设备 */
        case CellStyleAlert:
            self.statusImageView.hidden = NO;
            self.layer.borderWidth = 2.0f;
            self.layer.borderColor = UIColorFromHex(0xFBA526).CGColor;
            self.alertView.hidden = NO;
            self.bodyView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            for (UIView* view in self.bodyContents) {
                view.hidden = NO;
            }
            /** 第二版 */
            self.controlButtonView.hidden = YES;
            self.startButton.hidden = YES;
            break;
        case CellStyleUnauthorized:
//            self.statusImageView.hidden = NO;
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
    bodyView.frame = CGRectMake((width-kBodyViewWidth)/2, (height-kBodyViewHeight)/2, kBodyViewWidth, kBodyViewHeight);
    if(self.bodyView){
        [self.bodyView removeFromSuperview];
    }
    self.bodyView = bodyView;
    [self.bodyContentView addSubview:bodyView];

    [self.bodyView flashingTest];
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
-(void)showGifImageWithFLAnimatedImage {
    //GIF 转 NSData
    //Gif 路径
    NSString *pathForFile = [[NSBundle mainBundle] pathForResource: @"sin" ofType:@"gif"];
    //转成NSData
    NSData *dataOfGif = [NSData dataWithContentsOfFile: pathForFile];
    //初始化FLAnimatedImage对象
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:dataOfGif];
    //初始化FLAnimatedImageView对象
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    //设置GIF图片
    imageView.animatedImage = image;
    imageView.frame = CGRectMake(523, 276, 170, 112);
    [self addSubview:imageView];
}
@end
