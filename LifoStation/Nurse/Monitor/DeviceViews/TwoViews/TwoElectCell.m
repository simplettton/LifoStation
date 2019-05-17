//
//  TwoElectCell.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/28.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TwoElectCell.h"
#import "PatientInfoPopupView.h"
#import "HumidifierModel.h"
#import "LightModel.h"
#import "MachineParameterTool.h"
#import "NegativePressureModel.h"

#define kBodyViewWidth 165
#define kBodyViewHeight 226

#define kChartViewWidth 245
#define kChartViewHeight 110

#define kTimeLabelFont 25
#define kNoTimeLabelFont 20
@interface TwoElectCell()
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

/** 3 titleView */
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
/**  4 unauthorizedView */
@property (weak, nonatomic) IBOutlet UIImageView *unauthorizedView;
/**  5 bodyContents授权除外 */
@property (strong, nonatomic) IBOutletCollection(id) NSArray *bodyContents;
@end
@implementation TwoElectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = UIColorFromHex(0Xbbbbbb).CGColor;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.patientView addTapBlock:^(id obj) {
        PatientInfoPopupView *view = [[PatientInfoPopupView alloc]initWithModel:self.machine.patient];
        [view showInWindowWithBackgoundTapDismissEnable:YES];
    }];
    
    
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
    NSString *deviceImageName = [[MachineParameterTool sharedInstance]getDeviceImageName:machine];
    [self configureDeviceImage:deviceImageName];
    
    
    //信息展示
    /** 标题 */
    if ([machine.departmentName length] > 0) {
        if ([self.machine.patient.treatAddress length] > 0) {
            self.titleLabel.text = [NSString stringWithFormat:@"%@-%@-%@",machine.departmentName,self.machine.patient.treatAddress,machine.name];
        } else {
            self.titleLabel.text = [NSString stringWithFormat:@"%@-%@",machine.departmentName,machine.name];
        }
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

                } else {                //刚开始没有realtimedata 用参数信息顶替
                    NSArray *paramArray = [[MachineParameterTool sharedInstance]getParameter:machine.msg_treatParameter machine:machine];
                    if ([paramArray count] > 0) {
                        [self configureParameterViewWithData:paramArray];
                    }

                }
                if (![self.deviceView isAnimating]) {
                    [self.deviceView startAnimating];
                }
                if ([machine.groupCode integerValue] == MachineType_Light) {
                    LightModel *machineParameter = [[LightModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
                    if (machineParameter.isTemperatureOpen) {
                        self.chartView.hidden = NO;
                    } else {
                        self.chartView.hidden = YES;
                    }
                }
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

                if ([machine.groupCode integerValue] == MachineType_Light) {
                    LightModel *machineParameter = [[LightModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
                    if (machineParameter.isTemperatureOpen) {
                        self.chartView.hidden = NO;
                    } else {
                        self.chartView.hidden = YES;
                    }
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
    self.leftTimeLabel.text = [[MachineParameterTool sharedInstance]getTimeShowingText:machine];
    
    if (machine.isfocus) {
        self.heartImageView.image = [UIImage imageNamed:@"focus_fill"];
    } else {
        self.heartImageView.image = [UIImage imageNamed:@"focus_unfill"];
    }
    if (!machine.chartDataArray) {
        self.alertView.hidden = YES;
    }
    
}

- (void)updateMachineState:(MachineModel *)machine {
    machine.state = [[MachineParameterTool sharedInstance]getMachineState:machine];
    self.machine = machine;
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
            
            self.staticDeviceView.hidden = NO;
            self.leftTimeLabel.hidden = NO;
            self.statusImageView.hidden = NO;
            self.unauthorizedView.hidden = YES;
            if ([self.machine.groupCode integerValue] == MachineType_Light) {
                self.chartView.hidden = NO;
            } else {
                self.chartView.hidden = YES;
            }
            
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
            self.chartView.hidden = YES;
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
            if ([self.machine.groupCode integerValue] == MachineType_Light) {
                self.chartView.hidden = NO;
            } else {
                self.chartView.hidden = YES;
            }
            break;
        case CellStyleUnauthorized:
            
            self.layer.borderWidth = 0.5f;
            self.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
            
            for (UIView* view in self.bodyContents) {
                view.hidden = YES;
            }
            
            self.deviceView.hidden = YES;
            self.chartView.hidden = YES;
            self.staticDeviceView.hidden = YES;
            self.unauthorizedView.hidden = NO;
            break;
        default:
            break;
    }
    //wifi标志控制
    self.statusImageView.hidden = !self.machine.isonline;
    
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
#pragma mark - 中间视图更新
- (void)configureDeviceImage:(NSString *)name {
    if (!_deviceView) {
        [self addDeviceImage:name];
    } else {
        [self updateDeviceImage:name];
    }
}
//gif波形和静态图
-(void)addDeviceImage:(NSString *)name {
    //Gif 路径
    NSString *pathForFile = [[NSBundle mainBundle] pathForResource: name ofType:@"gif"];
    //转成NSData
    NSData *dataOfGif = [NSData dataWithContentsOfFile: pathForFile];
    //初始化FLAnimatedImage对象
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:dataOfGif];
    //初始化FLAnimatedImageView对象
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    
    //设置GIF图片
    CGFloat heightScale = kScreenHeight / 960;
    CGFloat widthScale = kScreenWidth / 768;
    CGFloat width = self.contentView.bounds.size.width * widthScale;
    CGFloat height = self.bodyContentView.bounds.size.height * heightScale;
    //按比例缩放
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.animatedImage = image;
    //112
    imageView.frame = CGRectMake((width - kBodyViewWidth) /2, (height-kBodyViewHeight)/2, kBodyViewWidth, kBodyViewHeight);
    
    
    /** 静态图 */
    UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake((width - kBodyViewWidth) /2, (height-kBodyViewHeight)/2, kBodyViewWidth, kBodyViewHeight)];
    imageView2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@2",name]];
    [imageView2.image setAccessibilityIdentifier:[NSString stringWithFormat:@"%@2",name]];
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
    /** 图表视图 */
    if ([self.machine.groupCode integerValue] == MachineType_Light) {
        LightModel *machineParameter = [[LightModel alloc]initWithDictionary:self.machine.msg_treatParameter error:nil];
        if (machineParameter.isTemperatureOpen) {
            [self initChartView];
        } 
    } else {
        self.chartView = nil;
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
    
    /** 图表视图 */
    if ([self.machine.groupCode integerValue] == MachineType_Light) {
        LightModel *machineParameter = [[LightModel alloc]initWithDictionary:self.machine.msg_treatParameter error:nil];
        if (machineParameter.isTemperatureOpen) {
            [self updateChartView];
        }
    }  else {
        self.chartView = nil;
    }
}
#pragma mark - 图表视图
- (void)initChartView {
    if (!self.chartView) {
        CGFloat heightScale = kScreenHeight / 960;
        CGFloat widthScale = kScreenWidth / 768;
        CGFloat width = self.contentView.bounds.size.width * widthScale;
        CGFloat height = self.bodyContentView.bounds.size.height * heightScale;
        AAChartView *chartView = [[AAChartView alloc]initWithFrame:CGRectMake(width - kChartViewWidth, height - kChartViewHeight,kChartViewWidth, kChartViewHeight)];
        chartView.backgroundColor = [UIColor clearColor];
        [self.bodyContentView addSubview:chartView];
        self.chartView = chartView;
        
        NSMutableArray *dataArray = [[NSMutableArray alloc]init];
        if (self.machine.chartDataArray) {
            dataArray = self.machine.chartDataArray;
        } else {
            [dataArray addObject:@"0"];
        }
        AAChartModel *chartModel= AAObject(AAChartModel)
        .chartTypeSet(AAChartTypeSpline)
        .titleSet(@"")
        .subtitleSet(@"")
        .yAxisLineWidthSet(@0)//Y轴轴线线宽为0即是隐藏Y轴轴线
        .markerRadiusSet(@0)    //圆点的大小
        .yAxisVisibleSet(NO)
        .xAxisVisibleSet(NO)
        .yAxisTitleSet(@"")//设置 Y 轴标题
        .tooltipValueSuffixSet(@"℃")//设置浮动提示框单位后缀
        .yAxisGridLineWidthSet(@0)//y轴横向分割线宽度为0(即是隐藏分割线)
        .legendEnabledSet(NO)//下面按钮是否显示
        .seriesSet(@[@{
                         @"name":@"temperature",
                         @"data":dataArray,
                         @"color":@"#f8b273"
                         },]);
        chartModel.animationType = AAChartAnimationBounce;
        [self.chartView aa_drawChartWithChartModel:chartModel];
    }
}
- (void)updateChartView {
    if (self.chartView && self.machine.chartDataArray) {
        NSArray *aaChartModelSeriesArray = @[@{
                                                 @"name":@"temperature",
                                                 @"type":@"spline",
                                                 @"data":self.machine.chartDataArray
                                                 },];
        [self.chartView aa_onlyRefreshTheChartDataWithChartModelSeries:aaChartModelSeriesArray];
    } else {
            [self initChartView];
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
