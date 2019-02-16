//
//  DeviceFilterView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/29.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface DeviceFilterView : UIView
@property (nonatomic, copy) void (^confirmSelect)(NSArray *selction);
- (instancetype)initWithLastContent:(NSArray *)selectedArray commitBlock:(void(^)(NSArray *selections))commitBlock;
- (void)show;
@end
