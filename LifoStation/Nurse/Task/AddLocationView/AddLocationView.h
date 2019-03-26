//
//  AddLocationView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^returnBlock) (NSString *);
@interface AddLocationView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) returnBlock returnEvent;
- (instancetype)initWithDic:(NSDictionary*)dic return:(returnBlock)returnEvent;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@end
