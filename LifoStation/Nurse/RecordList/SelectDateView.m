//
//  SelectDateView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/2/16.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "SelectDateView.h"
#import "UIView+TYAlertView.h"
#import "UIView+Tap.h"
@interface SelectDateView()
@property (weak, nonatomic) IBOutlet UIView *changeModeView;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;


@property (nonatomic, assign) BOOL isMonthly;
//按日选择
@property (weak, nonatomic) IBOutlet UIView *dailyView;
@property (weak, nonatomic) IBOutlet UIView *beginDayView;
@property (weak, nonatomic) IBOutlet UIView *endDayView;
@property (weak, nonatomic) IBOutlet UILabel *beginDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDayLabel;
@property (nonatomic, assign) BOOL isBeginDay;

//按月选择
@property (weak, nonatomic) IBOutlet UIView *monthlyView;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;


@end
@implementation SelectDateView
#pragma mark - Init
- (instancetype)initWithDic:(NSDictionary *)dic commitBlock:(void(^)(NSDictionary *selection))commitBlock {
    SelectDateView *view = [SelectDateView createViewFromNib];
    return view;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self initAll];
}
- (void)initAll {
    _isMonthly = YES;
    weakself(self);
    [self.changeModeView addTapBlock:^(id obj) {
        weakSelf.isMonthly = !weakSelf.isMonthly;
        if (weakSelf.isMonthly) {
            weakSelf.modeLabel.text = @"按月选择";
            weakSelf.monthlyView.hidden = NO;
            weakSelf.dailyView.hidden = YES;
        } else {
            weakSelf.modeLabel.text = @"按日选择";
            weakSelf.monthlyView.hidden = YES;
            weakSelf.dailyView.hidden = NO;
        }

    }];
    //设置中文
    self.datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
}
#pragma mark - Action
- (void)dateChanged:(UIDatePicker *)pickerView {
    NSDateFormatter *df = [NSDateFormatter new];
    if (_isMonthly) {
        df.dateFormat = @"yyyy-MM";
        
    } else {
        df.dateFormat = @"yyyy-MM-dd";
    }

    NSLog(@"===%@", pickerView.date);
}

- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (IBAction)finishAction:(id)sender {
    [self hideView];
}


@end
