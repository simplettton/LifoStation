//
//  PatientModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/12.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "PatientModel.h"

@implementation PatientModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"medicalNumber":@"MedicalNumber",
              @"uuid":@"Uid",
              @"personName":@"PersonName",
              @"treatAddress":@"TreatAddress",
              @"gender":@"Gender",
              @"age":@"Age",
              @"birthday":@"Birthday",
              @"taskState":@"TaskState",
              @"registeredDate":@"RegistedTime",
              @"phoneNumber":@"Phone"
              }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end
