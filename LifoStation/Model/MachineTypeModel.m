//
//  MachineTypeModel.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/7.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "MachineTypeModel.h"
#define MIN_WIDTH 75
@implementation MachineTypeModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
- (instancetype)init {
    if (self = [super init]) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
        
        CGFloat length = [self.name boundingRectWithSize:CGSizeMake(552, 74) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
        self.titleWidth = MAX(length + 20, MIN_WIDTH);
    }
    return self;
}
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"name":@"Name",
              @"typeCode":@"Code",
              @"groupCode":@"GroupCode"
              
              }];
}
@end
