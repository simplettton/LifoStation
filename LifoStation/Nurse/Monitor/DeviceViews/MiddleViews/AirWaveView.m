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
@property (weak, nonatomic) IBOutlet BodyImageView *leftup1;
@property (weak, nonatomic) IBOutlet BodyImageView *leftup2;
@property (weak, nonatomic) IBOutlet BodyImageView *leftup3;
@property (weak, nonatomic) IBOutlet BodyImageView *lefthand;
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
            UIView *view = (AirWaveView *)[[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].lastObject;
            self.bodyView = view;
            [self addSubview:view];
        }
        else if (type == AirBagTypeEight) {
            UIView *view  = (AirWaveView *)[[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
            self.bodyView = view;
            [self addSubview:view];
        }
    }
    return self;
}
- (instancetype)initWithParameter:(AirwaveModel *)machineParameter {
    if (self = [super init]) {
        self.APortType = machineParameter.APortType;
        self.BPortType = machineParameter.BPortType;
        NSInteger type;
        //用AB其中一个气囊的类型判断腿部显示多少腔
        if (machineParameter.APortType == AirPortType_Unconnected) {
            type = machineParameter.BPortType;
        } else {
            type = machineParameter.APortType;
        }
        switch (type) {
            case AirPortType_Leg6:
            case AirPortType_Leg8:
            {
                //腿部八腔
                UIView *view  = (AirWaveView *)[[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
                self.bodyView = view;
                [self addSubview:view];
            }
                
                break;
            default:{
                //腿部三腔
                UIView *view = (AirWaveView *)[[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].lastObject;
                self.bodyView = view;
                [self addSubview:view];
            }
                break;
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
- (void)updateViewWithModel:(MachineModel *)machine {
    NSDictionary *parameterDic;
    switch ([machine.state integerValue]) {
        case MachineStateRunning:
            parameterDic = machine.msg_realTimeData;
            break;
        case MachineStatePause:
        case MachineStateStop:
            parameterDic = machine.msg_treatParameter;
            break;
        default:
            break;
    }
    AirwaveModel *treatmentParameter = [[AirwaveModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
}
- (NSArray *)getAirPortType:(AirwaveModel *)treatParameter {
    int indexs[8];
    switch (treatParameter.APortType) {
        case AirPortType_Leg6:
        {
            int indexs[] = {leftfoottag,leftleg7tag,leftleg6tag,leftleg5tag,leftleg4tag,leftleg3tag};
        }
            break;
        case AirPortType_Leg8:
            break;
        default:
            break;
    }
    NSArray *array;
    return array;
}
@end
