 //
//  MonitorViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MonitorViewController.h"

#import "DeviceFilterView.h"

#import "SingleViewAirWaveCell.h"
#import "TwoViewsAirWaveCell.h"
#import "FourViewsAirWaveCell.h"
#import "FourElectCell.h"
#import "NineViewsAirWaveCell.h"

#import "PatientInfoPopupView.h"
#import "AirWaveSetParameterView.h"

#import "UIView+TYAlertView.h"
#import "UIView+Tap.h"
#import "AlertView.h"

#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTSessionManager.h>

#import "MachineModel.h"

#define USER_NAME @"admin"
#define PASSWORD @"pwd321"
#define MQTTIP @"HTTPServerIP"
#define MQTTPORT @"MQTTPORT"
@interface MonitorViewController ()<MQTTSessionManagerDelegate, MQTTSessionDelegate>
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
@property (nonatomic, strong) NSArray *selectedDevices;
@end

@implementation MonitorViewController
{
    int page;
    int totalPage;  //总页数
    BOOL isRefreshing; //是否正在下拉刷新或者上拉加载
    BOOL isFilteredList; //是否筛选
    NSMutableDictionary *filterparam;//筛选关键字
    NSMutableArray *datas;
    NSMutableArray *cpuids;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
}

- (void)initAll {
    
    datas = [[NSMutableArray alloc]init];
    cpuids = [[NSMutableArray alloc]init];
    
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
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([TwoViewsAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"TwoViewsAirWaveCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FourViewsAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"FourViewsAirWaveCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FourElectCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"FourElectCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([NineViewsAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"NineViewsAirWaveCell"];
    
    self.showViewType = FourViewsType;
    [self changeShowViewType:[self.typeSwitchView viewWithTag:FourViewsType]];
    
    /** 默认展示alertview */
    _isShowAlertMessage = YES;
    self.alertView.layer.borderWidth = 0.5f;
    self.alertView.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
    
    /** 设备添加 longpress 添加手势 可以关注设备 */
//    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePressMoving:)];
//    [self.collectionView addGestureRecognizer:_longPress];
    
    /** 下拉刷新控件 */
    [self initTableHeaderAndFooter];
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
}
#pragma mark - MQTT
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        LxDBAnyVar(self.manager.state);
        switch (self.manager.state) {
            case MQTTSessionManagerStateClosed:

                break;
            case MQTTSessionManagerStateClosing:
                break;
            case MQTTSessionManagerStateConnecting:
                break;
            case MQTTSessionManagerStateConnected:
                
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
                [self subcribe:machine.cpuid];
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
            [self.collectionView reloadItemsAtIndexPaths:indexPaths];
        }
    }
}
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSData * receiveData = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:receiveData options:NSJSONReadingMutableLeaves error:nil];
    NSNumber *code = jsonDict[@"Cmdid"];
    NSDictionary *content = jsonDict[@"Data"];
    NSArray *topicArray = [topic componentsSeparatedByString:@"/"];
    NSString *cpuid = topicArray[2];
    if ([cpuids containsObject:cpuid]) {
        NSInteger index = [cpuids indexOfObject:cpuids];
        MachineModel *machine = [datas objectAtIndex:index];
        if ([code integerValue] == 0x91) {
            //等3秒才去除报警信息
            machine.msg_realTimeData = content;
            if (machine.msg_alertMessage !=nil) {
                dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
                dispatch_after(timer, dispatch_get_main_queue(), ^{
                    machine.msg_alertMessage = nil;
                    [self reloadItemAtIndex:index];
                });
            }

        } else if ([code integerValue] == 0x90) {
            machine.msg_treatParameter = content;
            if (machine.msg_alertMessage !=nil) {
                dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
                dispatch_after(timer, dispatch_get_main_queue(), ^{
                    machine.msg_alertMessage = nil;
                    [self reloadItemAtIndex:index];
                });
            }
        } else if ([code integerValue] == 0x95) {
            machine.msg_alertMessage = content[@"error"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadItemAtIndex:index];
        });
    }

    
}
#pragma mark - refresh
-(void)initTableHeaderAndFooter{
    
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    header.stateLabel.textColor =UIColorFromHex(0xABABAB);
    header.lastUpdatedTimeLabel.hidden = YES;
    self.collectionView.mj_header = header;
    
    [self.tableView.mj_header beginRefreshing];
    
    //上拉加载
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
    self.collectionView.mj_footer = footer;
}
- (void)refresh {
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.collectionView reloadData];
//        // 结束刷新
//        [self.collectionView.mj_header endRefreshing];
//    });
    [self refreshDataWithHeader:YES];
}
- (void)loadMore {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // 结束刷新
//        [self.collectionView.mj_footer endRefreshing];
//    });
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
                                             
                                             [self getNetworkDataWithHeader:isPullingDown];
                                             //                                             [self hideNodataView];
                                         }else{
                                             [datas removeAllObjects];
                                            [cpuids removeAllObjects];
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.collectionView reloadData];
                                             });
                                             if (isFilteredList) {
                                                 [BEProgressHUD showMessage:@"没有找到该设备"];
                                             }else{
                                                 
                                                 [BEProgressHUD showMessage:@"暂无数据"];
                                             }
                                             
                                         }
                                         
                                     }
                                     
                                 } failure:nil];
    
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
                                             }
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
- (void)lonePressMoving:(UILongPressGestureRecognizer *)longPress {
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:[self.longPress locationInView:self.collectionView]];
            if (selectedIndexPath == nil) {
                break;
            }
//            [self focusMachine];
        }
            
            break;
            
        default:
            break;
    }
}
- (void)focusMachine:(NSIndexPath *)indexPath {

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"要关注设备吗？"
                                                                   message:@"关注之后可以在关注设备中查看"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self.collectionView reloadData];

                                                         }];
    UIAlertAction *focusAction = [UIAlertAction actionWithTitle:@"关注" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }];
    
    [alert addAction:cancelAction];
    [alert addAction:focusAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CollectionView

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *CellIdentifier;
    UICollectionViewCell *cell;
    switch (self.showViewType) {
        case SingleViewType:
        {
            CellIdentifier = @"SingleViewAirWaveCell";
            SingleViewAirWaveCell * cell = (SingleViewAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

            if (indexPath.row %4 == 0) {
//                [cell configureWithAirBagType:AirBagTypeThree message:nil];
//                cell.style = CellStyleOffLine;
                [cell configureWithCellStyle:CellStyleOffLine airBagType:AirBagTypeThree message:nil];

            } else if (indexPath.row %4 == 1) {
                [cell configureWithAirBagType:AirBagTypeEight message:@"运行中不可以切换气囊"];
                [cell.bodyView flashingTest];
                cell.style = CellStyleAlert;

            } else if (indexPath.row %4 == 2) {
                [cell configureWithAirBagType:AirBagTypeThree message:nil];
                cell.style = CellStyleUnauthorized;
            }
            else {
                [cell configureWithAirBagType:AirBagTypeEight message:nil];
                cell.style = CellStyleOnline;
            }
            [cell.patientButton addTarget:self action:@selector(showPatientInfoView:) forControlEvents:UIControlEventTouchUpInside];
            [cell.parameterView addTapBlock:^(id obj) {
                AirWaveSetParameterView *view = [AirWaveSetParameterView createViewFromNib];
                [view showInWindow];
            }];
            [cell.focusView addTapBlock:^(id obj) {
                [self focusMachine:indexPath];
            }];
            return cell;
            
        }
            break;
        case TwoViewsType:
        {
            CellIdentifier = @"TwoViewsAirWaveCell";
            TwoViewsAirWaveCell *cell = (TwoViewsAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
            if (indexPath.row %2 == 0){
                [cell configureWithAirBagType:AirBagTypeEight];
            }
            else {
                [cell configureWithAirBagType:AirBagTypeThree];
            }
            [cell.patientButton addTarget:self action:@selector(showPatientInfoView:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
            
        }
            break;
            
        case FourViewsType:
        {
            CellIdentifier = @"FourViewsAirWaveCell";
            FourViewsAirWaveCell *cell;
            if (indexPath.row %7 == 0){
                cell = (FourViewsAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
                [cell configureWithAirBagType:AirBagTypeEight];
            }
            else if (indexPath.row %7 == 1) {
                FourElectCell *cell = (FourElectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FourElectCell" forIndexPath:indexPath];
                [cell configureWithCellStyle:CellStyleOnline machineType:11111 dataDic:@{@"name":@"扇形波"} message:nil];

                
                return cell;
            }
            else if (indexPath.row %7 == 2) {
                FourElectCell *cell = (FourElectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FourElectCell" forIndexPath:indexPath];
                [cell configureWithCellStyle:CellStyleOnline machineType:11111 dataDic:@{@"name":@"rguangzi"} message:nil];

                return cell;
            }
            else if (indexPath.row %7 == 3) {
                FourElectCell *cell = (FourElectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FourElectCell" forIndexPath:indexPath];
                [cell configureWithCellStyle:CellStyleOnline machineType:11111 dataDic:@{@"name":@"bguangzi"} message:nil];
        
                return cell;
            }
            else if (indexPath.row %7 == 4) {
                FourElectCell *cell = (FourElectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FourElectCell" forIndexPath:indexPath];
                [cell configureWithCellStyle:CellStyleOnline machineType:11111 dataDic:@{@"name":@"gnhw"} message:nil];
 
                return cell;
            }
            else if (indexPath.row %7 == 5) {
                FourElectCell *cell = (FourElectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FourElectCell" forIndexPath:indexPath];
                [cell configureWithCellStyle:CellStyleOnline machineType:11111 dataDic:@{@"name":@"shihua"} message:nil];
        
                return cell;
            }
            else if (indexPath.row %7 == 6) {
                FourElectCell *cell = (FourElectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FourElectCell" forIndexPath:indexPath];
                [cell configureWithCellStyle:CellStyleOnline machineType:11111 dataDic:@{@"name":@"dafuya"} message:nil];
            
                return cell;
            }
            
            [cell.patientButton addTarget:self action:@selector(showPatientInfoView:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
             break;
        case NineViewsType:
        {
            CellIdentifier = @"NineViewsAirWaveCell";
            NineViewsAirWaveCell *cell = (NineViewsAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
            if (indexPath.row %2 == 0){
                [cell configureWithAirBagType:AirBagTypeEight];
            }
            else {
                [cell configureWithAirBagType:AirBagTypeThree];
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
    return 20;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
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
    FourElectCell *cell = (FourElectCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[FourElectCell class]]) {
        if([cell.deviceView isAnimating]) {
            [cell.deviceView stopAnimating];
        } else {
            [cell.deviceView startAnimating];
        }
    }
}

#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isShowAlertMessage) {
        return 3;
    } else {
        return 0;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /** 报警信息跳转到设备 */
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    return cell;
}
#pragma mark - Action

- (IBAction)showDeviceFilter:(id)sender {
    if ([_selectedDevices count] == 0) {
        _selectedDevices = @[@"空气波1",@"空气波8",@"空气波10",@"空气波12",@"红外设备7",@"红外设备11",@"光子7",
                             @"光子8",
                             @"光子9",
                             @"光子10",
                             @"光子11",
                             @"光子12",
                             @"光子13"];
    }
    weakself(self);
    DeviceFilterView *deviceFilterView = [[DeviceFilterView alloc]initWithLastContent:_selectedDevices commitBlock:^(NSArray *selections) {
        weakSelf.selectedDevices = selections;
        
    }];
    [deviceFilterView show];
}
- (void)showFocusMachines {
    [self performSegueWithIdentifier:@"showFocusMachines" sender:nil];
}
- (IBAction)showAlertView:(id)sender {
    AlertView *alerView = [AlertView createViewFromNib];
    [alerView showInWindowWithBackgoundTapDismissEnable:YES];

}

- (IBAction)changeShowViewType:(id)sender {
    self.showViewType = [sender tag];
    
    for (UIButton *button in self.typeSwitchView.subviews) {
        button.selected = (button.tag == [sender tag]);
    }
    [self.collectionView reloadData];
    /** 滑到第一格 */
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}
- (void)showPatientInfoView:(id)sender {
    NSDictionary *dataDic = @{
                              @"name":@"谢子琪",
                              @"gender":@"女"
                              };
    PatientInfoPopupView *view = [[PatientInfoPopupView alloc]initWithDic:dataDic];
    [view showInWindow];
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
#pragma mark - getter
- (NSArray *)selectedDevices {
    if (!_selectedDevices) {
        _selectedDevices = [NSArray array];
    }
    return _selectedDevices;
}
@end
