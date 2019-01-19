//
//  MonitorViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MonitorViewController.h"

#import "SingleViewAirWaveCell.h"
#import "TwoViewsAirWaveCell.h"
#import "FourViewsAirWaveCell.h"
#import "NineViewsAirWaveCell.h"

#import "PatientInfoPopupView.h"
#import "AirWaveSetParameterView.h"

#import "UIView+TYAlertView.h"
#import "UIView+Tap.h"
#import "AlertView.h"
@interface MonitorViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewHeight;

@property (nonatomic, assign) NSInteger showViewType;
@property (weak, nonatomic) IBOutlet UIStackView *typeSwitchView;

@property (weak, nonatomic) IBOutlet UIButton *isShowAlertViewButton;
@property (nonatomic, assign) BOOL isShowAlertMessage;
@end

@implementation MonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
}
- (void)initAll {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    [button setTitle:@" 重点关注" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:UIColorFromHex(0x6EA4E2) forState:UIControlStateNormal];
    
//    button.frame=CGRectMake(0,0,100,100);//#1#硬编码设置UIButton位置、大小
 UIBarButtonItem* barButtonItem=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem=barButtonItem;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    /** 注册新定义cell */
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([SingleViewAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"SingleViewAirWaveCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([TwoViewsAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"TwoViewsAirWaveCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FourViewsAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"FourViewsAirWaveCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([NineViewsAirWaveCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"NineViewsAirWaveCell"];
    
    self.alertView.layer.borderWidth = 0.5f;
    self.alertView.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
    
    self.showViewType = SingleViewType;
    [self changeShowViewType:[self.typeSwitchView viewWithTag:SingleViewType]];
    
    /** 默认展示alertview */
    _isShowAlertMessage = YES;
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
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *CellIdentifier;
    UICollectionViewCell *cell;
    switch (self.showViewType) {
        case SingleViewType:
        {
            CellIdentifier = @"SingleViewAirWaveCell";
            SingleViewAirWaveCell * cell = (SingleViewAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

            if (indexPath.row %3 == 0) {
                [cell configureWithCellStyle:CellStyleOffLine AirBagType:AirBagTypeEight];
            }
            else if (indexPath.row %3 == 1) {
                [cell configureWithCellStyle:CellStyleAlert AirBagType:AirBagTypeThree];
            }
            else {
                [cell configureWithCellStyle:CellStyleOnline AirBagType:AirBagTypeThree];
            }
            [cell.patientButton addTarget:self action:@selector(showPatientInfoView:) forControlEvents:UIControlEventTouchUpInside];
            [cell.parameterView addTapBlock:^(id obj) {
                AirWaveSetParameterView *view = [AirWaveSetParameterView createViewFromNib];
                [view showInWindow];
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
            FourViewsAirWaveCell *cell = (FourViewsAirWaveCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
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

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    /** 一宫格 */
    switch (self.showViewType) {
        case SingleViewType:
            return CGSizeMake(728, 688);
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
    return CGSizeMake(728, 688);
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

- (IBAction)showAlertView:(id)sender {
    AlertView *alerView = [AlertView createViewFromNib];
    [alerView showInWindow];
}

- (IBAction)changeShowViewType:(id)sender {
    self.showViewType = [sender tag];
    
    for (UIButton *button in self.typeSwitchView.subviews) {
        button.selected = (button.tag == [sender tag]);
    }
    [self.collectionView reloadData];
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

@end
