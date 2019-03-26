//
//  PatientModel.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/12.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@interface PatientModel : JSONModel

@property (nonatomic, strong) NSString *medicalNumber;
@property (nonatomic, strong) NSString *personName;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString<Optional>* treatAddress;
@property (nonatomic, strong) NSString<Optional>* gender;
@property (nonatomic, strong) NSString<Optional>* age;
@property (nonatomic, strong) NSString<Optional>* birthday;
@property (nonatomic, strong) NSString<Optional>* phoneNumber;
@property (nonatomic, strong) NSString<Optional>* registeredDate;
@property (nonatomic, strong) NSNumber<Optional>* taskState;

@end
