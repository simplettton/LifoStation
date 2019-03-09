//
//  AddPatientViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/25.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddPatientViewController.h"
#import "UIView+Tap.h"
#import <BRPickerView.h>
#import "NSDate+BRAdd.h"
@interface AddPatientViewController ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *editViews;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *requiredTextFields;
@property (weak, nonatomic) IBOutlet UIView *medicalNumView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControll;
@property (weak, nonatomic) IBOutlet UITextField *medicalRecordNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *bedNumTextField;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextFiled;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;

//@property (weak, nonatomic) IBOutlet BETextField *birthdayTF;
@property (weak, nonatomic) IBOutlet UILabel *treatDateLabel;
@property (weak, nonatomic) IBOutlet UIView *birthDayView;
@property (weak, nonatomic) IBOutlet UIView *treatDayView;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *nameLabels;

//条形码扫描
//@property (strong,nonatomic) QRCodeReaderViewController *reader;
@end

@implementation AddPatientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
}
- (void)initAll {
    for (UIView *view in self.editViews) {
        view.layer.borderWidth = 0.5f;
        view.layer.cornerRadius = 5.0f;
        view.layer.borderColor = UIColorFromHex(0xbbbbbb).CGColor;
    }
    [self initBirthdayPicker];

}
- (void)initBirthdayPicker {
    __weak typeof(self) weakSelf = self;
    [self.birthDayView addTapBlock:^(id obj) {
        [BRDatePickerView showDatePickerWithTitle:@"出生日期"
                                         dateType:BRDatePickerModeDate
                                  defaultSelValue:weakSelf.birthdayLabel.text
                                          minDate:nil
                                          maxDate:[NSDate date]
                                     isAutoSelect:NO
                                       themeColor:nil
                                      resultBlock:^(NSString *selectValue) {
                                          weakSelf.birthdayLabel.text = selectValue;
                                          NSString *time = [selectValue stringByAppendingString:@" 00:00:00"];
                                          NSString *timeStamp = [self timeStampFromTimeString:time dataFormat:@"yyyy-MM-dd HH:mm:ss"];
                                          
                                          NSLog(@"------send to server ：生日时间戳：%@",timeStamp);
                                      }
                                      cancelBlock:nil];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
//日期字符转为时间戳
-(NSString *)timeStampFromTimeString:(NSString *)timeString dataFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    //    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateFormat];
    
    //日期转时间戳
    NSDate *date = [formatter dateFromString:timeString];
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    NSString* timeStamp = [NSString stringWithFormat:@"%ld",timeSp];
    return timeStamp;
}

@end
