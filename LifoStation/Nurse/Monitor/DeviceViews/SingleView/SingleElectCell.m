//
//  SingleElectCell.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/27.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "SingleElectCell.h"
#import "PatientInfoPopupView.h"
#define kBodyViewWidth 262
#define kBodyViewHeight 358
@interface SingleElectCell()
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
@implementation SingleElectCell

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
    
    
    /** gif类型 */
    NSString *machineType = machine.type;
    if (!_deviceView) {
        
        switch ([machineType integerValue]) {
            case 122:
                [self showWaveImage:@"shihua"];
                break;
                
            default:
                break;
        }
    }
    
    //静态动态判断
    if ([machine.state integerValue] == MachineStateRunning) {
        self.deviceView.hidden = NO;
        self.staticDeviceView.hidden = YES;
        
    } else {
        self.deviceView.hidden = YES;
        self.staticDeviceView.hidden = NO;
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
        if ([self.machine.patient.treatAddress length] > 0) {
            self.titleLabel.text = [NSString stringWithFormat:@"%@-%@-%@",machine.departmentName,self.machine.patient.treatAddress,machine.name];
        } else {
            self.titleLabel.text = [NSString stringWithFormat:@"%@-%@",machine.departmentName,machine.name];
        }
    } else {
        self.titleLabel.text = machine.name;
    }
    
    /** 左上 */
    self.patientLabel.text = [NSString stringWithFormat:@"%@-%@",machine.patient.personName,machineStateDic[machine.state]];
    self.patientLabel.adjustsFontSizeToFitWidth = YES;
    self.treatAddressLabel.text = machine.patient.treatAddress;
    self.treatAddressLabel.adjustsFontSizeToFitWidth = YES;
    
    /** 左下 */
    self.leftTimeLabel.text = [self getHourAndMinuteFromSeconds:machine.leftTime];
    if (machine.isfocus) {
        self.heartImageView.image = [UIImage imageNamed:@"focus_fill"];
    } else {
        self.heartImageView.image = [UIImage imageNamed:@"focus_unfill"];
    }
    
    //报警信息置顶
    if (machine.msg_alertMessage != nil) {
        self.alertMessageLabel.text = machine.msg_alertMessage;
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
    /** 右上 */
    if (machine.msg_realTimeData) {
        NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
        for (NSDictionary *dic in machine.msg_realTimeData) {
            NSString *key = dic[@"Key"];
            NSString *value  = dic[@"Value"];
            if ([key isEqualToString:@"Time"]) {
                machine.leftTime = value;
                self.machine.leftTime = value;
            } else {
                [paramArray addObject:[NSString stringWithFormat:@"%@:%@",key,value]];
            }
        }
        
        if ([paramArray count] > 0) {
            [self configureParameterViewWithData:paramArray];
        }
    }
    /** 左下 */
    self.leftTimeLabel.text = [self getHourAndMinuteFromSeconds:machine.leftTime];
    if (machine.isfocus) {
        self.heartImageView.image = [UIImage imageNamed:@"focus_fill"];
    } else {
        self.heartImageView.image = [UIImage imageNamed:@"focus_unfill"];
    }
}
//报警视图闪烁效果
- (void)startFlashingAlertView {
    if (self.alertView.isHidden) {
        self.alertView.hidden = NO;
    } else {
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
                if (![view isEqual:self.alertView]) {
                    view.hidden = NO;
                }
            }
            self.deviceView.hidden = NO;
            self.staticDeviceView.hidden = NO;
            
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

- (void)configureParameterViewWithData:(NSMutableArray *)dataArray {
    for (int i = 0; i < [dataArray count]; i ++) {
        UILabel *label = [self.parameterView viewWithTag:1000+i];
        label.hidden = NO;
        label.adjustsFontSizeToFitWidth = YES;
        label.text = dataArray[i];
        
    }
}
//gif波形和静态图
-(void)showWaveImage:(NSString *)name {
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
    
    
    [self.bodyContentView addSubview:imageView];
    self.deviceView = imageView;
    
    UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake((width - kBodyViewWidth) /2, (height-kBodyViewHeight)/2, kBodyViewWidth, kBodyViewHeight)];
    imageView2.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@2",name]];
    [imageView2 setContentMode:UIViewContentModeScaleAspectFit];
    [self.bodyContentView addSubview:imageView2];
    
    self.staticDeviceView = imageView2;
}
- (NSString *)getHourAndMinuteFromSeconds:(NSString *)totalTime {
    NSInteger seconds = [totalTime integerValue];
    
    //format of hour
    NSString *HourString = [NSString stringWithFormat:@"%02ld",seconds/3600];
    NSString *minuterString = [NSString stringWithFormat:@"%02ld",(seconds % 3600)/60];
    NSString *fomatTime = [NSString stringWithFormat:@"%@:%@",HourString,minuterString];
    return fomatTime;
}
@end
