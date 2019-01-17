//
//  AddDepartmentView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/8.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddDepartmentView.h"
#import "UIVIEW+TYAlertView.h"
@implementation AddDepartmentView
#pragma mark - Init
- (instancetype)initWithDic:(NSDictionary *)dic return:(returnBlock)returnEvent {
    if (self = [super init]) {
        AddDepartmentView *view = [AddDepartmentView createViewFromNib];
        if (dic) {
            view.titleLabel.text = @"编辑科室";
            view.nameTextField.text = [dic objectForKey:@"department"];
        }
        else {
            view.titleLabel.text = @"新增科室";
        }
        view.returnEvent = returnEvent;
        return view;
    }
    return self;
}
- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (IBAction)saveAction:(id)sender {
    if ([self.nameTextField.text length] > 0) {
        self.returnEvent(self.nameTextField.text);
        [self hideView];
    }
    else {
        //提示不能为空
    }

}

@end
