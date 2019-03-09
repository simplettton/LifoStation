//
//  AddLocationView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddLocationView.h"
#import "UIView+TYAlertView.h"
@implementation AddLocationView
- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (IBAction)saveAction:(id)sender {
    [self hideView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initAll];
}
- (void)initAll {

}

@end
