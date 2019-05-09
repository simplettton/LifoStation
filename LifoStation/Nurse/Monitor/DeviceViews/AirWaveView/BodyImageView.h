//
//  BodyImageView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/25.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BodyImageView : UIImageView
/** 获取当前imageview的name */
@property (nonatomic,strong)IBInspectable NSString *bodyName;
@property (nonatomic,strong)NSTimer *changeColorTimer;
- (instancetype)initWithView:(UIImageView *)view;
- (void)closeTimer;
- (void)changeGreenColor;
- (void)changeColor:(NSString *)color;
@end
