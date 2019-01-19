//
//  PatientInfoPopupView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/18.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatientInfoPopupView : UIView
- (instancetype)initWithDic:(NSDictionary *)dic;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@end
