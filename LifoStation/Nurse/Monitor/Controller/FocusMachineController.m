//
//  FocusMachineController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/25.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "FocusMachineController.h"
#import "AirWaveSetParameterView.h"
#import "PatientInfoPopupView.h"
#import "AlertView.h"
#import "SingleViewAirWaveCell.h"
#import "UIView+Tap.h"
@interface FocusMachineController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *isShowAlertViewButton;
@property (nonatomic, assign) BOOL isShowAlertMessage;
@property (nonatomic, assign) BOOL isEditing;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *unfocusButton;

@end

@implementation FocusMachineController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
    // Do any additional setup after loading the view.
}

- (void)initAll {
    /** 注册新定义cell */
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SingleViewAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"SingleViewAirWaveCell"];
    
    /** 默认展示alertview */
    _isShowAlertMessage = YES;
    self.alertView.layer.borderWidth = 0.5f;
    self.alertView.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
    
    /** 编辑 */
    self.isEditing = NO;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0xf8f8f8);
    self.navigationController.navigationBar.tintColor = UIColorFromHex(0x272727);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0x272727)}];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x3A87C7);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
#pragma mark - CollectionView
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SingleViewAirWaveCell";
    SingleViewAirWaveCell * cell = (SingleViewAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.row %4 == 0) {
        [cell configureWithAirBagType:AirBagTypeEight message:nil];
        cell.style = CellStyleOffLine;
        
    } else if (indexPath.row %4 == 1) {
        [cell configureWithAirBagType:AirBagTypeThree message:@"运行中不可以切换气囊"];
        cell.style = CellStyleAlert;
        
    } else if (indexPath.row %4 == 2) {
        [cell configureWithAirBagType:AirBagTypeThree message:nil];
        cell.style = CellStyleUnauthorized;
    }
    else {
        [cell configureWithAirBagType:AirBagTypeThree message:nil];
        cell.style = CellStyleOnline;
    }
    [cell.patientButton addTarget:self action:@selector(showPatientInfoView:) forControlEvents:UIControlEventTouchUpInside];
    [cell.parameterView addTapBlock:^(id obj) {
        AirWaveSetParameterView *view = [AirWaveSetParameterView createViewFromNib];
        [view showInWindow];
    }];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
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

- (IBAction)rightBarButtonItemClicked:(id)sender {
    self.isEditing = !self.isEditing;

    if (self.isEditing) {
        self.unfocusButton.title = @"完成";
    } else {
        self.unfocusButton.title = @"取消关注";
    }
    [self.collectionView reloadData];
    
}
- (IBAction)showAlertView:(id)sender {
    AlertView *alerView = [AlertView createViewFromNib];
    [alerView showInWindow];
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
- (void)unfocusMachine {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"取消关注"
                                                                   message:@"确定取消关注22床空气波1号吗"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self.collectionView reloadData];
                                                             
                                                         }];
    UIAlertAction *focusAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:focusAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
