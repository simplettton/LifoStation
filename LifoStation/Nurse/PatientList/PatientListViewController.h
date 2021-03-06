//
//  PatientListViewController.h
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/25.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "PatientModel.h"
@interface PatientListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UITextFieldDelegate>
@property (nonatomic, strong) PatientModel *patient;
@property (nonatomic, assign) BOOL hasNewPatient;
@end
