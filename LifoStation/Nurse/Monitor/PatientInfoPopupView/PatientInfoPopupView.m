//
//  PatientInfoPopupView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/18.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PatientInfoPopupView.h"
#import "UIView+TYAlertView.h"
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
- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
