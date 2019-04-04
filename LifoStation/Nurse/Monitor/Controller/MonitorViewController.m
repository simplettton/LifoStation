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
/** 短频音效播放 */
#import <AudioToolbox/AudioToolbox.h>
/** 音频库文件 */
#import <AVFoundation/AVFoundation.h>

#define USER_NAME @"admin"
#define PASSWORD @"pwd321"
#define MQTTIP @"HTTPServerIP"
#define MQTTPORT @"MQTTPort"
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

//检测报警的定时器
@property (nonatomic, strong) NSTimer *alerTimer;
@property (weak, nonatomic) IBOutlet UIView *noDataView;
/**
 播放器
 */
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) NSInteger playingAlertLevel;
@property (nonatomic, assign) float volumValue;

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
    
    /** 默认展示alertview */
    _isShowAlertMessage = YES;
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
            [self.collectionView reloadItemsAtIndexPaths:indexPaths];
        }
    }
}
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {

    NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSData * receiveData = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableLeaves error:nil];
//    LxDBAnyVar(topic);
//    LxDBAnyVar(jsonDict);
    NSNumber *code = jsonDict[@"Cmdid"];
    NSArray *content = jsonDict[@"Data"];
    NSArray *topicArray = [topic componentsSeparatedByString:@"/"];
    NSString *cpuid = topicArray[2];
    if ([cpuids containsObject:cpuid]) {
        NSInteger index = [cpuids indexOfObject:cpuid];
        MachineModel *machine = [datas objectAtIndex:index];
        if ([code integerValue] == 0x91) {
            //等3秒才去除报警信息
            machine.msg_realTimeData = content;

        } else if ([code integerValue] == 0x90) {
            machine.msg_treatParameter = content;

        } else if ([code integerValue] == 0x94) {
            NSNumber *isOnline = jsonDict[@"Data"][@"IsOnline"];
            machine.isonline = [isOnline boolValue];
        } else if ([code integerValue] == 0x95) {
            BOOL isAlertSwitchOn = [UserDefault boolForKey:@"IsAlertSwitchOn"];
            BOOL isSoundSwitchOn = [UserDefault boolForKey:@"IsSoundSwitchOn"];
            
            if (isAlertSwitchOn) {
                machine.msg_alertMessage = jsonDict[@"Data"][@"ErrMsg"];
                //取消3秒关闭报警提示
                [self invalidateTimer:machine.outTimeTimer];
                //开启3秒关闭报警提示
                machine.outTimeTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(closeAlert:) userInfo:machine repeats:NO];
                
                //取消声音提示定时器
                [self invalidateTimer:self.alerTimer];
                //开启关闭声音提示3s定时器
                self.alerTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(closeSounds:) userInfo:nil repeats:NO];
                if (isSoundSwitchOn) {
                    //报警提示音
                    [self playAlertSoundsWithLevel:jsonDict[@"Data"][@"Level"]];
                }
            }
            
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]initWithCapacity:20];
            NSString *errorString = [NSString stringWithFormat:@"%@ %@[%@] %@",[self getCurrentTimeString],(machine.departmentName == nil)?@"":machine.departmentName,machine.name,machine.msg_alertMessage];
            [dataDic setObject:errorString forKey:@"error"];
            [dataDic setObject:machine.cpuid forKey:@"cpuid"];
            [dataDic setObject:jsonDict[@"Data"][@"Level"] forKey:@"level"];

            [alertArray addObject:dataDic];
            [self.tableView reloadData];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadItemAtIndex:index];
        });
    }
}
- (void)closeAlert:(NSTimer *)timer {
    MachineModel *machine = [timer userInfo];
    machine.msg_alertMessage = nil;
    NSInteger index = [cpuids indexOfObject:machine.cpuid];
    [self reloadItemAtIndex:index];
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
                                             
                                             //                                             [self hideNodataView];
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
                                             /** 刷新设备参数 */
//                                             [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(@"api/DevicesController/ReflashParam") params:@{} hasToken:YES success:nil failure:nil];
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

            if ([machine.type integerValue] == 1234) {

                SingleViewAirWaveCell *cell = (SingleViewAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SingleViewAirWaveCell" forIndexPath:indexPath];
                [cell configureWithAirBagType:AirBagTypeThree message:nil];
                return cell;
            } else {
                SingleElectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SingleElectCell" forIndexPath:indexPath];
                [cell configureWithModel:machine];
                [cell.focusView addTapBlock:^(id obj) {
                    [self focusMachine:machine];
                }];
                return cell;
            }
//            if (indexPath.row %4 == 0) {
////                [cell configureWithAirBagType:AirBagTypeThree message:nil];
////                cell.style = CellStyleOffLine;
//                [cell configureWithCellStyle:CellStyleOffLine airBagType:AirBagTypeThree message:nil];
//
//            } else if (indexPath.row %4 == 1) {
//                [cell configureWithAirBagType:AirBagTypeEight message:@"运行中不可以切换气囊"];
//                [cell.bodyView flashingTest];
//                cell.style = CellStyleAlert;
//
//            } else if (indexPath.row %4 == 2) {
//                [cell configureWithAirBagType:AirBagTypeThree message:nil];
//                cell.style = CellStyleUnauthorized;
//            }
//            else {
//                [cell configureWithAirBagType:AirBagTypeEight message:nil];
//                cell.style = CellStyleOnline;
//            }
            

//            [cell.parameterView addTapBlock:^(id obj) {
//                AirWaveSetParameterView *view = [AirWaveSetParameterView createViewFromNib];
//                [view showInWindow];
//            }];
//            [cell.focusView addTapBlock:^(id obj) {
//                [self focusMachine:indexPath];
//            }];
            return cell;
            
        }
            break;
        case TwoViewsType:
        {
            if ([machine.type integerValue] == 1234) {
                
                TwoViewsAirWaveCell *cell = (TwoViewsAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TwoViewsAirWaveCell" forIndexPath:indexPath];
                [cell configureWithAirBagType:AirBagTypeEight];
                return cell;
            } else {
                TwoElectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TwoElectCell" forIndexPath:indexPath];
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
            if ([machine.type integerValue] == 1234) {
                CellIdentifier = @"FourViewsAirWaveCell";
                FourViewsAirWaveCell *cell = (FourViewsAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
                [cell configureWithAirBagType:AirBagTypeEight];
                return cell;
            }
            else {
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
            if ([machine.type integerValue] == 1234) {
                NineViewsAirWaveCell *cell = (NineViewsAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"NineViewsAirWaveCell" forIndexPath:indexPath];
                [cell configureWithAirBagType:AirBagTypeEight];
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
            
            return cell;
        }
            break;
        default:
            CellIdentifier = @"SingleViewAirWaveCell";
            cell = (SingleViewAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
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

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isShowAlertMessage) {
//        return 3;
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
        }

    }] ;
    [view showInWindowWithBackgoundTapDismissEnable:YES];
}

- (IBAction)changeShowViewType:(id)sender {
    self.showViewType = [sender tag];
    
    for (UIButton *button in self.typeSwitchView.subviews) {
        button.selected = (button.tag == [sender tag]);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });

    /** 滑到第一格 */
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
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
            soundName = @"genhigh";
            if (self.playingAlertLevel != 1) {
                [self playSoundWithName:soundName soundtype:@"wav" level:1] ;
            }
            break;
        case 2:
            soundName = @"genmed";
            if (self.playingAlertLevel != 1 && self.playingAlertLevel != 2) {
                [self playSoundWithName:soundName soundtype:@"wav" level:2];
            }

            break;
        case 3:
            soundName = @"genlow";
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

- (NSString *)getCurrentTimeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *dateNow = [NSDate date];
    return [formatter stringFromDate:dateNow];
}
- (AVAudioPlayer *)player {
    if (!_player) {
        NSError *err;
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"genlow" withExtension:@"wav"];
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
- (IBAction)volumChange:(UISlider *)sender {
    //    改变声音大小
    _player.volume = sender.value;
}
- (IBAction)player:(id)sender {
    //    开始播放
    [_player play];
}

- (IBAction)stop:(id)sender {
    //    暂停播放
    [_player stop];
}
#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowFocusMachines"]) {
        FocusMachineController *controller = (FocusMachineController *)segue.destinationViewController;
        controller.machine = (MachineModel *)sender;
        controller.manager = self.manager;
    }
}
@end
