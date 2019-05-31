//
//  FocusMachineController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/25.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "FocusMachineController.h"
#import "MachineParameterTool.h"
#import "AirWaveSetParameterView.h"
#import "PatientInfoPopupView.h"
#import "AlertView.h"
#import "LightModel.h"
#import "SingleViewAirWaveCell.h"
#import "SingleElectCell.h"
#import "UIView+Tap.h"

#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTSessionManager.h>

#import "MachineModel.h"
/** 音频库文件 */
#import <AVFoundation/AVFoundation.h>
/** 图表头文件 */
#import "AAChartKit.h"
#define USER_NAME @"admin"
#define PASSWORD @"pwd321"
#define MQTTIP @"HTTPServerIP"
#define MQTTPORT @"MQTTPort"

@interface FocusMachineController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,MQTTSessionManagerDelegate, MQTTSessionDelegate,AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *isShowAlertViewButton;
@property (nonatomic, assign) BOOL isShowAlertMessage;

/** mqtt */

@property (strong, nonatomic) NSMutableDictionary *subscriptions;

//检测声音报警的定时器
@property (nonatomic, strong) NSTimer *soundTimer;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
/**
 播放器
 */
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) NSInteger playingAlertLevel;
@property (nonatomic, assign) float volumValue;
@end

@implementation FocusMachineController
{
    int page;
    int totalPage;  //总页数
    BOOL isRefreshing; //是否正在下拉刷新或者上拉加载

    NSMutableArray *datas;
    NSMutableArray *alertArray;
    NSMutableArray *cpuids;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
}

- (void)initAll {
    
    datas = [[NSMutableArray alloc]init];
    cpuids = [[NSMutableArray alloc]init];
    alertArray = [[NSMutableArray alloc]init];
    
    /** 注册新定义cell */
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SingleViewAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"SingleViewAirWaveCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SingleElectCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"SingleElectCell"];
    
    /** 默认展示alertview */
    _isShowAlertMessage = YES;
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.alertView.layer.borderWidth = 0.5f;
    self.alertView.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;

    if (self.machine) {
        if (self.machine.alertTimer) {
            self.machine.msg_alertMessage = nil;
            [self.machine.alertTimer invalidate];
            self.machine.alertTimer = nil;
        }
        if (self.machine.outTimeTimer) {
            [self.machine.outTimeTimer invalidate];
            self.machine.outTimeTimer = nil;
        }
        [datas addObject:self.machine];
        [cpuids addObject:self.machine.cpuid];
        [self.collectionView reloadData];
        self.title = @"";
    } else {
        self.title = @"重点关注";
        [self initTableHeaderAndFooter];
    }
    self.manager.delegate = self;
    
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    /** 关闭报警信息隐藏整个报警的tableview */
    BOOL isAlertSwitchOn = [UserDefault boolForKey:@"IsAlertSwitchOn"];
    if (!isAlertSwitchOn) {
        //留下底边框横线
        self.alertViewHeight.constant = 0.5;
//        self.alertView.hidden = YES;
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0xf8f8f8);
    self.navigationController.navigationBar.tintColor = UIColorFromHex(0x272727);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0x272727)}];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    //mqtt
    [self.manager addObserver:self
                   forKeyPath:@"state" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x3A87C7);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //mqtt
    [self.manager removeObserver:self forKeyPath:@"state" context:nil];
    
    //退出界面是关闭声音
    if (self.soundTimer) {
        //取消声音提示定时器
        [self invalidateTimer:self.soundTimer];
    }
    [self closeSounds:nil];
}
#pragma mark - MQTT
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        switch (self.manager.state) {
            case MQTTSessionManagerStateClosed:
                LxDBAnyVar(@"closed");
                break;
            case MQTTSessionManagerStateClosing:
                break;
            case MQTTSessionManagerStateConnecting:
                break;
            case MQTTSessionManagerStateConnected:
                LxDBAnyVar(@"connected");
                break;
            default:
                break;
        }
    }
}
- (void)connectMQTT {
    if (!self.manager) {
        self.manager = [[MQTTSessionManager alloc]init];
        self.manager.delegate = self;
        NSString *ip = [UserDefault objectForKey:MQTTIP];
        //21613
        NSString *port = [UserDefault objectForKey:MQTTPORT];
        //连接服务器
        [self.manager connectTo:ip
                           port:[port integerValue]
                            tls:false
                      keepalive:60
                          clean:true
                           auth:true
                           user:@"admin"
                           pass:@"pwd321"
                           will:false
                      willTopic:nil
                        willMsg:nil
                        willQos:MQTTQosLevelExactlyOnce
                 willRetainFlag:false
                   withClientId:nil
                 securityPolicy:nil
                   certificates:nil
                  protocolLevel:MQTTProtocolVersion31
                 connectHandler:nil];
        
    } else {
        [self.manager disconnectWithDisconnectHandler:nil];
        [self.manager connectToLast:^(NSError *error) {
            LxDBAnyVar(error);
        }];
        //订阅主题 controller即将出现的时候订阅
        [self.subscriptions setObject:[NSNumber numberWithInt:MQTTQosLevelExactlyOnce] forKey:@"warning/#"];
        self.manager.subscriptions = [self.subscriptions copy];
        
        //若没有订阅设备则订阅设备
        
        if (datas != nil) {
            for (MachineModel *machine in datas) {
                [self subcribeMachine:machine];
            }
        }
    }
}
- (void)subcribe:(NSString *)cpuid {
    NSString *newTopic = [NSString stringWithFormat:@"device/%@",cpuid];
    if (![self.manager.subscriptions.allKeys containsObject:newTopic]){
        [self.subscriptions setObject:[NSNumber numberWithInt:MQTTQosLevelExactlyOnce] forKey:newTopic];
        self.manager.subscriptions = [self.subscriptions copy];
    }
}
- (void)subcribeMachine:(MachineModel *)machine {
    NSArray *topicArray = @[@"device",machine.type,machine.cpuid];
    NSString *topic = [topicArray componentsJoinedByString:@"/"];
    if (![self.manager.subscriptions.allKeys containsObject:topic]) {
        [self.subscriptions setObject:[NSNumber numberWithInt:MQTTQosLevelExactlyOnce] forKey:topic];
        self.manager.subscriptions = [self.subscriptions copy];
    }
}
//receiveData
- (void)reloadItemAtIndex:(NSInteger)index {
    if ([datas count]>0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        [indexPaths addObject:indexPath];
        if (index < [datas count]) {
            [UIView performWithoutAnimation:^{
                [self.collectionView reloadItemsAtIndexPaths:indexPaths];
            }];
        }
    }
}
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSData * receiveData = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableLeaves error:nil];
    LxDBAnyVar(topic);
    LxDBAnyVar(jsonDict);
    NSNumber *code = jsonDict[@"Cmdid"];
    NSDictionary *content = jsonDict[@"Data"];
    NSArray *topicArray = [topic componentsSeparatedByString:@"/"];
    NSString *cpuid = topicArray[2];
    if ([cpuids containsObject:cpuid]) {
        NSInteger index = [cpuids indexOfObject:cpuid];
        MachineModel *machine = [datas objectAtIndex:index];
        if ([code integerValue] == 0x91) {
            machine.msg_realTimeData = content;
            machine.isonline = YES;
            [self updateCellAtIndex:index withModel:machine];
            
        } else if ([code integerValue] == 0x90) {
            NSString *currentState = machine.state;
            machine.msg_treatParameter = content;
            NSString *newState = [[MachineParameterTool sharedInstance]getMachineState:machine];
            //屏蔽电疗有实时包数据还发参数包
            if (!([currentState integerValue] == MachineStateRunning && [newState integerValue] == MachineStateRunning)) {
                /** 收到参数包代表已授权 */
                machine.hasLicense = YES;
                [self reloadItemAtIndex:index];
            }
        } else if ([code integerValue] == 0x94) {
            NSNumber *isOnline = jsonDict[@"Data"][@"IsOnline"];
            NSNumber *hasLicense = jsonDict[@"Data"][@"HasLicense"];
            machine.isonline = [isOnline boolValue];
            machine.hasLicense = [hasLicense boolValue];
            if (machine.isonline) {
                [BEProgressHUD showMessage:[NSString stringWithFormat:@"%@-%@-上线",machine.departmentName,machine.name]];
            } else {
                [BEProgressHUD showMessage:[NSString stringWithFormat:@"%@-%@-下线",machine.departmentName,machine.name]];
            }
            [self reloadItemAtIndex:index];
        } else if ([code integerValue] == 0x95) {
            BOOL isAlertSwitchOn = [UserDefault boolForKey:@"IsAlertSwitchOn"];
            BOOL isSoundSwitchOn = [UserDefault boolForKey:@"IsSoundSwitchOn"];
            
            /** 打开了报警提示开关 */
            if (isAlertSwitchOn) {
                NSNumber *level = content[@"Level"];
                NSString *oldAlertMessage = machine.msg_alertMessage;
                NSString *newAlertMessage = content[@"ErrMsg"];
                if (machine.msg_alertMessage) {
                    //如果当前信息与之前保存的报警信息不一致则添加到报警信息栏（之前的报警信息可以维持3s）
                    if (![oldAlertMessage isEqualToString:newAlertMessage]) {
                        [self refleshAlertArrayDataWithMachine:machine data:content];
                    }
                } else {
                     [self refleshAlertArrayDataWithMachine:machine data:content];
                }
                
                /** 更新报警文字 */
                machine.msg_alertMessage = newAlertMessage;
                machine.msg_alertDictionary = content;

                //取消3秒关闭报警提示
                [self invalidateTimer:machine.outTimeTimer];
                //开启3秒关闭报警提示
                machine.outTimeTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(closeAlert:) userInfo:@{
                                                                                                                                        @"machine":machine,
                                                                                                                                        @"index":[NSNumber numberWithInteger:index]} repeats:NO];
                if ((machine.alertTimer && (![oldAlertMessage isEqualToString:newAlertMessage])) || machine.alertTimer == nil) {
                    if (machine.alertTimer) {
                        [machine.alertTimer invalidate];
                        machine.alertTimer = nil;
                    }
                    //新的报警信息更新刷新频率
                    
                    machine.alertTimer = [NSTimer scheduledTimerWithTimeInterval:[self getAlertTimeIntervalWithLevel:level]
                                                                          target:self
                                                                        selector:@selector(startFlashingAlertView:)
                                                                        userInfo:@{
                                                                                   @"machine":machine,
                                                                                   @"index":[NSNumber numberWithInteger:index],
                                                                                   @"level":level
                                                                                   }
                                                                         repeats:YES];
                }
                
                /** 打开了声音开关 */
                if (isSoundSwitchOn) {
                    //取消声音提示定时器
                    [self invalidateTimer:self.soundTimer];
                    //开启关闭声音提示3s定时器
                    self.soundTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(closeSounds:) userInfo:nil repeats:NO];
                    //报警提示音
                    [self playAlertSoundsWithLevel:content[@"Level"]];
                }
            }
        }
    }
}

#pragma mark - 报警控制
- (void)refleshAlertArrayDataWithMachine:(MachineModel *)machine data:(NSDictionary *)content {
    /** 报警信息栏添加信息 */
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]initWithCapacity:20];
    NSNumber *level = content[@"Level"];
    NSString *rankLevelString = [[NSString alloc]init];
    switch ([level integerValue]) {
        case MachineAlertLevel_Low:
            rankLevelString = @"*";
            break;
        case MachineAlertLevel_Middle:
            rankLevelString = @"**";
            break;
        case MachineAlertLevel_High:
            rankLevelString = @"***";
            break;
        default:
            rankLevelString = @"";
            break;
    }
    NSString *showTime = [[NSString alloc]init];
    NSString *alertLockTime = content[@"WarnningTime"];
    if ([alertLockTime length] > 0) {
        showTime = alertLockTime;
    } else {
        showTime = [self getCurrentTimeString];
    }
    NSString *errorString = [NSString stringWithFormat:@"%@ %@ [%@] %@%@",showTime,(machine.departmentName == nil)?@"":machine.departmentName,machine.name,rankLevelString,content[@"ErrMsg"]];
    [dataDic setObject:errorString forKey:@"error"];
    [dataDic setObject:machine.cpuid forKey:@"cpuid"];
    [dataDic setObject:level forKey:@"level"];
    
    if ([alertArray count] == 0) {
        [self showBottomAlertView];
    }
    [alertArray insertObject:dataDic atIndex:0];
    [self.tableView reloadData];
}
- (NSTimeInterval)getAlertTimeIntervalWithLevel:(NSNumber *)level {
    switch ([level integerValue]) {
        case MachineAlertLevel_High:
            return 0.5;
            break;
        case MachineAlertLevel_Middle:
            return 1;
            break;
        case MachineAlertLevel_Low:
            return 0;
        default:
            return 0;
            break;
    }
}
- (NSString *)getAlertImageViewWithLevelWithLevel:(NSNumber *)level {
    if ([level integerValue] == MachineAlertLevel_High) {
        /** 一级报警红色图标 */
        return @"warm_red";
    } else {
        /** 二级三级报警黄色图标 */
        return @"warm";
    }
}
- (void)showBottomAlertView {
    self.isShowAlertMessage = YES;
    self.alertViewHeight.constant = 184;
    [self.isShowAlertViewButton setImage:[UIImage imageNamed:@"RectangleUp"] forState:UIControlStateNormal];
}
- (void)startFlashingAlertView:(NSTimer *)timer {
    
    /** 获取alertView */
    NSDictionary *dataDic = timer.userInfo;
    NSInteger index = [dataDic[@"index"]integerValue];
    MachineModel *machine = dataDic[@"machine"];
    NSInteger level = [dataDic[@"level"]integerValue];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    //边框橙色或者红色
    cell.layer.borderWidth = 2;
    cell.layer.borderColor =  [[Constant sharedInstance]getAlertColorWithLevel:dataDic[@"level"]].CGColor;
    
    UIView *bodyContentView = [cell.contentView viewWithTag:BodyContentViewTag];
    UIView *alertView = [bodyContentView viewWithTag:AlertViewTag];
    UIImageView *alertImageView = [alertView viewWithTag:AlertImageTag];
    alertImageView.image = [UIImage imageNamed:[self getAlertImageViewWithLevelWithLevel:dataDic[@"level"]]];
    UILabel *alertLabel = [alertView viewWithTag:AlertLabelTag];
    alertLabel.textColor = [[Constant sharedInstance]getAlertColorWithLevel:dataDic[@"level"]];
    alertLabel.text = machine.msg_alertMessage;
    
    /** 报警信息置顶 */
    [bodyContentView bringSubviewToFront:alertView];
    if (level == MachineAlertLevel_Low) {
        //三级报警一直显示
        alertView.hidden = NO;
    } else {
        /** 一二级报警显示与隐藏alertView */
        if (alertView.isHidden) {
            alertView.hidden = NO;
        } else {
            alertView.hidden = YES;
        }
    }
}
- (void)closeAlert:(NSTimer *)timer {
    NSDictionary *dataDic = timer.userInfo;
    MachineModel *machine = dataDic[@"machine"];
    NSInteger index = [dataDic[@"index"]integerValue];
    machine.msg_alertMessage = nil;
    machine.msg_alertDictionary = nil;
    [machine.alertTimer invalidate];
    machine.alertTimer = nil;
    /** 恢复边框颜色 */
    [self reloadItemAtIndex:index];
    
    /** 隐藏alertview */
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UIView *bodyContentView = [cell.contentView viewWithTag:BodyContentViewTag];
    UIView *alertView = [bodyContentView viewWithTag:AlertViewTag];
    alertView.hidden = YES;
    
}
- (void)closeSounds:(NSTimer *)timer {
    if ([_player isPlaying]) {
        [_player stop];
    }
    self.playingAlertLevel = 0;
}
- (void)invalidateTimer:(NSTimer *)timer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark - 实时包

- (void)updateLightSourceAtIndex:(NSInteger)index withModel:(MachineModel *)machine {
    if ([machine.groupCode integerValue] == MachineType_Light)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        LightModel *machineParameter = [[LightModel alloc]initWithDictionary:machine.msg_realTimeData error:nil];
        
        if ([machine.lightSource integerValue] != machineParameter.mainLightSource ||!machine.lightSource ) {
        SingleElectCell *cell1 = (SingleElectCell *)cell;
        [cell1 updateDeviceImage:[machineParameter getLightName]];
   
        }
        //machine中保存光源
        if (machineParameter.mainLightSource != LightSourceNull) {
            machine.lightSource = [NSString stringWithFormat:@"%ld",(long)machineParameter.mainLightSource];
        } else {
            machine.lightSource = [NSString stringWithFormat:@"%ld",(long)machineParameter.appendLightSource];;
        }
    }
}
- (void)updateCellAtIndex:(NSInteger)index withModel:(MachineModel *)machine {
    /** 右上 */
    /** 实时信息 */
    switch ([machine.state integerValue]) {
        case MachineStateRunning:
            if (machine.msg_realTimeData) {
                NSArray *paramArray = [[MachineParameterTool sharedInstance]getParameter:machine.msg_realTimeData machine:machine];
                if ([paramArray count] > 0) {
                    [self configureParameterViewAtIndex:index withData:paramArray];
                }
            }
            break;
        default:
            break;
    }
    /** 左下 */

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UIView *focusView = [cell.contentView viewWithTag:FocusViewTag];
    UILabel *leftTimeLabel = [focusView viewWithTag:TimeLabelTag];
    leftTimeLabel.text = [[MachineParameterTool sharedInstance]getTimeShowingText:machine];
    
    /** 图表 */
    NSString *machineType = machine.groupCode;
    if ([machineType integerValue] == MachineType_Light) {
        LightModel *machineParameter = [[LightModel alloc]initWithDictionary:machine.msg_treatParameter error:nil];
        if (machineParameter.isTemperatureOpen) {
            [self refreshChartAtIndex:index withMachine:machine];
        }
    }
    /** 中间视图 */
    if ([machineType integerValue] == MachineType_AirWave) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        SingleViewAirWaveCell *cell = (SingleViewAirWaveCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell.deviceView updateViewWithModel:machine];
    }
    else if ([machineType integerValue] == MachineType_Light)
    {
        [self updateLightSourceAtIndex:index withModel:machine];
    }
}

/** 根据paramter数组获取右上角 */
- (void)configureParameterViewAtIndex:(NSInteger)index withData:(NSArray *)dataArray {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UIView *bodyContentView = [cell.contentView viewWithTag:BodyContentViewTag];
    UIView *parameterView = [bodyContentView viewWithTag:ParameterViewTag];
    for (int i = 0; i < 4; i ++) {
        UILabel *label = [parameterView viewWithTag:1000+i];
        if (i < [dataArray count]) {
            label.hidden = NO;
            label.adjustsFontSizeToFitWidth = YES;
            if(dataArray[i]) {
                label.text = dataArray[i];
            }
        } else {
            label.hidden = YES;
        }
    }
}
- (NSString *)getLightName:(NSInteger)lightSource {
    
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
#pragma mark - chart
- (void)refreshChartAtIndex:(NSInteger)index withMachine:(MachineModel *)machine {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (!machine.chartDataArray) {
        machine.chartDataArray = [[NSMutableArray alloc]initWithCapacity:20];;
    }
    NSNumber *data = [[MachineParameterTool sharedInstance]getChartDataWithModel:machine];
    [machine.chartDataArray addObject:data];
    //已经有图表数据则更新，没有图标数据则新建
    if ([machine.chartDataArray count]>1) {
        if ([machine.chartDataArray count]>15) {
            [machine.chartDataArray removeObjectAtIndex:0];
        }
        NSArray *aaChartModelSeriesArray = @[@{
                                                 @"name":@"temperature",
                                                 @"type":@"spline",
                                                 @"data":machine.chartDataArray
                                                 },];
        SingleElectCell *cell1 = (SingleElectCell *)cell;
        [cell1.chartView aa_onlyRefreshTheChartDataWithChartModelSeries:aaChartModelSeriesArray];

    }
    
}
#pragma mark - AlertSounds

- (void)playAlertSoundsWithLevel:(NSNumber *)level {
    NSString *soundName = [NSString string];
    
    switch ([level integerValue]) {
        case 1:
            soundName = @"warninghigh";
            if (self.playingAlertLevel != 1) {
                [self playSoundWithName:soundName soundtype:@"wav" level:1] ;
            }
            break;
        case 2:
            soundName = @"warningmed";
            if (self.playingAlertLevel != 1 && self.playingAlertLevel != 2) {
                [self playSoundWithName:soundName soundtype:@"wav" level:2];
            }
            
            break;
        case 3:
            soundName = @"warninglow";
            if (self.playingAlertLevel == 0) {
                [self playSoundWithName:soundName soundtype:@"wav" level:3];
            }
            break;
        default:
            break;
    }
    self.playingAlertLevel = [level integerValue];
}
/**
 设置音效
 @param name 音效名称
 @param soundtype 音效类型
 
 */
- (void)playSoundWithName:(NSString *)name soundtype:(NSString *)soundtype level:(NSInteger)level
{
    [self playerInitialize:name soundtype:soundtype];
    LxDBAnyVar(@"--------------------------------------");
    self.playingAlertLevel = level;
}
- (void)playerInitialize:(NSString *)musicName soundtype:(NSString *)soundtype {
    NSError *err;
    NSURL *url = [[NSBundle mainBundle] URLForResource:musicName withExtension:soundtype];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    _volumValue = 0.5;
    _player.volume = _volumValue;
    _player.delegate = self;
    _player.numberOfLoops = -1;
    [_player prepareToPlay];
    [_player play];
}
- (void)stopPlayer {
    [_player stop];
}
#pragma mark - refresh
- (void)initTableHeaderAndFooter {
    
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    header.stateLabel.textColor =UIColorFromHex(0xABABAB);
    header.lastUpdatedTimeLabel.hidden = YES;
    self.collectionView.mj_header = header;
    
    [self.collectionView.mj_header beginRefreshing];
    
    //上拉加载
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
    self.collectionView.mj_footer = footer;
}
- (void)refresh {
    [self refreshDataWithHeader:YES];
}
- (void)loadMore {
    [self refreshDataWithHeader:NO];
}
- (void)refreshDataWithHeader:(BOOL)isPullingDown {
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:@1 forKey:@"IsFocus"];
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/List?Action=Count")
                                  params:params
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     if ([responseObject.result intValue] == 1) {
                                         [self endRefresh];
                                         NSNumber *count = responseObject.content;
                                         totalPage = ([count intValue]+10-1)/10;
                                         
                                         if (totalPage <= 1) {
                                             self.collectionView.mj_footer.hidden = YES;
                                         }else{
                                             self.collectionView.mj_footer.hidden = NO;
                                         }
                                         
                                         
                                         if([count intValue] > 0)
                                         {
                                             self.noDataView.hidden = YES;
                                             [self getNetworkDataWithHeader:isPullingDown];

                                         }else{
                                             [datas removeAllObjects];
                                             [cpuids removeAllObjects];
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.collectionView reloadData];
                                                 self.noDataView.hidden = NO;
                                             });

                                         }
                                         
                                     }
                                     
                                 }
                                 failure:nil];
    
}

- (void)getNetworkDataWithHeader:(BOOL)isPullingDown {
    if (isPullingDown) {
        page = 0;
    } else {
        page ++;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:@1 forKey:@"IsFocus"];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"Page"];

    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/List")
                                  params:params
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     [self endRefresh];
                                     isRefreshing = NO;
                                     if (page == 0) {
                                         [datas removeAllObjects];
                                         [cpuids removeAllObjects];
                                     }
                                     
                                     if (isRefreshing) {
                                         if (page >= totalPage) {
                                             [self endRefresh];
                                             
                                         }
                                         return;
                                     }
                                     isRefreshing = YES;
                                     
                                     if (page >= totalPage) {
                                         [self endRefresh];
                                         [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                         return;
                                     }
                                     
                                     if ([responseObject.result intValue] == 1) {
                                         NSArray *content = responseObject.content;
                                         LxDBAnyVar(content);
                                         if (content) {
                                             for (NSDictionary *dic in content) {
                                                 NSError *error;
                                                 MachineModel *machine = [[MachineModel alloc]initWithDictionary:dic error:&error];
                                                 [datas addObject:machine];
                                                 [cpuids addObject:machine.cpuid];
                                                 [self subcribeMachine:machine];
                                             }
                                             //等所有cell设置好再刷新数据？
                                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                 [self refreshParam];
                                             }); dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.collectionView reloadData];
                                             });
                                         }
                                     }
                                     
                                 } failure:nil];
    
}
- (void)refreshParam {
    /** 刷新设备参数 */
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/ReflashParam") params:@{} hasToken:YES success:^(HttpResponse *responseObject) {
        
    } failure:nil];
}
- (void)endRefresh {
    if (page == 0) {
        [self.collectionView.mj_header endRefreshing];
    }
    [self.collectionView.mj_footer endRefreshing];
}
#pragma mark - CollectionView
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MachineModel *machine = datas[indexPath.row];
    if ([machine.groupCode integerValue] == MachineType_AirWave) {
        
        SingleViewAirWaveCell *cell = (SingleViewAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SingleViewAirWaveCell" forIndexPath:indexPath];
        [cell configureWithModel:machine];
        [cell.focusView addTapBlock:^(id obj) {
            [self unfocusMachine:machine];
        }];
        return cell;
    } else {
        SingleElectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SingleElectCell" forIndexPath:indexPath];
        [cell configureWithModel:machine];
        [cell.focusView addTapBlock:^(id obj) {
            [self unfocusMachine:machine];
        }];
        return cell;
    }
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [datas count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightScale = kScreenHeight / 960;
    CGFloat widthScale = kScreenWidth / 768;
    return CGSizeMake(728 * widthScale, 680 * heightScale);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 40;
}
#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isShowAlertMessage) {
        if ([alertArray count] == 0) {
            return 1;
        } else {
            return [alertArray count];
        }
    } else {
        return 0;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //选中报警信息滚动到设备视图可见
    if ([alertArray count] == 0) {
        return;
    }
    NSString *cpuid = alertArray[indexPath.row][@"cpuid"];
    if ([cpuids containsObject:cpuid]) {
        NSInteger index = [cpuids indexOfObject:cpuid];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.textColor = UIColorFromHex(0x787878);
    if ([alertArray count] == 0) {
        cell.textLabel.text = @"暂时没有数据哦~";
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
    } else {
        cell.textLabel.text = alertArray[indexPath.row][@"error"];
        cell.selectionStyle =UITableViewCellSelectionStyleDefault;
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

#pragma mark - Action

- (IBAction)showAlertView:(id)sender {
    AlertView *view = [[AlertView alloc]initWithData:alertArray return:^(NSString *cpuid) {
        if ([cpuids containsObject:cpuid]) {
            //选中报警信息滚动到设备视图可见
            NSInteger index = [cpuids indexOfObject:cpuid];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        }
        
    }] ;
    [view showInWindowWithBackgoundTapDismissEnable:YES];
}
- (void)showPatientInfoView:(id)sender {
    AlertView *view = [[AlertView alloc]initWithData:alertArray return:^(NSString *cpuid) {
        if ([cpuids containsObject:cpuid]) {
            //选中报警信息滚动到设备视图可见
            NSInteger index = [cpuids indexOfObject:cpuid];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        }
        
    }] ;
    [view showInWindowWithBackgoundTapDismissEnable:YES];
}
- (IBAction)showAndHideAlertView:(id)sender {
    if (self.isShowAlertMessage) {
        self.alertViewHeight.constant = 49;
        [self.isShowAlertViewButton setImage:[UIImage imageNamed:@"RectangleDown"] forState:UIControlStateNormal];
    } else {
        self.alertViewHeight.constant = 184;
        [self.isShowAlertViewButton setImage:[UIImage imageNamed:@"RectangleUp"] forState:UIControlStateNormal];
    }
    self.isShowAlertMessage = !self.isShowAlertMessage;
    [self.tableView reloadData];
}
/** 取消关注和关注 */
- (void)unfocusMachine:(MachineModel*)machine {
    if (machine.isfocus) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"取消关注"
                                                                       message:[NSString stringWithFormat:@"确定取消关注%@吗?",machine.name]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self.collectionView reloadData];
                                                                 
                                                             }];
        UIAlertAction *focusAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSInteger index = [datas indexOfObject:machine];
            [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/Focus")
                                          params:@{@"Cpuid":machine.cpuid,@"IsFocus":@0}
                                        hasToken:YES
                                         success:^(HttpResponse *responseObject) {
                                             if ([responseObject.result integerValue] == 1 ) {
                                                 machine.isfocus = !machine.isfocus;
                                                 [BEProgressHUD showMessage:@"已取消关注"];
                                                 [self reloadItemAtIndex:index];
                                             }
                                         }
                                         failure:nil];
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:focusAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"要关注设备吗？"
                                                                       message:@"关注之后可以在关注设备中查看"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [self.collectionView reloadData];
                                                                 
                                                             }];
        UIAlertAction *focusAction = [UIAlertAction actionWithTitle:@"关注" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSInteger index = [datas indexOfObject:machine];
            [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/Focus")
                                          params:@{@"Cpuid":machine.cpuid,@"IsFocus":@1}
                                        hasToken:YES
                                         success:^(HttpResponse *responseObject) {
                                             if ([responseObject.result integerValue] == 1 ) {
                                                 machine.isfocus = !machine.isfocus;
                                                 [BEProgressHUD showMessage:@"已关注设备"];
                                                 [self reloadItemAtIndex:index];
                                             }
                                         }
                                         failure:nil];
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:focusAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
#pragma mark - Private Method
- (NSString *)getCurrentTimeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm"];
    NSDate *dateNow = [NSDate date];
    return [formatter stringFromDate:dateNow];
}

#pragma mark - getter
- (NSMutableDictionary *)subscriptions {
    if (!_subscriptions) {
        _subscriptions = [NSMutableDictionary dictionary];
    }
    return _subscriptions;
}

- (AVAudioPlayer *)player {
    if (!_player) {
        NSError *err;
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"warninglow" withExtension:@"wav"];
        //    初始化播放器
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
        //    设置播放器声音
        _volumValue = 0.5;
        _player.volume = _volumValue;
        _player.delegate = self;
        //    设置播放次数 负数代表无限循环
        _player.numberOfLoops = -1;
        //    准备播放
        [_player prepareToPlay];
        
    }
    return _player;
}
@end
