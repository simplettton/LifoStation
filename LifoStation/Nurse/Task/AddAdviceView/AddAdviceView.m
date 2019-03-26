//
//  AddAdviceView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddAdviceView.h"
#import "UIView+TYAlertView.h"
@interface AddAdviceView()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
@implementation AddAdviceView
- (instancetype)initWithContent:(NSString *)content return:(returnBlock)returnEvent {
    if (self = [super init]) {
        AddAdviceView *view = [AddAdviceView createViewFromNib];
        if (content) {
            view.titleLabel.text = @"编辑医嘱";
            view.textView.text = content;
        } else {
            view.titleLabel.text = @"添加医嘱";
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
    }
    [self hideView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initAll];
}
- (void)initAll {
    _textView.layer.borderColor = UIColorFromHex(0xcdcdcd).CGColor;
    _textView.layer.borderWidth = 0.5f;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}
@end
