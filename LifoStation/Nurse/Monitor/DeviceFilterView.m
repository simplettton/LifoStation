//
//  DeviceFilterView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/29.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "DeviceFilterView.h"
#import "UIView+Extension.h"

#define kTitleHeight 40
#define kContentHeight 270
#define kButtonWidth 65
#define kButtonHeight 28
// 屏幕的width
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕的height
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface DeviceFilterView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *selectedDepartments;
@property (nonatomic, strong) NSMutableArray *selectedTypes;
@property (nonatomic, strong) NSMutableArray *selectedDevices;
// 布局控件
@property (nonatomic, strong) UIView *bgV;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITableView *departmentTableView;
@property (nonatomic, strong) UITableView *typeTableView;
@property (nonatomic, strong) UITableView *deviceTableView;
@end
@implementation DeviceFilterView
- (instancetype)initWithLastContent:(NSDictionary *)lastContent commitBlock:(void(^)(NSDictionary *selections))commitBlock{
    if ([super init]) {
        self.frame = CGRectMake(0, 57, kScreenWidth, kTitleHeight + kContentHeight);
        [self setupView];
    }
    return self;
}
#pragma mark - create UI
//- (instancetype)initWithFrame:(CGRect)frame {
//
//}
- (void)setupView {
    //背景
    self.bgV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _bgV.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelAction:)];
    [_bgV addGestureRecognizer:tapGestureRecognizer];
    [self addSubview:_bgV];
    
    //承载view
    self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 57, kScreenWidth, kTitleHeight + kContentHeight)];
    _containerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_containerView];
    
    //titleview
    self.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kTitleHeight)];
    self.titleView.backgroundColor = UIColorFromHex(0xFBFBFB);
    [self.containerView addSubview:self.titleView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 150, kTitleHeight)];
    titleLabel.text = @"请选择监控设备";
    titleLabel.textColor = UIColorFromHex(0x6DA3E0);
    titleLabel.backgroundColor = [UIColor clearColor];
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
    [self.titleView addSubview:confirmButton];
//    
//    self.departmentTableView = [UITableView alloc]initWithFrame:CGRectMake(0, 0, self.containerView.width/3, self.containerView.height - kTitleHeight) style:UITableViewStylePlain];
//    
//    
    
}
- (void)addViews {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.containerView];
    
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
@end
