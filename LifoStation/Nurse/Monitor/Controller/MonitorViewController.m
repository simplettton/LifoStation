 //
//  MonitorViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MonitorViewController.h"
#import "FocusMachineController.h"
#import "DeviceFilterView.h"
#import "MachineModel.h"
#import "MachineParameterTool.h"
#import "NegativePressureModel.h"

#import "LightModel.h"

#import "SingleViewAirWaveCell.h"
#import "SingleElectCell.h"
#import "TwoViewsAirWaveCell.h"
#import "TwoElectCell.h"
#import "FourViewsAirWaveCell.h"
#import "FourElectCell.h"
#import "NineViewsAirWaveCell.h"
#import "NineElectCell.h"

#import "PatientInfoPopupView.h"
#import "AirWaveSetParameterView.h"

#import "UIView+TYAlertView.h"
#import "UIView+Tap.h"
#import "AlertView.h"

#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTSessionManager.h>

/** 音频库文件 */
#import <AVFoundation/AVFoundation.h>

/** 图表头文件 */
#import "AAChartKit.h"

#define USER_NAME @"admin"
#define PASSWORD @"pwd321"
#define MQTTIP @"HTTPServerIP"
#define MQTTPORT @"MQTTPort"


#define ParameterViewTag 9999
#define TimeLabelTag 8888
#define FocusViewTag 7777
#define BodyContentViewTag 6666
#define AlertViewTag 5555
#define AlertLabelTag 4444
#define ChartViewTag 3333

typedef NS_ENUM(NSInteger, PlaySoundType) {
    PlaySoundTypeNormal = 0,
    PlaySoundTypeShake,
};
@interface MonitorViewController ()<MQTTSessionManagerDelegate, MQTTSessionDelegate,AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewHeight;

@property (nonatomic, assign) NSInteger showViewType;
@property (weak, nonatomic) IBOutlet UIStackView *typeSwitchView;

@property (weak, nonatomic) IBOutlet UIButton *isShowAlertViewButton;
@property (nonatomic, assign) BOOL isShowAlertMessage;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

/** GPRS */
@property (strong, nonatomic) MQTTSessionManager *manager;
@property (strong, nonatomic) NSMutableDictionary *subscriptions;
@property (nonatomic, strong) NSArray *selectedDepartment;

//检测声音报警的定时器
@property (nonatomic, strong) NSTimer *soundTimer;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
/**
 播放器
 */
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) NSInteger playingAlertLevel;
@property (nonatomic, assign) float volumValue;
@property (nonatomic, strong) AAChartView *aaview;
@end

@implementation MonitorViewController
{
    int page;
    int totalPage;  //总页数
    BOOL isRefreshing; //是否正在下拉刷新或者上拉加载
    BOOL isFilteredList; //是否筛选
    NSMutableDictionary *filterparam;//筛选关键字
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
    filterparam = [[NSMutableDictionary alloc]init];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    [button setTitle:@" 重点关注" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:UIColorFromHex(0x6EA4E2) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showFocusMachines) forControlEvents:UIControlEventTouchUpInside];
//    button.frame=CGRectMake(0,0,100,100);//#1#硬编码设置UIButton位置、大小
    UIBarButtonItem* barButtonItem=[[UIBarButtonItem alloc]initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem=barButtonItem;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    /** 注册新定义cell */
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SingleViewAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"SingleViewAirWaveCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SingleElectCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"SingleElectCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([TwoViewsAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"TwoViewsAirWaveCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([TwoElectCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"TwoElectCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FourViewsAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"FourViewsAirWaveCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FourElectCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"FourElectCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([NineViewsAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"NineViewsAirWaveCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([NineElectCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"NineElectCell"];
    
    self.showViewType = FourViewsType;
    [self changeShowViewType:[self.typeSwitchView viewWithTag:FourViewsType]];
    
    /** 默认不显示alertview */
    _isShowAlertMessage = NO;
    self.alertView.layer.borderWidth = 0.5f;
    self.alertView.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
    
    [self connectMQTT];
    
    /** 下拉刷新控件 */
    [self initTableHeaderAndFooter];
    
    /** 初始化当前声音等级 */
    self.playingAlertLevel = 0;
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
    if (self.manager) {
        self.manager.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x3A87C7);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //mqtt
    [self.manager removeObserver:self forKeyPath:@"state" context:nil];
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
                LxDBAnyVar(@"connecting");
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
        //2921
        NSString *port = [UserDefault objectForKey:MQTTPORT];
        NSInteger portInterger = [port integerValue];
        //连接服务器
        [self.manager connectTo:ip
                           port:portInterger
                            tls:false
                      keepalive:60
                          clean:true
                           auth:true
                           user:@"admin"
                           pass:@"lifotronic.com"
                           will:nil
                      willTopic:nil
                        willMsg:nil
                        willQos:MQTTQosLevelExactlyOnce
                 willRetainFlag:false
                   withClientId:nil
                 securityPolicy:nil
                   certificates:nil
                  protocolLevel:MQTTProtocolVersion31
                 connectHandler:nil];
        
        [Constant sharedInstance].manager = self.manager;
    } else {
        [self.manager disconnectWithDisconnectHandler:nil];
        [self.manager connectToLast:^(NSError *error) {
            LxDBAnyVar(error);
        }];
        [Constant sharedInstance].manager = self.manager;
        //订阅主题 controller即将出现的时候订阅
        [self.subscriptions setObject:[NSNumber numberWithInt:MQTTQosLevelExactlyOnce] forKey:@"warning/#"];
        self.manager.subscriptions = [self.subscriptions copy];
        
        //若没有订阅设备则订阅设备

        if ([datas count] > 0) {
            for (MachineModel *machine in datas) {
                [self subcribeMachine:machine];
            }
        }
    }
}

- (void)disconnectMQTT {
    [self.subscriptions removeAllObjects];
    self.manager.subscriptions = nil;
    [self.manager disconnectWithDisconnectHandler:nil];
}

- (void)subcribeMachine:(MachineModel *)machine {
    NSArray *topicArray = @[@"device",machine.type,machine.cpuid];
    NSString *topic = [topicArray componentsJoinedByString:@"/"];

    if (![self.manager.subscriptions.allKeys containsObject:topic]) {
        [self.subscriptions setObject:[NSNumber numberWithInt:MQTTQosLevelExactlyOnce] forKey:topic];
        LxDBAnyVar(topic);
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
            machine.msg_treatParameter = content;
            /** 收到参数包代表已授权 */
            machine.hasLicense = YES;
            [self reloadItemAtIndex:index];

        } else if ([code integerValue] == 0x94) {
            NSNumber *isOnline = jsonDict[@"Data"][@"IsOnline"];
            NSNumber *hasLicense = jsonDict[@"Data"][@"HasLicense"];
            machine.isonline = [isOnline boolValue];
            machine.hasLicense = [hasLicense boolValue];

            [self reloadItemAtIndex:index];
            
        } else if ([code integerValue] == 0x95) {
            BOOL isAlertSwitchOn = [UserDefault boolForKey:@"IsAlertSwitchOn"];
            BOOL isSoundSwitchOn = [UserDefault boolForKey:@"IsSoundSwitchOn"];
            /** 打开了报警提示开关 */
            if (isAlertSwitchOn) {
                /** 报警信息栏添加信息 */
                NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]initWithCapacity:20];
                NSString *errorString = [NSString stringWithFormat:@"%@ %@ [%@] %@",[self getCurrentTimeString],(machine.departmentName == nil)?@"":machine.departmentName,machine.name,content[@"ErrMsg"]];
                
                [dataDic setObject:errorString forKey:@"error"];
                [dataDic setObject:machine.cpuid forKey:@"cpuid"];
                [dataDic setObject:jsonDict[@"Data"][@"Level"] forKey:@"level"];
                
                if (machine.msg_alertMessage) {
                    //如果当前信息与之前保存的报警信息不一致则添加到报警信息栏（之前的报警信息可以维持3s）
                    if (![machine.msg_alertMessage isEqualToString:content[@"ErrMsg"]]) {
                        if ([alertArray count] == 0) {
                            [self showBottomAlertView];
                        }
                        [alertArray insertObject:dataDic atIndex:0];
                        
                        [self.tableView reloadData];
                    }
                } else {
                    if ([alertArray count] == 0) {
                        [self showBottomAlertView];
                    }
                    [alertArray insertObject:dataDic atIndex:0];
                    [self.tableView reloadData];
                }
                
               
                /** 更新报警文字 */
                machine.msg_alertMessage = content[@"ErrMsg"];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                UIView *bodyContentView = [cell.contentView viewWithTag:BodyContentViewTag];
                UIView *alertView = [bodyContentView viewWithTag:AlertViewTag];
                UILabel *alertLabel = [alertView viewWithTag:AlertLabelTag];
                alertLabel.text = machine.msg_alertMessage;
                //边框橙色
                cell.layer.borderWidth = 2;
                cell.layer.borderColor =  UIColorFromHex(0xFBA526).CGColor;
            
                //取消3秒关闭报警提示
                [self invalidateTimer:machine.outTimeTimer];
                //开启3秒关闭报警提示
                machine.outTimeTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self
                                                                      selector:@selector(closeAlert:)
                                                                      userInfo:@{
                                                                                 @"machine":machine,
                                                                                 @"index":[NSNumber numberWithInteger:index]}
                                                                       repeats:NO];
                if (!machine.alertTimer) {
                    
                    machine.alertTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                          target:self
                                                                        selector:@selector(startFlashingAlertView:)
                                                                        userInfo:@{
                                                                                   @"machine":machine,
                                                                                   @"index":[NSNumber numberWithInteger:index]}
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
- (void)showBottomAlertView {
    self.isShowAlertMessage = YES;
    self.alertViewHeight.constant = 184;
    [self.isShowAlertViewButton setImage:[UIImage imageNamed:@"RectangleUp"] forState:UIControlStateNormal];
}
- (void)startFlashingAlertView:(NSTimer *)timer {
    
    /** 获取alertView */
    NSDictionary *dataDic = timer.userInfo;
    NSInteger index = [dataDic[@"index"]integerValue];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UIView *bodyContentView = [cell.contentView viewWithTag:BodyContentViewTag];
    UIView *alertView = [bodyContentView viewWithTag:AlertViewTag];
    
    /** 报警信息置顶 */
    [bodyContentView bringSubviewToFront:alertView];

    /** 显示与隐藏alertView */
    if (alertView.isHidden) {
        alertView.hidden = NO;
    } else {
        alertView.hidden = YES;
    }
}
- (void)closeAlert:(NSTimer *)timer {
    NSDictionary *dataDic = timer.userInfo;
    MachineModel *machine = dataDic[@"machine"];
    NSInteger index = [dataDic[@"index"]integerValue];
    machine.msg_alertMessage = nil;
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
#pragma mark - 参数包
- (void)resetbodyViewAtIndex:(NSInteger)index withModel:(MachineModel *)machine {

    NSString *machineType = machine.groupCode;
    if ([machineType integerValue] == MachineType_AirWave) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        switch (self.showViewType) {
            case SingleViewType:
            {
                SingleViewAirWaveCell *cell1 = (SingleViewAirWaveCell *)cell;
                [cell1.deviceView changeAllBodyPartsToGrey];
            }
                
                break;
            case TwoViewsType:
            {
                TwoViewsAirWaveCell *cell1 = (TwoViewsAirWaveCell *)cell;
                [cell1.deviceView changeAllBodyPartsToGrey];
            }
                
                break;
            case FourViewsType:
            {
                FourViewsAirWaveCell *cell1 = (FourViewsAirWaveCell *)cell;
                [cell1.deviceView changeAllBodyPartsToGrey];
            }
                
                break;
            case NineViewsType:
            {
                NineViewsAirWaveCell *cell1 = (NineViewsAirWaveCell *)cell;
                [cell1.deviceView changeAllBodyPartsToGrey];
            }
                
                break;
            default:
                break;
        }
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
            
            switch (self.showViewType) {
                case SingleViewType:
                {
                    SingleElectCell *cell1 = (SingleElectCell *)cell;
                    [cell1 updateDeviceImage:[machineParameter getLightName]];
                }
                    
                    break;
                case TwoViewsType:
                {
                    TwoElectCell *cell1 = (TwoElectCell *)cell;
                    [cell1 updateDeviceImage:[machineParameter getLightName]];
                }
                    
                    break;
                case FourViewsType:
                {
                    FourElectCell *cell1 = (FourElectCell *)cell;
                    [cell1 updateDeviceImage:[machineParameter getLightName]];
                }
                    
                    break;
                case NineViewsType:
                {
                    NineElectCell *cell1 = (NineElectCell *)cell;
                    [cell1 updateDeviceImage:[machineParameter getLightName]];
                }
                    
                    break;
                default:
                    break;
            }
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
        [self refreshChartAtIndex:index withMachine:machine];
    }
    
    /** 中间视图 */
    if ([machineType integerValue] == MachineType_AirWave) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        switch (self.showViewType) {
            case SingleViewType:
            {
                SingleViewAirWaveCell *cell1 = (SingleViewAirWaveCell *)cell;
                [cell1.deviceView updateViewWithModel:machine];
            }

                break;
            case TwoViewsType:
            {
                TwoViewsAirWaveCell *cell1 = (TwoViewsAirWaveCell *)cell;
                [cell1.deviceView updateViewWithModel:machine];
            }
                
                break;
            case FourViewsType:
            {
                FourViewsAirWaveCell *cell1 = (FourViewsAirWaveCell *)cell;
                [cell1.deviceView updateViewWithModel:machine];
            }
                
                break;
            case NineViewsType:
            {
                NineViewsAirWaveCell *cell1 = (NineViewsAirWaveCell *)cell;
                [cell1.deviceView updateViewWithModel:machine];
            }
                
                break;
            default:
                break;
        }
    } else if ([machineType integerValue] == MachineType_Light){
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
        switch (self.showViewType) {
            case SingleViewType:
            {
                SingleElectCell *cell1 = (SingleElectCell *)cell;
                [cell1.chartView aa_onlyRefreshTheChartDataWithChartModelSeries:aaChartModelSeriesArray];
            }
                
                break;
            case TwoViewsType:
            {
                TwoElectCell *cell1 = (TwoElectCell *)cell;
                [cell1.chartView aa_onlyRefreshTheChartDataWithChartModelSeries:aaChartModelSeriesArray];
            }
                
                break;
            case FourViewsType:
            {
                FourElectCell *cell1 = (FourElectCell *)cell;
                [cell1.chartView aa_onlyRefreshTheChartDataWithChartModelSeries:aaChartModelSeriesArray];
                
            }
                
                break;
            case NineViewsType:
            {
                NineElectCell *cell1 = (NineElectCell *)cell;
                [cell1.chartView aa_onlyRefreshTheChartDataWithChartModelSeries:aaChartModelSeriesArray];
            }
                
                break;
            default:
                break;
        }
    }
//    else {
//        if (data) {
//            AAChartModel *chartModel= AAObject(AAChartModel)
//            .chartTypeSet(AAChartTypeSpline)
//            .titleSet(@"")
//            .subtitleSet(@"")
//            .yAxisLineWidthSet(@0)//Y轴轴线线宽为0即是隐藏Y轴轴线
//            .markerRadiusSet(@0)    //圆点的大小
//            .yAxisVisibleSet(NO)
//            .xAxisVisibleSet(NO)
//            .yAxisTitleSet(@"")//设置 Y 轴标题
//            .tooltipValueSuffixSet(@"℃")//设置浮动提示框单位后缀
//            .yAxisGridLineWidthSet(@0)//y轴横向分割线宽度为0(即是隐藏分割线)
//            .legendEnabledSet(NO)//下面按钮是否显示
//            .seriesSet(@[@{
//                             @"name":@"temperature",
//                             @"data":machine.chartDataArray,
//                             @"color":@"#f8b273"
//                             },]);
//            chartModel.animationType = AAChartAnimationBounce;
//            /*图表视图对象调用图表模型对象,绘制最终图形*/
//            switch (self.showViewType) {
//                case SingleViewType:
//                {
//                    SingleElectCell *cell1 = (SingleElectCell *)cell;
//                    [cell1.chartView aa_drawChartWithChartModel:chartModel];
//                }
//
//                    break;
//                case TwoViewsType:
//                {
//                    TwoElectCell *cell1 = (TwoElectCell *)cell;
//                    [cell1.chartView aa_drawChartWithChartModel:chartModel];
//                }
//
//                    break;
//                case FourViewsType:
//                {
//                    FourElectCell *cell1 = (FourElectCell *)cell;
//                    [cell1.chartView aa_drawChartWithChartModel:chartModel];
//                }
//
//                    break;
//                case NineViewsType:
//                {
//                    NineElectCell *cell1 = (NineElectCell *)cell;
//                    [cell1.chartView aa_drawChartWithChartModel:chartModel];
//                }
//
//                    break;
//                default:
//                    break;
//            }
//        }
//    }

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
    if (isFilteredList) {
        params = filterparam;
    }
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
                                             });
                                             self.noDataView.hidden = NO;

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
    if (isFilteredList) {
        [filterparam setObject:[NSNumber numberWithInt:page] forKey:@"Page"];
        params = filterparam;
    } else {
        [params setObject:[NSNumber numberWithInt:page] forKey:@"Page"];
    }

    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/List")
                                  params:params
                                hasToken:YES
                                 success:^(HttpResponse *responseObject) {
                                     [self endRefresh];
                                     isRefreshing = NO;
                                     if (page == 0) {
                                         [datas removeAllObjects];
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
                                             });
                                             

                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.collectionView reloadData];
                                             });
                                         }
                                     }
                                     
                                 } failure:nil];
    
}
- (void)endRefresh {
    if (page == 0) {
        [self.collectionView.mj_header endRefreshing];
    }
    [self.collectionView.mj_footer endRefreshing];
}
- (void)refreshParam {
    /** 刷新设备参数 */
    [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/ReflashParam") params:@{} hasToken:YES success:^(HttpResponse *responseObject) {
        
    } failure:nil];
}
#pragma mark - LongPress Action

- (void)focusMachine:(MachineModel *)machine {

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

#pragma mark - CollectionView

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *CellIdentifier;
    UICollectionViewCell *cell;

    MachineModel *machine = datas[indexPath.row];
    switch (self.showViewType) {
        case SingleViewType:
        {

            if ([machine.groupCode integerValue] == MachineType_AirWave) {
                SingleViewAirWaveCell *cell = (SingleViewAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SingleViewAirWaveCell" forIndexPath:indexPath];
                [cell configureWithModel:machine];
                [cell.focusView addTapBlock:^(id obj) {
                    [self focusMachine:machine];
                }];
                return cell;
            } else {
                SingleElectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SingleElectCell" forIndexPath:indexPath];
                [cell configureWithModel:machine];
                [cell.focusView addTapBlock:^(id obj) {
                    [self focusMachine:machine];
                }];
                return cell;
            }
            
        }
            break;
        case TwoViewsType:
        {
            if ([machine.groupCode integerValue] == MachineType_AirWave) {
                
                TwoViewsAirWaveCell *cell = (TwoViewsAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TwoViewsAirWaveCell" forIndexPath:indexPath];
                [cell configureWithModel:machine];
                [cell.focusView addTapBlock:^(id obj) {
                    [self focusMachine:machine];
                }];
                return cell;
            } else {
                TwoElectCell *cell = (TwoElectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TwoElectCell" forIndexPath:indexPath];
                [cell configureWithModel:machine];
                [cell.focusView addTapBlock:^(id obj) {
                    
                    [self focusMachine:machine];
                }];
                return cell;
            }
        }
            break;
            
        case FourViewsType:
        {
            if ([machine.groupCode integerValue] == MachineType_AirWave) {
                CellIdentifier = @"FourViewsAirWaveCell";
                FourViewsAirWaveCell *cell = (FourViewsAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
                [cell configureWithModel:machine];
                [cell.focusView addTapBlock:^(id obj) {
                    [self focusMachine:machine];
                }];
                return cell;
            } else {
                FourElectCell *cell = (FourElectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FourElectCell" forIndexPath:indexPath];
                [cell configureWithModel:machine];

                [cell.focusView addTapBlock:^(id obj) {
                    [self focusMachine:machine];
                }];

                return cell;
            }

        }
             break;
        case NineViewsType:
        {
            if ([machine.groupCode integerValue] == MachineType_AirWave) {
                NineViewsAirWaveCell *cell = (NineViewsAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"NineViewsAirWaveCell" forIndexPath:indexPath];
                [cell configureWithModel:machine];
                [cell.focusView addTapBlock:^(id obj) {
                    [self focusMachine:machine];
                }];
                return cell;
            }
            else {
                NineElectCell *cell = (NineElectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"NineElectCell" forIndexPath:indexPath];
                [cell configureWithModel:machine];
                
                [cell.focusView addTapBlock:^(id obj) {
                    [self focusMachine:machine];
                }];
                return cell;
            }
        }
            break;
        default:
            CellIdentifier = @"SingleViewAirWaveCell";
            cell = (SingleViewAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
            return cell;
            break;
    }

    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [datas count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    /** 一宫格 */
    switch (self.showViewType) {
        case SingleViewType:
            return CGSizeMake(728, 680);
            break;
        case TwoViewsType:
            return CGSizeMake(700, 352);
            break;
        case FourViewsType:
            return CGSizeMake(342, 306);
            break;
        case NineViewsType:
            return CGSizeMake(232, 206);
            break;
        default:
            break;
    }
    return CGSizeMake(728, 680);
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
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MachineModel *model = datas[indexPath.row];
    [self performSegueWithIdentifier:@"ShowFocusMachines" sender:model];
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    [self reflashParam];
}
#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isShowAlertMessage) {
        return [alertArray count];
    } else {
        return 0;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //选中报警信息滚动到设备视图可见
    NSString *cpuid = alertArray[indexPath.row][@"cpuid"];
    if ([cpuids containsObject:cpuid]) {
        NSInteger index = [cpuids indexOfObject:cpuid];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.layer.borderWidth = 2;
        cell.layer.borderColor =  UIColorFromHex(0xFBA526).CGColor;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self reloadItemAtIndex:index];
        });
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.textColor = UIColorFromHex(0x787878);
    
    cell.textLabel.text = alertArray[indexPath.row][@"error"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    return cell;
}
#pragma mark - Action

- (IBAction)showDeviceFilter:(id)sender {

    weakself(self);
    DeviceFilterView *deviceFilterView = [[DeviceFilterView alloc]initWithLastContent:_selectedDepartment commitBlock:^(NSArray *selections) {
        weakSelf.selectedDepartment = selections;
        if ([selections count]>0) {
            isFilteredList = YES;
            [filterparam setObject:selections forKey:@"DepartmentId"];
            [self refresh];
        } else {
            isFilteredList = NO;
        }
        LxDBAnyVar(selections);
        
        
    }];
    [deviceFilterView show];

}
- (void)showFocusMachines {
    [self performSegueWithIdentifier:@"ShowFocusMachines" sender:nil];
}
- (IBAction)showAlertView:(id)sender {
    AlertView *view = [[AlertView alloc]initWithData:alertArray return:^(NSString *cpuid) {
        if ([cpuids containsObject:cpuid]) {
            //选中报警信息滚动到设备视图可见
            NSInteger index = [cpuids indexOfObject:cpuid];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            cell.layer.borderWidth = 2;
            cell.layer.borderColor =  UIColorFromHex(0xFBA526).CGColor;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reloadItemAtIndex:index];
            });
        }

    }] ;
    [view showInWindowWithBackgoundTapDismissEnable:YES];
}

- (IBAction)changeShowViewType:(id)sender {
    self.showViewType = [sender tag];
    
    for (UIButton *button in self.typeSwitchView.subviews) {
        button.selected = (button.tag == [sender tag]);
    }

    [UIView performWithoutAnimation:^{
        [self.collectionView reloadData];
    }];
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
    //    设置播放器声音
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    CGFloat systemVolume = audioSession.outputVolume;
    _player.volume = systemVolume;
    _player.delegate = self;
    _player.numberOfLoops = -1;
    [_player prepareToPlay];
    [_player play];
}
- (void)stopPlayer {
    [_player stop];
}
#pragma mark - AVAudioDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
}
#pragma mark - 懒加载
- (NSArray *)selectedDepartment {
    if (!_selectedDepartment) {
        _selectedDepartment = [NSArray array];
    }
    return _selectedDepartment;
}
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
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        CGFloat systemVolume = audioSession.outputVolume;
        
         _volumValue = systemVolume;
        _player.volume = _volumValue;
        _player.delegate = self;
        //    设置播放次数 负数代表无限循环
        _player.numberOfLoops = -1;
        //    准备播放
        [_player prepareToPlay];
      
    }
    return _player;
}
- (IBAction)volumChange:(UISlider *)sender {
    //    改变声音大小
    _player.volume = sender.value;
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowFocusMachines"]) {
        FocusMachineController *controller = (FocusMachineController *)segue.destinationViewController;
        controller.machine = (MachineModel *)sender;
        controller.manager = self.manager;
    }
}
#pragma mark - Private Method
- (NSString *)getCurrentTimeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *dateNow = [NSDate date];
    return [formatter stringFromDate:dateNow];
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
