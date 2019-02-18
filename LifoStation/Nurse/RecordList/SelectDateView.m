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

#import "PGDatePickManager.h"

@interface SelectDateView()<PGDatePickerDelegate>

@property (weak, nonatomic) IBOutlet UIView *changeModeView;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *datePickerBackground;

@property (nonatomic, assign) BOOL isMonthly;
//按日选择
@property (weak, nonatomic) IBOutlet UIView *dailyView;
@property (weak, nonatomic) IBOutlet UIView *beginDayView;
@property (weak, nonatomic) IBOutlet UIView *endDayView;
@property (weak, nonatomic) IBOutlet UILabel *beginDayLabel;
@property (weak, nonatomic) IBOutlet UIView *beginDayUnderLine;
@property (weak, nonatomic) IBOutlet UILabel *endDayLabel;
@property (weak, nonatomic) IBOutlet UIView *endDayUnderLine;
@property (nonatomic, assign) BOOL isBeginDay;
@property (nonatomic, strong) PGDatePicker *dayDatePicker;

//按月选择
@property (weak, nonatomic) IBOutlet UIView *monthlyView;
@property (weak, nonatomic) IBOutlet UIView *monthView;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIView *monthUnderLine;

@property (nonatomic, strong) PGDatePicker *monthDatePicker;



@end
@implementation SelectDateView
#pragma mark - Init
- (instancetype)initWithDic:(NSDictionary *)dic commitBlock:(void(^)(NSDictionary *selection))commitBlock {
    SelectDateView *view = [SelectDateView createViewFromNib];
    return view;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.dayDatePicker = [[PGDatePicker alloc]initWithFrame:self.datePickerBackground.frame];
    self.dayDatePicker.delegate = self;
    self.dayDatePicker.datePickerMode = PGDatePickerModeDate;
    self.dayDatePicker.maximumDate = [NSDate date];
    self.dayDatePicker.autoSelected = YES;
    [self.contentView addSubview:self.dayDatePicker];
    self.dayDatePicker.hidden = YES;
    

    self.monthDatePicker = [[PGDatePicker alloc]initWithFrame:self.datePickerBackground.frame];
    self.monthDatePicker.delegate = self;
    self.monthDatePicker.datePickerMode = PGDatePickerModeYearAndMonth;
    self.monthDatePicker.maximumDate = [NSDate date];
    self.monthDatePicker.autoSelected = YES;
    [self.contentView addSubview:self.monthDatePicker];
    
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self initAll];
}
- (void)initAll {
    //设置时间选择器
    
    _isMonthly = YES;
    _isBeginDay = YES;
    weakself(self);
    [self.changeModeView addTapBlock:^(id obj) {
        weakSelf.isMonthly = !weakSelf.isMonthly;
        if (weakSelf.isMonthly) {
            weakSelf.modeLabel.text = @"按月选择";
            weakSelf.monthlyView.hidden = NO;
            weakSelf.dailyView.hidden = YES;
            weakSelf.dayDatePicker.hidden = YES;
            weakSelf.monthDatePicker.hidden = NO;

        } else {
            weakSelf.modeLabel.text = @"按日选择";
            weakSelf.monthlyView.hidden = YES;
            weakSelf.dailyView.hidden = NO;
            weakSelf.dayDatePicker.hidden = NO;
            weakSelf.monthDatePicker.hidden = YES;
        }
    }];
    
    [self.beginDayView addTapBlock:^(id obj) {
        [weakSelf tapDayView:weakSelf.beginDayView];
    }];
    [self.endDayView addTapBlock:^(id obj) {
        [weakSelf tapDayView:weakSelf.endDayView];
    }];
    
    [self.monthView addTapBlock:^(id obj) {
        [weakSelf tapDayView:weakSelf.monthView];
    }];
    
}
#pragma mark - Action

- (IBAction)deleteDate:(id)sender {
    if (_isMonthly) {
        _monthDatePicker.hidden = YES;
        _monthLabel.text = @"选择月份";
        _monthLabel.textColor = UIColorFromHex(0xcdcdcd);
        _monthUnderLine.backgroundColor = UIColorFromHex(0xcdcdcd);
    } else {
        _dayDatePicker.hidden = YES;
        _beginDayLabel.text = @"开始时间";
        _endDayLabel.text = @"结束时间";
        _beginDayLabel.textColor = UIColorFromHex(0xcdcdcd);
        _beginDayUnderLine.backgroundColor = UIColorFromHex(0xcdcdcd);
        _endDayLabel.textColor = UIColorFromHex(0xcdcdcd);
        _endDayUnderLine.backgroundColor = UIColorFromHex(0xcdcdcd);
    }

}
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
/** 点击三个日期数字 */
- (void)tapDayView:(UIView*)view {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    [dateFormatter setTimeZone: [NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
    if ([view isEqual:self.beginDayView]) {
        _isBeginDay = YES;
        _beginDayLabel.textColor = UIColorFromHex(0x007AFF);
        _beginDayUnderLine.backgroundColor = UIColorFromHex(0x007AFF);
        _endDayLabel.textColor = UIColorFromHex(0xcdcdcd);
        _endDayUnderLine.backgroundColor = UIColorFromHex(0xcdcdcd);
        
        if ([_beginDayLabel.text isEqualToString:@"开始时间"]) {
            [_dayDatePicker setDate:[NSDate date]];
        } else {
            NSString *beginday = _beginDayLabel.text;
            NSDate *date = [dateFormatter dateFromString: beginday];
            NSLog(@"beginday = %@,date = %@",beginday,date);
            [_dayDatePicker setDate:date animated:true];
        }

    } else if ([view isEqual:self.endDayView]) {
        _isBeginDay = NO;
        _beginDayLabel.textColor = UIColorFromHex(0xcdcdcd);
        _beginDayUnderLine.backgroundColor = UIColorFromHex(0xcdcdcd);
        _endDayLabel.textColor = UIColorFromHex(0x007AFF);
        _endDayUnderLine.backgroundColor = UIColorFromHex(0x007AFF);
        
        if([_endDayLabel.text isEqualToString:@"结束时间"]){
            [_dayDatePicker setDate:[NSDate date]];
        } else {
            [_dayDatePicker setDate:[dateFormatter dateFromString: _endDayLabel.text]animated:true];
        }
        
    } else {
        if ([_monthLabel.text isEqualToString:@"选择月份"]) {
            [_monthDatePicker setDate:[NSDate date]];
            _monthLabel.textColor = UIColorFromHex(0x007AFF);
            _monthUnderLine.backgroundColor = UIColorFromHex(0x007AFF);
        }
    }
    
    if (_isMonthly) {
        _monthDatePicker.hidden = NO;
    } else {
        _dayDatePicker.hidden = NO;
    }
    
}
#pragma mark - PGDatePickerDelegate

- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents{

    NSDateFormatter *df = [NSDateFormatter new];
    if (_isMonthly) {
        df.dateFormat = @"yyyy-MM";

    } else {
        df.dateFormat = @"yyyy-MM-dd";
    }

    
    if ([datePicker isEqual:_dayDatePicker]) {
        if (_isBeginDay) {
            _beginDayLabel.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)dateComponents.year,(long)dateComponents.month,(long)dateComponents.day];
        } else {
            _endDayLabel.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",(long)dateComponents.year,(long)dateComponents.month,(long)dateComponents.day];
        }
    } else {
        _monthLabel.text = [NSString stringWithFormat:@"%04ld-%02ld",(long)dateComponents.year,(long)dateComponents.month];
    }

}
@end
