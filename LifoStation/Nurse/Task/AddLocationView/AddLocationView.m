//
//  AddLocationView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/9.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AddLocationView.h"
#import "UIView+TYAlertView.h"
@interface AddLocationView()
@property (nonatomic, assign) BOOL isAddMode;
@property (nonatomic, strong) NSDictionary *dataDic;

@end
@implementation AddLocationView
- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (IBAction)saveAction:(id)sender {
    NSString *name = self.nameTextField.text;
    self.returnEvent(name);
    [self hideView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.nameTextField becomeFirstResponder];
    [self initAll];
}
- (void)initAll {

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
@end
