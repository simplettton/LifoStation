//
//  AirWaveView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/17.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AirWaveView.h"

@interface AirWaveView()

- (void)startTimerToChangeColorOfImageView:(BodyImageView *)bodyPart;

@property (strong, nonatomic) IBOutletCollection(BodyImageView) NSArray *eightLegArray;
//bodyImage从下到上 从左到右
@property (strong, nonatomic) IBOutletCollection(BodyImageView) NSArray *bodyPartArray;
@property (weak, nonatomic) IBOutlet BodyImageView *leftdown1;
@property (weak, nonatomic) IBOutlet BodyImageView *leftdown2;
@property (weak, nonatomic) IBOutlet BodyImageView *leftdown3;
@property (weak, nonatomic) IBOutlet BodyImageView *leftfoot;
@property (weak, nonatomic) IBOutlet BodyImageView *rightup1;
@property (weak, nonatomic) IBOutlet BodyImageView *rightup2;
@property (weak, nonatomic) IBOutlet BodyImageView *rightup3;
@property (weak, nonatomic) IBOutlet BodyImageView *righthand;
@property (weak, nonatomic) IBOutlet BodyImageView *rightdown1;
@property (weak, nonatomic) IBOutlet BodyImageView *rightdown2;
@property (weak, nonatomic) IBOutlet BodyImageView *rightdown3;
@property (weak, nonatomic) IBOutlet BodyImageView *rightfoot;
@property (weak, nonatomic) IBOutlet BodyImageView *leftup1;
@property (weak, nonatomic) IBOutlet BodyImageView *leftup2;
@property (weak, nonatomic) IBOutlet BodyImageView *leftup3;

@property (weak, nonatomic) IBOutlet BodyImageView *middle1;
@property (weak, nonatomic) IBOutlet BodyImageView *middle2;
@property (weak, nonatomic) IBOutlet BodyImageView *middle3;
@property (weak, nonatomic) IBOutlet BodyImageView *middle4;
@property (weak, nonatomic) IBOutlet BodyImageView *lefthand;

@property (nonatomic, strong) NSMutableArray *activeBodyPartArray;
@end
@implementation AirWaveView

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
                self.type = AirBagTypeEight;
                [self addSubview:view];
            }
                
                break;
            default:{
                //腿部三腔
                UIView *view = (AirWaveView *)[[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].lastObject;
                self.type = AirBagTypeThree;
                self.bodyView = view;
                [self addSubview:view];
            }
                break;
        }
    }
    return self;
}
- (void)updateBodyView:(AirBagType)type {

    switch (type) {
            case AirBagTypeThree:
        {
            //腿部三腔
            UIView *view = (AirWaveView *)[[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].lastObject;
            self.type = AirBagTypeThree;
            CGRect frame = self.bodyView.frame;
            view.frame = frame;
            [self.bodyView removeFromSuperview];
            [self addSubview:view];
            self.bodyView = view;
        }
            
            break;
            case AirBagTypeEight:
        {
            //腿部八腔
            UIView *view  = (AirWaveView *)[[UINib nibWithNibName:@"AirWaveView" bundle:nil] instantiateWithOwner:self options:nil].firstObject;
            self.type = AirBagTypeEight;
            CGRect frame = self.bodyView.frame;
            view.frame = frame;
            [self.bodyView removeFromSuperview];
            [self addSubview:view];
            self.bodyView = view;

        }

            break;
    }
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    //外框frame修改时bodyview的frame同步修改
    CGRect newFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.bodyView.frame = newFrame;
}
#pragma mark - 闪烁颜色块控制
- (void)startTimerToChangeColorOfImageView:(BodyImageView *)bodyPart {
    
    if (!bodyPart.changeColorTimer) {
        bodyPart.changeColorTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                     target:bodyPart
                                                                   selector:@selector(changeGreenColor)
                                                                   userInfo:nil
                                                                    repeats:YES];

    }

}
- (void)deallocTimerWithImageView:(BodyImageView *)bodyPart {
    [bodyPart.changeColorTimer invalidate];
    bodyPart.changeColorTimer = nil;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)closeTimer:(NSTimer *)timer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)updateViewWithModel:(MachineModel *)machine {

    [self updateBodyPart:machine];

}
#pragma mark - 参数包
- (void)resetBodyPartColor:(MachineModel *)machine {
    AirwaveModel *treatParameter = [[AirwaveModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
    if ([machine.state integerValue] != MachineStateRunning) {
        [self changeAllBodyPartsToGrey];
    }
    AirBagType type;
    if (treatParameter.APortType == AirPortType_Leg6 || treatParameter.APortType == AirPortType_Leg8) {
        type = AirBagTypeEight;
    } else {
        type = AirBagTypeThree;
    }
    if (type != self.type) {
        [self updateBodyView:type];
    }
    [self.activeBodyPartArray removeAllObjects];
    switch (treatParameter.APortType) {
        case AirPortType_Leg6:
        case AirPortType_Leg8:
        {
            [self resetBodyPartWithModel:machine startIndex:leftfootIndex startEnableIndex:0 partNumber:8];
        }
            break;
        case AirPortType_Arm3:
            [self resetBodyPartWithModel:machine startIndex:leftup3Index startEnableIndex:1 partNumber:3];
            break;
        case AirPortType_Leg3:
            [self resetBodyPartWithModel:machine startIndex:leftdown3Index startEnableIndex:1 partNumber:3];
            break;
        case AirPortType_Arm4:
            [self resetBodyPartWithModel:machine startIndex:lefthandIndex startEnableIndex:0 partNumber:4];
            break;
        case AirPortType_Leg4:
            [self resetBodyPartWithModel:machine startIndex:leftfootIndex startEnableIndex:0 partNumber:4];
            break;
        case AirPortType_Abdomen:
            [self resetBodyPartWithModel:machine startIndex:middle4Index startEnableIndex:0 partNumber:4];
            break;
        case AirPortType_Hand1:
        case AirPortType_HandRecovery:
            [self resetBodyPartWithModel:machine startIndex:lefthandIndex startEnableIndex:0 partNumber:1];
            break;
        case AirPortType_Foot1:
            [self resetBodyPartWithModel:machine startIndex:leftfootIndex startEnableIndex:0 partNumber:1];
            break;
        default:
            break;
    }
    switch (treatParameter.BPortType) {
        case AirPortType_Arm3:
            [self resetBodyPartWithModel:machine startIndex:rightup3Index startEnableIndex:5 partNumber:3];
            break;
        case AirPortType_Leg3:
            [self resetBodyPartWithModel:machine startIndex:rightdown3Index startEnableIndex:5 partNumber:3];
            break;
        case AirPortType_Arm4:
            [self resetBodyPartWithModel:machine startIndex:righthandIndex startEnableIndex:4 partNumber:4];
            break;
        case AirPortType_Leg4:
            [self resetBodyPartWithModel:machine startIndex:rightfootIndex startEnableIndex:4 partNumber:4];
            break;
        case AirPortType_Abdomen:
            [self resetBodyPartWithModel:machine startIndex:middle4Index startEnableIndex:4 partNumber:4];
            break;
        case AirPortType_Hand1:
        case AirPortType_HandRecovery:
            [self resetBodyPartWithModel:machine startIndex:righthandIndex startEnableIndex:4 partNumber:1];
            break;
        case AirPortType_Foot1:
            [self resetBodyPartWithModel:machine startIndex:rightfootIndex startEnableIndex:4 partNumber:1];
            break;
        default:
            break;
    }

    if (treatParameter.APortType == AirPortType_Leg6 || treatParameter.APortType == AirPortType_Leg8) {
        for (BodyImageView *bodypart in self.eightLegArray) {
            if (![self.activeBodyPartArray containsObject:bodypart]) {
                [bodypart changeColor:@"grey"];
            }
        }
    } else {
        for (BodyImageView *bodypart in self.bodyPartArray) {
            if (![self.activeBodyPartArray containsObject:bodypart]) {
                [bodypart changeColor:@"grey"];
            }
        }
        
    }
}
- (void)resetBodyPartWithModel:(MachineModel *)machine startIndex:(NSInteger)startIndex startEnableIndex:(NSInteger)startEnableIndex partNumber:(NSInteger)partNumber {
    AirwaveModel *treatParameter = [[AirwaveModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
    if (treatParameter) {
        for (NSInteger i = startEnableIndex; i < partNumber + startEnableIndex; i++)
        {
            BodyImageView *bodyPart = [[BodyImageView alloc]init];
            
            if (treatParameter.APortType == AirPortType_Leg6 || treatParameter.APortType == AirPortType_Leg8) {
                bodyPart = self.eightLegArray[startIndex + i - startEnableIndex];
            } else {
                
                bodyPart = self.bodyPartArray[startIndex + i - startEnableIndex];
            }
            if (bodyPart) {
                
                if ([treatParameter.portEnable[i] boolValue] == true) {
                    [bodyPart changeColor:@"yellow"];
                } else {
                    [bodyPart changeColor:@"grey"];
                }
                if (bodyPart.changeColorTimer) {
                    [bodyPart closeTimer];
                }
                [self.activeBodyPartArray addObject:bodyPart];
            }
        }
        
    }
}
#pragma mark - 实时包
- (void)updateBodyPart:(MachineModel *)machine {
    AirwaveModel *treatParameter = [[AirwaveModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
    if ([machine.state integerValue] != MachineStateRunning) {
        [self changeAllBodyPartsToGrey];
    }
    AirBagType type;
    if (treatParameter.APortType == AirPortType_Leg6 || treatParameter.APortType == AirPortType_Leg8) {
        type = AirBagTypeEight;
    } else {
        type = AirBagTypeThree;
    }
    if (type != self.type) {
        [self updateBodyView:type];
    }
    switch (treatParameter.APortType) {
        case AirPortType_Leg6:
        case AirPortType_Leg8:
        {
            [self updateBodyPartWithModel:machine startIndex:leftfootIndex startEnableIndex:0 partNumber:8];
        }
            break;
        case AirPortType_Arm3:
            [self updateBodyPartWithModel:machine startIndex:leftup3Index startEnableIndex:1 partNumber:3];
            break;
        case AirPortType_Leg3:
            [self updateBodyPartWithModel:machine startIndex:leftdown3Index startEnableIndex:1 partNumber:3];
            break;
        case AirPortType_Arm4:
            [self updateBodyPartWithModel:machine startIndex:lefthandIndex startEnableIndex:0 partNumber:4];
            break;
        case AirPortType_Leg4:
            [self updateBodyPartWithModel:machine startIndex:leftfootIndex startEnableIndex:0 partNumber:4];
            break;
        case AirPortType_Abdomen:
            [self updateBodyPartWithModel:machine startIndex:middle4Index startEnableIndex:0 partNumber:4];
            break;
        case AirPortType_Hand1:
        case AirPortType_HandRecovery:
            [self updateBodyPartWithModel:machine startIndex:lefthandIndex startEnableIndex:0 partNumber:1];
            break;
        case AirPortType_Foot1:
            [self updateBodyPartWithModel:machine startIndex:leftfootIndex startEnableIndex:0 partNumber:1];
            break;
        default:
            break;
    }
    switch (treatParameter.BPortType) {
        case AirPortType_Arm3:
            [self updateBodyPartWithModel:machine startIndex:rightup3Index startEnableIndex:5 partNumber:3];
            break;
        case AirPortType_Leg3:
            [self updateBodyPartWithModel:machine startIndex:rightdown3Index startEnableIndex:5 partNumber:3];
            break;
        case AirPortType_Arm4:
            [self updateBodyPartWithModel:machine startIndex:righthandIndex startEnableIndex:4 partNumber:4];
            break;
        case AirPortType_Leg4:
            [self updateBodyPartWithModel:machine startIndex:rightfootIndex startEnableIndex:4 partNumber:4];
            break;
        case AirPortType_Abdomen:
            [self updateBodyPartWithModel:machine startIndex:middle4Index startEnableIndex:4 partNumber:4];
            break;
        case AirPortType_Hand1:
        case AirPortType_HandRecovery:
            [self updateBodyPartWithModel:machine startIndex:righthandIndex startEnableIndex:4 partNumber:1];
            break;
        case AirPortType_Foot1:
            [self updateBodyPartWithModel:machine startIndex:rightfootIndex startEnableIndex:4 partNumber:1];
            break;
        default:
            break;
    }
}

- (void)updateBodyPartWithModel:(MachineModel *)machine startIndex:(NSInteger)startIndex startEnableIndex:(NSInteger)startEnableIndex partNumber:(NSInteger)partNumber {
    AirwaveModel *treatParameter = [[AirwaveModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
    AirwaveModel *runningParameter = [[AirwaveModel alloc]initWithDictionary:machine.msg_realTimeData error:nil];
    
    if (treatParameter) {
        for (NSInteger i = startEnableIndex; i < partNumber + startEnableIndex; i++)
        {
            BodyImageView *bodyPart = [[BodyImageView alloc]init];
            
            if (treatParameter.APortType == AirPortType_Leg6 || treatParameter.APortType == AirPortType_Leg8) {
                bodyPart = self.eightLegArray[startIndex + i - startEnableIndex];
            } else {
                
                bodyPart = self.bodyPartArray[startIndex + i - startEnableIndex];
            }
            if (bodyPart) {
                if ([treatParameter.portEnable[i] boolValue] == true) {
                    
                    if ([machine.state integerValue] == MachineStateRunning) {
                        NSInteger portState = [runningParameter.portState[i] integerValue];
                        switch (portState)
                        {
                            case AirPortState_UnWorking:
                                [bodyPart closeTimer];
                                [bodyPart changeColor:@"yellow"];
                                break;
                            case AirPortState_Working:
                                if (!bodyPart.changeColorTimer) {
                                    [self startTimerToChangeColorOfImageView:bodyPart];
                                }
                                break;
                            case AirPortState_KeepingAir:
                                [bodyPart closeTimer];
                                [bodyPart changeColor:@"green"];
                                break;
                            default:
                                break;
                        }
                    } else {
                        if (bodyPart.changeColorTimer) {
                            [bodyPart closeTimer];

                        }
                        [bodyPart changeColor:@"yellow"];
                    }
                } else {
                    [bodyPart closeTimer];
                    [bodyPart changeColor:@"grey"];
                }
            }
        }
    }
}
- (void)changeAllBodyPartsToGrey {
    for (BodyImageView *bodyPart in self.bodyPartArray) {
        if (bodyPart) {
            [bodyPart changeColor:@"grey"];
            [self closeTimer:bodyPart.changeColorTimer];

        }
    }
    for (BodyImageView *legPart in self.eightLegArray) {
        if (legPart) {
            [legPart changeColor:@"grey"];
            [self closeTimer:legPart.changeColorTimer];
        }
    }
}
- (NSMutableArray *)activePartArray {
    if (!_activeBodyPartArray) {
        _activeBodyPartArray = [NSMutableArray array];
    }
    return _activeBodyPartArray;
}
@end
