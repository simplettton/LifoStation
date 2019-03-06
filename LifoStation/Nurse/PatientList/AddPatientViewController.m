//
//  AddPatientViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/25.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddPatientViewController.h"

@interface AddPatientViewController ()
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *editViews;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *requiredTextFields;
@property (weak, nonatomic) IBOutlet UIView *medicalNumView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControll;
@property (weak, nonatomic) IBOutlet UITextField *medicalRecordNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *bedNumTextField;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextFiled;

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
}



@end
