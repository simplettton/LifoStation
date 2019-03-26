//
//  EditMachineViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/4.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "EditMachineViewController.h"
#import "UIView+TYAlertView.h"
#import "ChooseDepartmentView.h"
#import "UIView+Tap.h"
#import "DepartmentModel.h"
@interface EditMachineViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIView *departmentView;
@property (weak, nonatomic) IBOutlet UILabel *departmentNameLabel;

@end

@implementation EditMachineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
    // Do any additional setup after loading the view.
}

- (void)initAll {
    self.nameTextField.text = self.machineName;
    [self.nameTextField setValue:[NSNumber numberWithInt:10] forKey:@"paddingLeft"];
    [self.departmentView addTapBlock:^(id obj) {
        ChooseDepartmentView  *view = [[ChooseDepartmentView alloc]initWithDic:@{@"department":self.departmentNameLabel.text} return:^(NSString *selectedUuid) {

            self.departmentNameLabel.text = [[Constant sharedInstance]departmentDic][selectedUuid];
        }];
        [view showInWindow];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Actions

- (IBAction)return:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}
@end
