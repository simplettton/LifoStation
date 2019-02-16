//
//  DeviceFilterView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/29.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DeviceFilterView.h"
#import "UIView+Extension.h"
#import "FilterDeviceModel.h"
#import "DepartmentDeviceModel.h"
#import "DeviceFilterCell.h"

#define kTitleHeight 55
#define kContentHeight 250
#define kButtonWidth 65
#define kButtonHeight 28
// 屏幕的width
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕的height
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface DeviceFilterView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *allDataArray;

@property (nonatomic, strong) NSString *currentDepartment;
@property (nonatomic, strong) NSString *currentType;
@property (nonatomic, strong) NSMutableArray *selectedDepartments;
@property (nonatomic, strong) NSMutableArray *selectedTypes;
@property (nonatomic, strong) NSMutableArray *selectedDevices;

@property (nonatomic, strong) NSMutableArray *departments;
@property (nonatomic, strong) NSMutableArray *types;
@property (nonatomic, strong) NSMutableArray *devices;

// 布局控件
@property (nonatomic, strong) UIView *bgV;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITableView *departmentTableView;
@property (nonatomic, strong) UITableView *typeTableView;
@property (nonatomic, strong) UITableView *deviceTableView;
@end
@implementation DeviceFilterView
- (instancetype)initWithLastContent:(NSArray *)selectedArray commitBlock:(void(^)(NSArray *selections))commitBlock{
    if ([super init]) {
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        self.selectedDevices = [NSMutableArray arrayWithArray:selectedArray];
        [self setupView];
        [self getDeviceData];
        self.confirmSelect = commitBlock;
    }
    return self;
}
#pragma mark - create UI

- (void)getDeviceData {
    [self removeAllObjectFromDataArray];
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"devices.txt" ofType:nil]];
    if (!data) {
        return;
    }
    NSArray *allArray = [DepartmentDeviceModel arrayOfModelsFromData:data error:nil];
    self.allDataArray = [NSArray arrayWithArray:allArray];
    [self calculateDataArray];
}
//清空当前数据
- (void)removeAllObjectFromDataArray {
    [self.departments removeAllObjects];
    [self.types removeAllObjects];
    [self.devices removeAllObjects];
}

- (void)setupView {
    //背景
    self.bgV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _bgV.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelAction:)];
    [_bgV addGestureRecognizer:tapGestureRecognizer];
    [self addSubview:_bgV];
    
    //承载view 65距导航栏高度
    self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 65, kScreenWidth, kTitleHeight + kContentHeight)];
    _containerView.backgroundColor = [UIColor whiteColor];
    [_containerView.layer setBorderWidth:0.7];
    [_containerView.layer setBorderColor:UIColorFromHex(0xcdcdcd).CGColor];
    [self addSubview:_containerView];
    
    //titleview
    self.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kTitleHeight)];
    self.titleView.backgroundColor = UIColorFromHex(0xFBFBFB);
    [self.containerView addSubview:self.titleView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 150, kTitleHeight)];
    titleLabel.text = @"请选择监控设备";
    titleLabel.textColor = UIColorFromHex(0x6DA3E0);
    titleLabel.backgroundColor = UIColorFromHex(0xFBFBFB);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:17];
    [self.titleView addSubview:titleLabel];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    confirmButton.frame = CGRectMake(_titleView.width - kButtonWidth - 8, (_titleView.height - kButtonHeight )/2, kButtonWidth, kButtonHeight);
    confirmButton.backgroundColor = UIColorFromHex(0x6DA3E0);
    confirmButton.layer.masksToBounds = YES;
    confirmButton.layer.cornerRadius = 5.0f;
    [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:confirmButton];
    
    CGFloat titleBottom = self.titleView.frame.origin.y + self.titleView.frame.size.height;
    //第一个tableView
    self.departmentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, titleBottom , self.containerView.width/3, self.containerView.height - kTitleHeight) style:UITableViewStylePlain];
    _departmentTableView.dataSource = self;
    _departmentTableView.delegate = self;
    _departmentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.containerView addSubview:self.departmentTableView];
    //第二个tableview
    self.typeTableView = [[UITableView alloc]initWithFrame:CGRectMake(self.containerView.width/3, titleBottom, self.containerView.width/3, self.containerView.height - kTitleHeight) style:UITableViewStylePlain];
    _typeTableView.dataSource = self;
    _typeTableView.delegate = self;
    _typeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.containerView addSubview:self.typeTableView];
    //第三个tableview
    self.deviceTableView = [[UITableView alloc]initWithFrame:CGRectMake(self.containerView.width/3 *2, titleBottom, self.containerView.width/3, self.containerView.height - kTitleHeight) style:UITableViewStylePlain];
    _deviceTableView.dataSource = self;
    _deviceTableView.delegate = self;
    _deviceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.containerView addSubview:self.deviceTableView];
    
    //注册tableview cell
    [_departmentTableView registerNib:[UINib nibWithNibName:@"DeviceFilterCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    [_typeTableView registerNib:[UINib nibWithNibName:@"DeviceFilterCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    [_deviceTableView registerNib:[UINib nibWithNibName:@"DeviceFilterCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    
}
- (void)addViews {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.containerView];
    
}
- (void)show {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}
#pragma mark - TableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.departmentTableView]) {
        return self.departments.count;
    } else if ([tableView isEqual:self.typeTableView]) {
        return self.types.count;
    } else if ([tableView isEqual:self.deviceTableView]) {
        return self.devices.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"cell";
    DeviceFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ([tableView isEqual:self.departmentTableView]) {
        cell.centerLabel.text = self.departments[indexPath.row];
        if ([self.currentDepartment isEqualToString:self.departments[indexPath.row]]) {
            cell.backgroundColor = UIColorFromHex(0xF8F8F8);
            cell.rightArrow.hidden = NO;
        }else {
            cell.backgroundColor = [UIColor whiteColor];
            cell.rightArrow.hidden = YES;
        }
        //科室是否打钩
        NSString *departmentName = self.departments[indexPath.row];
        if ([self.selectedDepartments containsObject:departmentName]) {
            [cell.selectButton setImage:[UIImage imageNamed:@"selected_blue"] forState:UIControlStateNormal];
        } else {
            [cell.selectButton setImage:[UIImage imageNamed:@"unselected_gray"] forState:UIControlStateNormal];
        }
        [cell.selectButton addTarget:self action:@selector(selectDepartment:) forControlEvents:UIControlEventTouchUpInside];
        
    } else if ([tableView isEqual:self.typeTableView]) {
        cell.centerLabel.text = self.types[indexPath.row];
        if ([self.currentType isEqualToString:self.types[indexPath.row]]) {
            cell.backgroundColor = UIColorFromHex(0xF8F8F8);
            cell.rightArrow.hidden = NO;
        }else {
            cell.backgroundColor = [UIColor whiteColor];
            cell.rightArrow.hidden = YES;
        }
        //类型是否打钩
        NSString *typeName = self.types[indexPath.row];
        if ([self.selectedTypes containsObject:typeName]) {
            [cell.selectButton setImage:[UIImage imageNamed:@"selected_blue"] forState:UIControlStateNormal];
        } else {
            [cell.selectButton setImage:[UIImage imageNamed:@"unselected_gray"] forState:UIControlStateNormal];
        }

        [cell.selectButton addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        //机器是否打钩
        NSString *deviceName = self.devices[indexPath.row];
        cell.centerLabel.text = deviceName;
        if ([self.selectedDevices containsObject:deviceName]) {
            [cell.selectButton setImage:[UIImage imageNamed:@"selected_blue"] forState:UIControlStateNormal];
        } else {
            [cell.selectButton setImage:[UIImage imageNamed:@"unselected_gray"] forState:UIControlStateNormal];
        }
        [cell.selectButton addTarget:self action:@selector(selectDevice:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - DataArray
- (void)calculateDataArray {
    [self removeAllObjectFromDataArray];
    if (!self.currentDepartment) {
        self.currentDepartment = ((DepartmentDeviceModel *)self.allDataArray[0]).department;
    }
    if (!self.selectedTypes) {
        self.selectedTypes = [NSMutableArray array];
    }
    if (!self.selectedDepartments) {
        self.selectedDepartments = [NSMutableArray array];
    }
    for (DepartmentDeviceModel *model in self.allDataArray) {
        
        //----科室是否打钩----
        NSString *departmentName = model.department;
        //1.科室项
        [self.departments addObject:departmentName];
        BOOL isSelectedDepartment = YES;
        for (FilterDeviceModel *device in model.devices) {
            if (![self isArray:_selectedDevices contain:device.name]) {
                isSelectedDepartment = NO;
                break;
            }
        }
        if (isSelectedDepartment) {
            if (![_selectedDepartments containsObject:departmentName]) {
                [_selectedDepartments addObject:departmentName];
            }
        } else {
            if ([self.selectedDepartments containsObject:departmentName]) {
                [self.selectedDepartments removeObject:departmentName];
            }
        }
        //----科室是否打钩end----
        
        if ([self.currentDepartment isEqualToString:model.department]) {
            if (!self.currentType) {
                self.currentType = ((FilterDeviceModel *)model.devices[0]).type;
            }
            for (FilterDeviceModel *deviceModel in model.devices) {
                //2.机器种类项
                [self.types addObject:deviceModel.type];
                if ([self.currentType isEqualToString:deviceModel.type]) {
                    for (NSString *deviceName in deviceModel.name) {
                        //3.机器名称项
                        [self.devices addObject:deviceName];
                    }
                }
                
                //----类型是否打钩----

                BOOL isSelectedType = [self isArray:self.selectedDevices contain:deviceModel.name];
                if (isSelectedType) {
                    if (![_selectedTypes containsObject:deviceModel.type]) {
                        [_selectedTypes addObject:deviceModel.type];
                    }
                } else {
                    if ([_selectedTypes containsObject:deviceModel.type]) {
                        [_selectedTypes removeObject:deviceModel.type];
                    }
                }
                //----类型是否打钩end----
            }
        }
    }
    [self reloadTableViews];
    
}
- (void)selectDepartment:(id)sender {
    UIView *cellContainer = [sender superview];
    DeviceFilterCell *cell = (DeviceFilterCell* )[cellContainer superview];
    NSIndexPath *indexPath = [_departmentTableView indexPathForCell:cell];
    
    NSString* departmentName = _departments[indexPath.row];

    DepartmentDeviceModel *model = self.allDataArray[indexPath.row];
    //科室已经被选中 清除包含的所有机器
    if ([_selectedDepartments containsObject:departmentName]){
        for (FilterDeviceModel *deviceModel in model.devices) {
            for (NSString *deviceName in deviceModel.name) {
                [_selectedDevices removeObject:deviceName];
            }
        }
    }
    else {
        for (FilterDeviceModel *deviceModel in model.devices) {
            for (NSString *deviceName in deviceModel.name) {
                if (![_selectedDevices containsObject:deviceName]) {
                    [_selectedDevices addObject:deviceName];
                }
            }
        }
    }

    self.currentDepartment = departmentName;
    [self calculateDataArray];
}
- (void)selectType:(id)sender {
    UIView *cellContainer = [sender superview];
    DeviceFilterCell *cell = (DeviceFilterCell *)[cellContainer superview];
    NSIndexPath *indexPath = [_typeTableView indexPathForCell:cell];


    NSString *typeName = _types[indexPath.row];
    for (DepartmentDeviceModel *model in self.allDataArray) {
        if ([_currentDepartment isEqualToString:model.department]) {
            FilterDeviceModel *deviceModel = model.devices[indexPath.row];
            if ([typeName isEqualToString:deviceModel.type]) {
                //类型已被选中 清除选中类型和对应的机器们
                if ([_selectedTypes containsObject:typeName]) {
                    for (NSString *deviceName in deviceModel.name) {
                        [_selectedDevices removeObject:deviceName];
                    }
                    [_selectedTypes removeObject:typeName];
                }
                else {
                    //类型未被选中 加入选中类型列表中以及对应的机器们
                    for (NSString *deviceName in deviceModel.name) {
                        if (![_selectedDevices containsObject:deviceName]) {
                            [_selectedDevices addObject:deviceName];
                        }
                    }
                    if (![_selectedTypes containsObject:typeName]) {
                        [_selectedTypes addObject:typeName];
                    }
                }
            }
            
            break;
        }
    }

    self.currentType = typeName;
    //1.选择类型则不清空选择的类型重新计算
    [self calculateDataArray];
}
- (void)selectDevice:(id)sender {
    UIView *cellContainer = [sender superview];
    DeviceFilterCell *cell = (DeviceFilterCell *)[cellContainer superview];
    NSIndexPath *indexPath = [_deviceTableView indexPathForCell:cell];

    //与选种设备项同一效果
    [self.selectedTypes removeAllObjects];   //2.选择设备则清空选择的类型重新计算
    NSString *deviceName = self.devices[indexPath.row];
    if ([self.selectedDevices containsObject:deviceName]) {
        [self.selectedDevices removeObject:deviceName];
    } else {
        [self.selectedDevices addObject:deviceName];
    }
    [self calculateDataArray];
}
- (BOOL)isArray:(NSArray *)array1 contain:(NSArray *)array2 {
    NSSet *set1 = [NSSet setWithArray:array1];
    NSSet *set2 = [NSSet setWithArray:array2];
    
    if ([set2 isSubsetOfSet:set1]) {
        return YES;
    }
    else {
        return NO;
    }
}
#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.departmentTableView]) {
        if (![self.currentDepartment isEqualToString:self.departments[indexPath.row]]) {
            self.currentDepartment = self.departments[indexPath.row];
            self.currentType = nil;
            [self.selectedTypes removeAllObjects];
        }
    } else if ([tableView isEqual:self.typeTableView]) {
        self.currentType = self.types[indexPath.row];
    } else {
        [self.selectedTypes removeAllObjects];
        NSString *deviceName = self.devices[indexPath.row];
        if ([self.selectedDevices containsObject:deviceName]) {
            [self.selectedDevices removeObject:deviceName];
        } else {
            [self.selectedDevices addObject:deviceName];
        }
    }
    [self calculateDataArray];
    
}
- (void)reloadTableViews {
    [self.departmentTableView reloadData];
    [self.typeTableView reloadData];
    [self.deviceTableView reloadData];
}
#pragma mark - Action
 - (void)showWithAnimation {
}

- (void)cancelAction:(id)sender {
    [self removeFromSuperview];
}
- (void)sureAction:(id)sender {
    if (self.confirmSelect) {
        self.confirmSelect(self.selectedDevices);
    }
    [self removeFromSuperview];
}
#pragma mark - Getter
- (NSMutableArray *)departments {
    if(!_departments) {
        _departments = [NSMutableArray array];
    }
    return _departments;
}
- (NSMutableArray *)types {
    if (!_types) {
        _types = [NSMutableArray array];
    }
    return _types;
}
- (NSMutableArray *)devices {
    if (!_devices) {
        _devices = [NSMutableArray array];
    }
    return _devices;
}
- (NSMutableArray *)selectedDepartments {
    if (!_selectedDepartments) {
        _selectedDepartments = [NSMutableArray array];
    }
    return _selectedDepartments;
}
- (NSMutableArray *)selectedDevices {
    if (!_selectedDevices) {
        _selectedDevices = [NSMutableArray array];
    }
    return _selectedDevices;
}
- (NSMutableArray *)selectedTypes {
    if (!_selectedTypes) {
        _selectedTypes = [NSMutableArray array];
    }
    return _selectedTypes;
}
@end
