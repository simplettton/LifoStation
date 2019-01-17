//
//  RecordReportViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/8.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "RecordReportViewController.h"
#import <MMAlertView.h>
@interface RecordReportViewController ()

@end

@implementation RecordReportViewController
#pragma mark - View LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];

    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0xf8f8f8);
    self.navigationController.navigationBar.tintColor = UIColorFromHex(0x272727);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0x272727)}];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x3A87C7);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

#pragma mark - Action
- (IBAction)printAction:(id)sender {
    MMPopupItemHandler block = ^(NSInteger index){
        switch (index) {
            case 0:

                break;
            case 1:

                break;
            default:
                break;
        }
    };
    
    MMPopupCompletionBlock completeBlock = ^(MMPopupView *popupView, BOOL finished){
        
    };
    
    NSArray *items =
    @[MMItemMake(@"打印预览", MMItemTypeNormal, block),
      MMItemMake(@"打印", MMItemTypeNormal, block),
      MMItemMake(@"取消", MMItemTypeNormal, block)];
    
    [[[MMAlertView alloc] initWithTitle:@"连接工作站打印机"
                                 detail:@""
                                  items:items]
     showWithBlock:completeBlock];
}

- (IBAction)addPhotoAction:(id)sender {
    MMPopupItemHandler block = ^(NSInteger index){
        switch (index) {
            case 0:
                
                break;
            case 1:
                
                break;
            default:
                break;
        }
    };
    
    MMPopupCompletionBlock completeBlock = ^(MMPopupView *popupView, BOOL finished){
        
    };
    
    NSArray *items =
    @[MMItemMake(@"拍摄", MMItemTypeNormal, block),
      MMItemMake(@"从相册中选择", MMItemTypeNormal, block),
      MMItemMake(@"取消", MMItemTypeNormal, block)];
    
    [[[MMAlertView alloc] initWithTitle:@"添加治疗效果图"
                                 detail:@""
                                  items:items]
     showWithBlock:completeBlock];
}

@end
