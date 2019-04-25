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

- (CGFloat)titleWidth {
    CGFloat length = [self getWidthWithText:self.name height:30 font:15];
    return MAX(length + 20, MIN_WIDTH);
    
}
+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc]initWithModelToJSONDictionary:
            @{
              @"name":@"Name",
              @"typeCode":@"Code",
              @"groupCode":@"GroupCode"
              
              }];
}
/**
 
  根据高度求宽度
 
  
 
  @param text 计算的内容
 
  @param height 计算的高度
 
  @param font font字体大小
 
  @return 返回Label的宽度
 
  */

- (CGFloat)getWidthWithText:(NSString *)text height:(CGFloat)height font:(CGFloat)font {
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font weight:UIFontWeightLight]} context:nil];
    return rect.size.width;
    
}

@end
