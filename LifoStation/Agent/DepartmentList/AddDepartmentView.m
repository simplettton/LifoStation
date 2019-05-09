//
//  AddDepartmentView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/8.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddDepartmentView.h"
#import "UIVIEW+TYAlertView.h"
@interface AddDepartmentView()<UITextFieldDelegate>
@property (nonatomic, assign) BOOL isAddMode;
@property (nonatomic, strong) NSDictionary *dataDic;
@end
@implementation AddDepartmentView
#pragma mark - Init
- (instancetype)initWithDic:(NSDictionary *)dic return:(returnBlock)returnEvent {
    if (self = [super init]) {
        AddDepartmentView *view = [AddDepartmentView createViewFromNib];
        view.dataDic = dic;
        if (dic) {
            view.titleLabel.text = @"编辑科室";
            view.isAddMode = NO;
            view.nameTextField.text = [dic objectForKey:@"Name"];
        }
        else {
            view.titleLabel.text = @"新增科室";
            view.isAddMode = YES;
        }
        view.returnEvent = returnEvent;
        return view;
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self.nameTextField becomeFirstResponder];
    self.nameTextField.delegate = self;
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger proposedNewLength = textField.text.length - range.length + string.length;
    if (proposedNewLength > 7) {
        return NO;//限制长度
    }
    return YES;
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
