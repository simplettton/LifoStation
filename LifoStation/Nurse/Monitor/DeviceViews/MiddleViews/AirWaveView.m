//
//  AirWaveView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/17.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AirWaveView.h"

@interface AirWaveView()
@property (weak, nonatomic) IBOutlet BodyImageView *testBodyPart;

- (void)startTimerToChangeColorOfImageView:(BodyImageView *)bodyPart;
@end
@implementation AirWaveView
- (void)flashingTest {
//    for (BodyImageView *body in self.bodyImages) {
//        if(!body.changeColorTimer){
//            [self startTimerToChangeColorOfImageView:body];
//        }
//    }
    if (!_testBodyPart.changeColorTimer) {
        [self startTimerToChangeColorOfImageView:self.testBodyPart];
    }
}
- (instancetype)initWithAirBagType:(AirBagType)type {
    
    if (self = [super init]) {
        if (type == AirBagTypeThree) {
            UIView *view = [[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].lastObject;
            self.bodyView = view;
            [self addSubview:view];
        }
        else if (type == AirBagTypeEight) {
            UIView *view  = [[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
            self.bodyView = view;
            [self addSubview:view];
        }
    }
    return self;
}
- (void)startTimerToChangeColorOfImageView:(BodyImageView *)bodyPart {
    
    bodyPart.changeColorTimer = [NSTimer timerWithTimeInterval:0.5
                                                        target:bodyPart
                                                      selector:@selector(changeGreenColor)
                                                      userInfo:nil
                                                       repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:bodyPart.changeColorTimer forMode:NSDefaultRunLoopMode];
    
}
- (void)deallocTimerWithImageView:(BodyImageView *)bodyPart {
    [bodyPart.changeColorTimer invalidate];
    bodyPart.changeColorTimer = nil;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    //外框frame修改时bodyview的frame同步修改
    CGRect newFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.bodyView.frame = newFrame;
}

@end
