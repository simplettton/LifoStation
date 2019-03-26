//
//  FourViewsAirWaveCell.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/18.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "FourViewsAirWaveCell.h"

#define kBodyViewWidth 137
#define kBodyViewHeight 187
@implementation FourViewsAirWaveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
}
- (void)configureWithAirBagType:(AirBagType)type {

//    if(self.bodyView){
//        [self.bodyView removeFromSuperview];
//    }
//    self.bodyView = bodyView;
    if (!self.deviceView) {
        AirWaveView *bodyView = [[AirWaveView alloc]initWithAirBagType:type];
        CGFloat width = self.contentView.bounds.size.width;
        CGFloat height = self.bodyContentView.bounds.size.height;
        bodyView.frame = CGRectMake((width-kBodyViewWidth)/2, 55, kBodyViewWidth, kBodyViewHeight);
        [self.bodyContentView addSubview:bodyView];
        self.deviceView = bodyView;
    }
//    [self.bodyContentView addSubview:bodyView];
}
- (IBAction)showPatientInfoView:(id)sender {
    
}
- (void)configureWithCellStyle:(CellStyle)style machineType:(NSInteger)typdeCode dataDic:(NSDictionary *)dic message:(NSString *)message {
    //电疗
    if (typdeCode == 11111) {
        NSString *waveName = [dic objectForKey:@"wave"];

    }
//    //报警信息置顶
//    if (message != nil) {
//        self.alertMessageLabel.text = message;
//        self.alertView.hidden = NO;
//        [self.bodyContentView bringSubviewToFront:self.alertView];
//        if(!self.alertTimer) {               
//            self.alertTimer = [NSTimer timerWithTimeInterval:0.5
//                                                      target:self
//                                                    selector:@selector(startFlashingAlertView)
//                                                    userInfo:nil
//                                                     repeats:YES];
//            [[NSRunLoop mainRunLoop] addTimer:self.alertTimer forMode:NSDefaultRunLoopMode];
//        }
//
//    } else {
//        self.alertView.hidden = YES;
//        if (self.alertTimer) {
//            [self.alertTimer invalidate];
//            self.alertTimer = nil;
//        }
//    }
    
//    if (self.style == CellStyleUnauthorized) {
//        self.bodyView.hidden = YES;
//    }
    
}

@end
