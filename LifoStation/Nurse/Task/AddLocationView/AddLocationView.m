//
//  AddLocationView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddLocationView.h"
#import "UIView+TYAlertView.h"
@interface AddLocationView()<UITextFieldDelegate>
@property (nonatomic, assign) BOOL isAddMode;
@property (nonatomic, strong) NSDictionary *dataDic;

@end
@implementation AddLocationView
- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (IBAction)saveAction:(id)sender {
    NSString *name = self.nameTextField.text;
    if (name.length == 0) {
        [BEProgressHUD showMessage:@"输入信息不可为空"];
    } else {
        self.returnEvent(name);
        [self hideView];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.nameTextField becomeFirstResponder];
    [self initAll];
}
- (void)initAll {
    self.nameTextField.delegate = self;
}
- (instancetype)initWithDic:(NSDictionary *)dic return:(returnBlock)returnEvent {
    if (self = [super init]) {
        AddLocationView *view = [AddLocationView createViewFromNib];
        view.dataDic = dic;
        if (dic) {
            view.titleLabel.text = @"编辑位置";
            view.nameTextField.text = [dic objectForKey:@"name"];
        }
        else {
            view.titleLabel.text = @"添加位置";
            view.isAddMode = YES;
        }
        view.returnEvent = returnEvent;
        return view;
    }
    return self;
}
#pragma mark - TextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
        // Check for total length
        NSUInteger proposedNewLength = textField.text.length - range.length + string.length;
        if (proposedNewLength > 8) {
            return NO;//限制长度
        }
        return YES;
}

@end
