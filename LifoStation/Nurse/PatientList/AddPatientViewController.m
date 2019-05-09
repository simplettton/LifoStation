//
//  AddPatientViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/25.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddPatientViewController.h"
#import "QRCodeReaderViewController.h"
#import "PatientListViewController.h"
#import "UIView+Tap.h"
#import <BRPickerView.h>
#import "NSDate+BRAdd.h"
@interface AddPatientViewController ()<QRCodeReaderDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *editViews;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *requiredTextFields;
@property (weak, nonatomic) IBOutlet UIView *medicalNumView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UITextField *medicalRecordNumTextField;

@property (weak, nonatomic) IBOutlet UITextField *treatAddressTextField;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextFiled;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (nonatomic, assign) BOOL hasTapedBirthday;

@property (weak, nonatomic) IBOutlet UILabel *treatDateLabel;
@property (weak, nonatomic) IBOutlet UIView *birthDayView;
@property (weak, nonatomic) IBOutlet UIView *treatDayView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *nameLabels;


//条形码扫描
@property (weak, nonatomic) IBOutlet UIBarButtonItem *scanButton;
@property (strong,nonatomic) QRCodeReaderViewController *reader;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *limitTextFields;

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
    //当前时间戳
    NSString *timestamp = [NSString stringWithFormat:@"%ld", time(NULL)];
//    self.birthdayLabel.text = [self stringFromTimeIntervalString:timestamp dateFormat:@"yyyy-MM-dd"];
    NSArray *genderArray = @[@"男",@"女",@"其他"];
    if (self.patient == nil) {
        self.title = @"增加病历";
        self.treatDateLabel.text = [self stringFromTimeIntervalString:timestamp dateFormat:@"yyyy-MM-dd"];

    } else {
        self.title = @"编辑病历";
        self.medicalNumView.layer.borderWidth = 0;
        self.navigationItem.rightBarButtonItem = nil;
        self.medicalRecordNumTextField.text = self.patient.medicalNumber;
        self.medicalRecordNumTextField.enabled = NO;
        self.nameTextField.text = self.patient.personName;
        self.treatAddressTextField.text = self.patient.treatAddress;
        self.phoneTextFiled.text = self.patient.phoneNumber;
        /** birthday服务器可为@""空字符串 */
        if (self.patient.birthday.length > 0) {
            self.birthdayLabel.text = [self stringFromTimeIntervalString:self.patient.birthday dateFormat:@"yyyy-MM-dd"];
        }

        self.treatDateLabel.text = [self stringFromTimeIntervalString:self.patient.registeredDate dateFormat:@"yyyy-MM-dd"];
    }
    
    
    if (self.patient.gender) {
        NSInteger selectedIndex = [genderArray indexOfObject:self.patient.gender];
        [self.segmentedControl setSelectedSegmentIndex:selectedIndex];
    } else {
        [self.segmentedControl setSelectedSegmentIndex:-1];
    }

    [self initBirthdayPicker];
    
    for (UITextField *textField in self.limitTextFields) {
        textField.delegate = self;
    }
}
#pragma mark - TextFiledDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSArray *lengthLimitArray = @[@30,@10,@10,@11];
    NSNumber *limit = [lengthLimitArray objectAtIndex:[self.limitTextFields indexOfObject:textField]];
    NSUInteger proposedNewLength = textField.text.length - range.length + string.length;
    if (proposedNewLength > [limit integerValue]) {
        return NO;
    }
    return YES;
}
- (void)initBirthdayPicker {
    __weak typeof(self) weakSelf = self;
    /** 1900-01-01 00：00：00 */
    NSString *minDateString = @"-2209017600";
    [self.birthDayView addTapBlock:^(id obj) {
        [BRDatePickerView showDatePickerWithTitle:@"出生日期"
                                         dateType:BRDatePickerModeDate
                                  defaultSelValue:weakSelf.birthdayLabel.text
                                          minDate:[NSDate dateWithTimeIntervalSince1970:[minDateString doubleValue]]
                                          maxDate:[NSDate date]
                                     isAutoSelect:NO
                                       themeColor:nil
                                      resultBlock:^(NSString *selectValue) {
                                          weakSelf.hasTapedBirthday = YES;
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
- (IBAction)scanAction:(id)sender {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"相机启用权限未开启"
                                                                       message:[NSString stringWithFormat:@"请在iPhone的“设置”-“隐私”-“相机”功能中，找到“%@”打开相机访问权限",[[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleDisplayName"]]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                  [[UIApplication sharedApplication] openURL:url];
                                                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"]];
                                                                  
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
        return;
        
    }
    NSArray *types = @[
                       AVMetadataObjectTypeQRCode,
                       AVMetadataObjectTypeEAN13Code,
                       AVMetadataObjectTypeEAN8Code,
                       AVMetadataObjectTypeUPCECode,
                       AVMetadataObjectTypeCode39Code,
                       AVMetadataObjectTypeCode39Mod43Code,
                       AVMetadataObjectTypeCode93Code,
                       AVMetadataObjectTypeCode128Code,
                       AVMetadataObjectTypePDF417Code];
    
    _reader = [QRCodeReaderViewController readerWithMetadataObjectTypes:types];
    _reader.delegate = self;
    
    [self presentViewController:_reader animated:YES completion:NULL];
}
#pragma mark - QRCodeReader Delegate Methods
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
    [self dismissViewControllerAnimated:YES completion:^{
        
    //病历号限制了30位
    if(result.length <= 30){
        self.medicalRecordNumTextField.text = result;
    }else{
        [SVProgressHUD showErrorWithStatus:@"请扫描有效的病历号"];
        self.medicalRecordNumTextField.text = @"";
    }
        
        NSLog(@"QRretult == %@", result);
    }];
}
- (void)readerDidCancel:(QRCodeReaderViewController *)reader {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)save:(id)sender {
    NSArray *genderArray = @[@"男",@"女",@"其他"];
    BOOL hasBlankTextFiled = NO;
    if([self.medicalRecordNumTextField.text length] == 0 || [self.nameTextField.text length] == 0) {
        [BEProgressHUD showMessage:@"请填写完整信息"];
        hasBlankTextFiled = YES;
    } else if (_segmentedControl.selectedSegmentIndex == -1) {
        [BEProgressHUD showMessage:@"请选择性别"];
        hasBlankTextFiled = YES;
    }
    if (!hasBlankTextFiled) {
        NSString *api;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:20];
        NSString *gender = genderArray[self.segmentedControl.selectedSegmentIndex];
        NSString *birthdayString = [self timeStampFromTimeString:self.birthdayLabel.text dataFormat:@"yyyy-MM-dd"];

        [params setObject:self.nameTextField.text forKey:@"PersonName"];
        [params setObject:gender forKey:@"Gender"];
        
        if (self.hasTapedBirthday) {
            [params setObject:birthdayString forKey:@"Birthday"];
        }
        if ([self.treatAddressTextField.text length] > 0) {
            [params setObject:self.treatAddressTextField.text forKey:@"TreatAddress"];
        }
        if ([self.phoneTextFiled.text length] > 0) {
            [params setObject:self.phoneTextFiled.text forKey:@"Phone"];
        }
        
        if (self.patient == nil) {
            api = @"api/PatientController/Add";
            [params setObject:self.medicalRecordNumTextField.text forKey:@"MedicalNumber"];
        } else {
            api = @"api/PatientController/Update";
            [params setObject:self.patient.uuid forKey:@"PatientId"];
            if ([self.treatAddressTextField.text length] > 0) {
                self.patient.treatAddress = self.treatAddressTextField.text;
            }
            if ([self.phoneTextFiled.text length] > 0) {
                self.patient.phoneNumber = self.phoneTextFiled.text;
            }
            self.patient.age = [self getAgeFromBirthday:self.birthdayLabel.text];
            self.patient.birthday = birthdayString;
            self.patient.personName = self.nameTextField.text;
            self.patient.gender = gender;
        }
        
        [[NetWorkTool sharedNetWorkTool]POST:RequestUrl(api)
                                      params:params
                                    hasToken:YES
                                     success:^(HttpResponse *responseObject) {
                                         if ([responseObject.result intValue] == 1) {
                                             [BEProgressHUD showMessage:@"保存成功"];
                                             PatientListViewController *patientListViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
                                             if (self.patient) {
                                                 patientListViewController.patient = self.patient;
                                                 [self.navigationController popToViewController:patientListViewController animated:YES];
                                                 
                                             } else {
                                                 patientListViewController.hasNewPatient = YES;
                                                 [self.navigationController popViewControllerAnimated:YES];
                                             }
                                         }
                                     }
                                     failure:nil];
        
        
    }

}

#pragma mark - Private Method
- (NSString *)getAgeFromBirthday:(NSString *)dateStr {
    NSString *year = [dateStr substringWithRange:NSMakeRange(0, 4)];
    NSString *month = [dateStr substringWithRange:NSMakeRange(5, 2)];
    NSString *day = [dateStr substringWithRange:NSMakeRange(dateStr.length-2, 2)];
    NSLog(@"出生于%@年%@月%@日", year, month, day);
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
    NSDateComponents *compomemts = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay fromDate:nowDate];
    NSInteger nowYear = compomemts.year;
    NSInteger nowMonth = compomemts.month;
    NSInteger nowDay = compomemts.day;
    NSLog(@"今天是%ld年%ld月%ld日", nowYear, nowMonth, nowDay);
    
    // 计算年龄
    NSInteger userAge = nowYear - year.intValue - 1;
    if ((nowMonth > month.intValue) || (nowMonth == month.intValue && nowDay >= day.intValue)) {
        userAge++;
    }
    NSLog(@"用户年龄是%ld",userAge);
    return [NSString stringWithFormat:@"%ld",userAge];
}
//时间戳字符串转化为日期或时间
- (NSString *)stringFromTimeIntervalString:(NSString *)timeString dateFormat:(NSString*)dateFormat
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone: [NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateFormat];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
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
//仅输入字母或数字 正则
- (BOOL)inputShouldLetterOrNumWithText:(NSString *)inputString {
    if (inputString.length == 0) return NO;
    NSString *regex =@"[a-zA-Z0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:inputString];
}
@end
