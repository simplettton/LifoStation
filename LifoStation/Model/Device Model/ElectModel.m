//
//  ElectModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/4/25.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ElectModel.h"

@implementation ElectModel
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"state":@"State",
              @"treatTime":@"TreatTime",
              @"showTime":@"ShowTime"
              }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
- (NSArray *)getParameterArray {
    NSMutableArray *paramArray = [[NSMutableArray alloc]initWithCapacity:20];
    return [paramArray copy];
}
- (NSString *)getGifName {
    NSArray *gifNameArray = @[
                              @"zhengxianbo",
                              @"fangbo",
                              @"juchibo",
                              @"sanjiaobo",
                              @"maichongbo",
                              @"jianbo",
                              @"tixingbo",
                              @"zhishubo",
                              @"sanxingbo"
                              ];
    return gifNameArray[self.modulationWaveIndex];
}
@end
