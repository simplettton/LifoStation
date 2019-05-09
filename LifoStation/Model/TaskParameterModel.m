//
//  taskParameterModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/23.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TaskParameterModel.h"

@implementation TaskParameterModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
                        @{
                          @"showName":@"ShowName",
                          @"unit":@"Unit",
                          @"value":@"DefaultValue",
                          @"selectionList":@"SelectionList"
                          }];
}
- (NSDictionary *)getParamDictionary {
    if (self.selectionList) {
        for (NSDictionary *dic in self.selectionList) {
            NSNumber *value = dic[@"Value"];
            if ([self.value integerValue] == [value integerValue]) {
                self.value = dic[@"ShowName"];
                break;
            }
        }
    }
    //空气波持续治疗模式时间处理
    if ([self.value isEqualToString:@"持续治疗"]) {
        self.unit = @"";
    }
        return @{
                 @"showName":self.showName,
                 @"value":[NSString stringWithFormat:@"%@%@",self.value,self.unit]};
    
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end
