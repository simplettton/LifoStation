//
//  AddDepartmentView.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/8.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^returnBlock) (NSString *);
@interface AddDepartmentView : UIView
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) returnBlock returnEvent;
- (instancetype)initWithDic:(NSDictionary*)dic return:(returnBlock)returnEvent;
@end
