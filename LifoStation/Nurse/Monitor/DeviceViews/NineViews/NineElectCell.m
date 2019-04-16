//
//  NineElectCell.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/28.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "NineElectCell.h"
#import "HumidifierModel.h"
#import "LightModel.h"
#import "MachineParameterTool.h"
#define kBodyViewWidth 90
#define kBodyViewHeight 113
@interface NineElectCell()
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
@property (nonatomic,strong)NSTimer *alertTimer;
-(void)startFlashingAlertView;

/** 3 titleView */
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
/**  4 unauthorizedView */
@property (weak, nonatomic) IBOutlet UIImageView *unauthorizedView;
/**  5 bodyContents授权除外 */
@property (strong, nonatomic) IBOutletCollection(id) NSArray *bodyContents;
@end
@implementation NineElectCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = UIColorFromHex(0Xbbbbbb).CGColor;
}
- (void)layoutSubviews {
    [super layoutSubviews];
}
- (void)configureWithModel:(MachineModel *)machine {
    self.machine = machine;
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
    
    /** gif类型 */
    NSString *machineType = machine.groupCode;
    if (!_deviceView) {
        
        switch ([machineType integerValue]) {
            case MachineType_Humidifier:
                [self addDeviceImage:@"shihua"];
                break;
            case 6448:
                [self addDeviceImage:@"gnhw"];
                break;
            case MachineType_Light:
                [self addDeviceImage:@"rlight"];
                
                break;
            default:
                break;
        }
    } else {
        switch ([machineType integerValue]) {
            case MachineType_Humidifier:
                [self updateDeviceImage:@"shihua"];
                break;
            case 6448:
                [self updateDeviceImage:@"gnhw"];
                break;
            case MachineType_Light:
            {
                LightModel *machineParameter = [[LightModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
                /** 主光源为空的时候显示附件光源 */
                if (machineParameter.mainLightSource != LightSourceNull) {
                    [self updateDeviceImage:[self getLightName:machineParameter.mainLightSource]];
                } else {
                    [self updateDeviceImage:[self getLightName:machineParameter.appendLightSource]];
                }
                
            }
                break;
            default:
                break;
        }
        
    }
    
    NSDictionary *machineStateDic = @{
                                      @"0":@"运行中",
                                      @"1":@"暂停中",
                                      @"2":@"空闲中",
                                      @"3":@"离线"
                                      };
    //信息展示
    /** 标题 */
    if ([machine.departmentName length] > 0) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@-%@",machine.departmentName,machine.name];
    } else {
        self.titleLabel.text = machine.name;
    }
    

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
            if (![self.deviceView isAnimating]) {
                [self.deviceView startAnimating];
            }
            machine.chartView.hidden = NO;
            break;
        case MachineStateStop:
            /** 参数修改信息 修改了state 多了treattime 和 state*/
            if (machine.msg_treatParameter) {
                NSArray *paramArray = [[MachineParameterTool sharedInstance]getParameter:machine.msg_treatParameter machine:machine];
                if ([paramArray count] > 0) {
                    [self configureParameterViewWithData:paramArray];
                }
            }
            if ([self.deviceView isAnimating]) {
                [self.deviceView stopAnimating];
            }
            /** 隐藏chartview */
            self.chartView.hidden = YES;
            machine.chartView.hidden = YES;
            
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
            if ([self.deviceView isAnimating]) {
                [self.deviceView stopAnimating];
            }
            /** 显示时间 */
            if(machine.msg_realTimeData) {
                machine.leftTime = [NSString stringWithFormat:@"%@",machine.msg_realTimeData[@"ShowTime"]];
            }
            machine.chartView.hidden = NO;
            break;
        default:
            break;
    }


    
    /** 左上 */
    if (machine.patient.personName) {
        self.patientLabel.text = [NSString stringWithFormat:@"%@",machine.patient.personName];

    } else {
        self.patientLabel.text = @"未知患者";
        
    }

    self.statusLabel.text = machineStateDic[machine.state];
    self.patientLabel.adjustsFontSizeToFitWidth = YES;
    self.treatAddressLabel.adjustsFontSizeToFitWidth = YES;
    if (machine.patient.treatAddress) {
        self.treatAddressLabel.text = machine.patient.treatAddress;
    }else {
        self.treatAddressLabel.text = @"";
    }
    //静态动态判断
    if ([machine.state integerValue] == MachineStateRunning) {
        self.deviceView.hidden = NO;
        self.staticDeviceView.hidden = YES;
        
    } else {
        self.deviceView.hidden = YES;
        self.staticDeviceView.hidden = NO;
    }
    /** 左下 */
    self.leftTimeLabel.text = [self getHourAndMinuteFromSeconds:machine.leftTime];
    if (machine.isfocus) {
        self.heartImageView.image = [UIImage imageNamed:@"focus_fill"];
    } else {
        self.heartImageView.image = [UIImage imageNamed:@"focus_unfill"];
    }
}
- (NSString *)getLightName:(NSInteger)lightSource {
    if ([self.machine.state integerValue] != MachineStateRunning) {
        return @"rlight";
    } else {
        switch (lightSource) {
            case LightSourceNull:
                return @"rlight";
                break;
            case LightSourceRed:
                return @"rlight";
                break;
            case LightSourceBlue:
                return @"blight";
                break;
            case LightSourceRedAndBlue:
                return @"rblight";
                break;
            default:
                return nil;
                break;
        }
    }
}
- (void)configureCellStyle {
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
            self.deviceView.hidden = NO;
            self.staticDeviceView.hidden = NO;
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
                if (![view isEqual:self.focusView]) {
                    view.hidden = YES;
                }
            }
            self.leftTimeLabel.hidden = YES;
            self.focusView.hidden = NO;
            self.deviceView.hidden = NO;
            self.staticDeviceView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            break;
            /** 有报警信息的设备 */
        case CellStyleAlert:
            self.statusImageView.hidden = NO;
            self.layer.borderWidth = 2.0f;
            self.layer.borderColor = UIColorFromHex(0xFBA526).CGColor;
            self.deviceView.hidden = NO;
            self.staticDeviceView.hidden = NO;
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
            self.staticDeviceView.hidden = YES;
            self.unauthorizedView.hidden = NO;
            break;
        default:
            break;
    }
    //wifi标志控制
    
    self.statusImageView.hidden = !self.machine.isonline;
}

- (void)updateMachineState:(MachineModel *)machine {
    machine.state = [NSString stringWithFormat:@"%@",machine.msg_treatParameter[@"State"]];
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
//gif波形和静态图
-(void)addDeviceImage:(NSString *)name {
    //GIF 转 NSData
    //Gif 路径
    NSString *pathForFile = [[NSBundle mainBundle] pathForResource: name ofType:@"gif"];
    //转成NSData
    NSData *dataOfGif = [NSData dataWithContentsOfFile: pathForFile];
    //初始化FLAnimatedImage对象
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:dataOfGif];
    //初始化FLAnimatedImageView对象
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    
    //设置GIF图片
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = self.bodyContentView.bounds.size.height;
    //按比例缩放
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.animatedImage = image;
    //112
    imageView.frame = CGRectMake((width - kBodyViewWidth) /2, (height-kBodyViewHeight)/2, kBodyViewWidth, kBodyViewHeight);
    
    
    /** 静态图 */
    UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake((width - kBodyViewWidth) /2, (height-kBodyViewHeight)/2, kBodyViewWidth, kBodyViewHeight)];
    imageView2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@2",name]];
    [imageView2 setContentMode:UIViewContentModeScaleAspectFit];
    if (!self.staticDeviceView) {
        [self.bodyContentView addSubview:imageView2];
        self.staticDeviceView = imageView2;
    }
    
    
    /** 动态图 */
    if (!self.deviceView) {
        [self.bodyContentView addSubview:imageView];
        self.deviceView = imageView;
    }

}
- (void)updateDeviceImage:(NSString *)name {
    /** 静态图 */
    self.staticDeviceView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@2",name]];
    
    /** 动态图*/
    NSString *pathForFile = [[NSBundle mainBundle] pathForResource: name ofType:@"gif"];
    NSData *dataOfGif = [NSData dataWithContentsOfFile: pathForFile];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:dataOfGif];
    self.deviceView.animatedImage = image;
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
