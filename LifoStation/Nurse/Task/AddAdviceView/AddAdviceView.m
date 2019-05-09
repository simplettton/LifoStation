//
//  AddAdviceView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddAdviceView.h"
#import "UIView+TYAlertView.h"
@interface AddAdviceView()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
@implementation AddAdviceView
- (instancetype)initWithContent:(NSString *)content return:(returnBlock)returnEvent {
    if (self = [super init]) {
        AddAdviceView *view = [AddAdviceView createViewFromNib];
        if (content) {
            view.textView.text = content;
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
    if (self.textView.text.length>0) {
        self.returnEvent(self.textView.text);
        [self hideView];
    } else {
        [BEProgressHUD showMessage:@"输入信息不可为空"];
    }

}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initAll];
}
- (void)initAll {
    _textView.layer.borderColor = UIColorFromHex(0xcdcdcd).CGColor;
    _textView.layer.borderWidth = 0.5f;
    _textView.delegate = self;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}
#pragma mark - TextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Check for total length
    NSUInteger proposedNewLength = textView.text.length - range.length + text.length;
    if (proposedNewLength > 200) {
        return NO;//限制长度
    }
    return YES;
}
@end
