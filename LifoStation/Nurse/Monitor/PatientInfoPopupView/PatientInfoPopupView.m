//
//  PatientInfoPopupView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/18.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PatientInfoPopupView.h"
#import "UIView+TYAlertView.h"
@interface PatientInfoPopupView()
@property (weak, nonatomic) IBOutlet UILabel *medicalNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *treatAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstLineHeight;

@end
@implementation PatientInfoPopupView
- (instancetype)initWithDic:(NSDictionary *)dic {
    if ([super init]) {
        NSString *name = [dic objectForKey:@"name"];
        NSString *gender = [dic objectForKey:@"gender"];
        PatientInfoPopupView *view = [PatientInfoPopupView createViewFromNib];
        view.nameLabel.text = name;
        view.genderLabel.text = gender;
        return view;
    }
    return self;
}
- (instancetype)initWithModel:(PatientModel *)model {
    if ([super init]) {
        PatientInfoPopupView *view = [PatientInfoPopupView createViewFromNib];
        view.model = model;
        return view;
    }
    return self;
}
- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self initAll];
}
- (void)initAll {
    
    self.medicalNumLabel.text = self.model.medicalNumber;
    self.nameLabel.text = self.model.personName;
    self.genderLabel.text = self.model.gender;
    
    
    self.ageLabel.text = self.model.age;
    self.treatAddressLabel.text = [self.model.treatAddress length] > 0 ? self.model.treatAddress : @"-";
    
    self.phoneNumberLabel.text = [self.model.phoneNumber length] > 0 ? self.model.phoneNumber : @"-";
    
    if([self.model.medicalNumber length] > 18 ) {
        self.firstLineHeight.constant = 75;
    }
}

@end
