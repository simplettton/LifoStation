//
//  FourViewsAirWaveCell.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/18.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "FourViewsAirWaveCell.h"
#import "PatientInfoPopupView.h"
#import "MachineParameterTool.h"
#define kBodyViewWidth 137
#define kBodyViewHeight 187
@interface FourViewsAirWaveCell()
@property (weak, nonatomic) IBOutlet UIView *bodyContentView;

//1 右上
@property (weak, nonatomic) IBOutlet UIView *parameterView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;
@property (weak, nonatomic) IBOutlet UILabel *forthLabel;

/** 2 alert */
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UILabel *alertMessageLabel;

/** 3 titleView */
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
/**  4 unauthorizedView */
@property (weak, nonatomic) IBOutlet UIImageView *unauthorizedView;
/**  5 bodyContents授权除外 */
@property (strong, nonatomic) IBOutletCollection(id) NSArray *bodyContents;
@end
@implementation FourViewsAirWaveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.machine.patient.personName) {
        [self.patientView addTapBlock:^(id obj) {
            PatientInfoPopupView *view = [[PatientInfoPopupView alloc]initWithModel:self.machine.patient];
            [view showInWindowWithBackgoundTapDismissEnable:YES];
        }];
    }
}


- (void)configureWithModel:(MachineModel *)machine {
    self.machine = machine;
    
    /** 更新cellstyle */
    if (!machine.isonline) {
        self.style = CellStyleOffLine;

    } else {
        if (!machine.hasLicense) {
            self.style = CellStyleUnauthorized;
            [self configureCellStyle];
            return;
        } else {
            if (machine.msg_alertMessage) {
                self.style = CellStyleAlert;
            } else {
                self.style = CellStyleOnline;
            }
        }
        
        
    }
    [self configureCellStyle];
    
    /** 更新machine state */
    if (machine.msg_treatParameter && ![machine.msg_treatParameter isKindOfClass:[NSNull class]]) {
        [self updateMachineState:machine];
    }
    /** 更新当前deviceView */
    if (!self.deviceView) {
        NSError *error;
        AirwaveModel *machineParameter = [[AirwaveModel alloc]initWithDictionary:machine.msg_treatParameter error:&error];
        AirWaveView *bodyView = [[AirWaveView alloc]initWithParameter:machineParameter];
        CGFloat width = self.contentView.bounds.size.width;
        bodyView.frame = CGRectMake((width-kBodyViewWidth)/2, 55, kBodyViewWidth, kBodyViewHeight);
        [self.bodyContentView addSubview:bodyView];
        self.deviceView = bodyView;
        
        //alertview置顶
        [self.bodyContentView bringSubviewToFront:self.alertView];
    } else {
        [self.deviceView resetBodyPartColor:machine];
        [self.deviceView updateViewWithModel:machine];
    }
    

    //信息展示
    /** 标题 */
    if ([machine.departmentName length] > 0) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@-%@",machine.departmentName,machine.name];
    } else {
        self.titleLabel.text = machine.name;
    }
    
    if (machine.isonline) {
        /** 右上 */
        /** 实时信息和lefttime更新 */
        switch ([machine.state integerValue]) {
            case MachineStateRunning:
                
                if (machine.msg_realTimeData) {
                    NSArray *paramArray = [[MachineParameterTool sharedInstance]getParameter:machine.msg_realTimeData machine:machine];
                    if ([paramArray count] > 0) {
                        [self configureParameterViewWithData:paramArray];
                    }
                    /** 显示时间ShowTime 秒为单位 */
                    machine.leftTime = [NSString stringWithFormat:@"%@",machine.msg_realTimeData[@"ShowTime"]];
                } else {                //刚开始没有realtimedata 用参数信息顶替
                    NSArray *paramArray = [[MachineParameterTool sharedInstance]getParameter:machine.msg_treatParameter machine:machine];
                    if ([paramArray count] > 0) {
                        [self configureParameterViewWithData:paramArray];
                    }
                    machine.leftTime = [NSString stringWithFormat:@"%ld",[machine.msg_treatParameter[@"TreatTime"]integerValue]*60];
                }
                

                break;
            case MachineStateStop:
                /** 参数修改信息 修改了state 多了treattime 和 state*/
                if (machine.msg_treatParameter) {
                    NSArray *paramArray = [[MachineParameterTool sharedInstance]getParameter:machine.msg_treatParameter machine:machine];
                    if ([paramArray count] > 0) {
                        [self configureParameterViewWithData:paramArray];
                    }
                    [self.deviceView resetBodyPartColor:machine];
                    [self.deviceView updateViewWithModel:machine];
                }
                
                /** 显示时间TreatTime分钟为单位 */
                machine.leftTime = [NSString stringWithFormat:@"%ld",[machine.msg_treatParameter[@"TreatTime"]integerValue]*60];
                break;
            case MachineStatePause:
                /** 参数修改信息 修改了state 多了treattime 和 state*/
                if (machine.msg_treatParameter) {
                    NSArray *paramArray = [[MachineParameterTool sharedInstance]getParameter:machine.msg_treatParameter machine:machine];
                    if ([paramArray count] > 0) {
                        [self configureParameterViewWithData:paramArray];
                    }
                }
                [self.deviceView resetBodyPartColor:machine];
                [self.deviceView updateViewWithModel:machine];
                
                /** 显示时间 */
                if(machine.msg_realTimeData) {
                    machine.leftTime = [NSString stringWithFormat:@"%@",machine.msg_realTimeData[@"ShowTime"]];
                }

                break;
            default:
                break;
        }
        /** 左上 */
        if (machine.patient.personName) {
            self.patientLabel.text = [NSString stringWithFormat:@"%@-%@",machine.patient.personName,[[MachineParameterTool sharedInstance]getStateShowingText:machine]];
        } else {
            self.patientLabel.text = [NSString stringWithFormat:@"未知患者-%@",[[MachineParameterTool sharedInstance]getStateShowingText:machine]];
        }
        self.patientLabel.adjustsFontSizeToFitWidth = YES;
        if (machine.patient.treatAddress) {
            self.treatAddressLabel.text = machine.patient.treatAddress;
        } else {
            self.treatAddressLabel.text = machine.patient.treatAddress;
        }
        
        self.treatAddressLabel.adjustsFontSizeToFitWidth = YES;

    } else {
        [self.deviceView changeAllBodyPartsToGrey];
    }
    
    /** 左下 */
    
    self.leftTimeLabel.text = [self getHourAndMinuteFromSeconds:machine.leftTime];
    if (machine.isfocus) {
        self.heartImageView.image = [UIImage imageNamed:@"focus_fill"];
    } else {
        self.heartImageView.image = [UIImage imageNamed:@"focus_unfill"];
    }
    if (!machine.chartDataArray) {
        self.alertView.hidden = YES;
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
            self.deviceView.hidden = NO;
            self.leftTimeLabel.hidden = NO;
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
            self.deviceView.hidden = NO;
            [self.deviceView changeAllBodyPartsToGrey];
            self.unauthorizedView.hidden = YES;
            break;
            /** 有报警信息的设备 */
        case CellStyleAlert:
            self.statusImageView.hidden = NO;
            self.layer.borderWidth = 2.0f;
            self.layer.borderColor = UIColorFromHex(0xFBA526).CGColor;
            self.deviceView.hidden = NO;
            self.leftTimeLabel.hidden = NO;
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
            
            self.deviceView.hidden = YES;
            self.unauthorizedView.hidden = NO;
            break;
        default:
            break;
    }
    //wifi标志控制
    self.statusImageView.hidden = !self.machine.isonline;

}
- (void)updateMachineState:(MachineModel *)machine {
    machine.state = [[MachineParameterTool sharedInstance]getMachineState:machine];
    self.machine = machine;
}
- (void)configureParameterViewWithData:(NSArray *)dataArray {
    for (int i = 0; i < 4; i ++) {
        UILabel *label = [self.parameterView viewWithTag:1000+i];
        if (i < [dataArray count]) {
            label.hidden = NO;
            label.adjustsFontSizeToFitWidth = YES;
            label.text = dataArray[i];
        } else {
            label.hidden = YES;
        }
    }
}
- (NSString *)getHourAndMinuteFromSeconds:(NSString *)totalTime {
    NSInteger seconds = [totalTime integerValue];
    
    //format of hour
    NSString *HourString = [NSString stringWithFormat:@"%02ld",seconds/3600];
    NSString *minuterString = [NSString stringWithFormat:@"%02ld",(seconds % 3600)/60];
    NSString *secondString = [NSString stringWithFormat:@"%02ld",seconds%60];
    NSString *formatTime = [NSString stringWithFormat:@"%@:%@:%@",HourString,minuterString,secondString];
    return formatTime;
}
@end
