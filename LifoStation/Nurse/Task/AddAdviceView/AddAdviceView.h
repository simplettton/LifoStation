//
//  AddAdviceView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^returnBlock) (NSString *);
@interface AddAdviceView : UIView
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) returnBlock returnEvent;
- (instancetype)initWithContent:(NSString*)content return:(returnBlock)returnEvent;
@end
