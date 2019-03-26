//
//  ReportTableViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/10.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "ReportTableViewController.h"
#import "AddAdviceView.h"
#import <MMAlertView.h>
#import "TimeLineModel.h"
#import "BETimeLine.h"

#import "UIImage+Rotate.h"
#import "JLImageMagnification.h"
#import "PopoverView.h"
#define LineHeight 52
@interface ReportTableViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *alertContentView;
@property (weak, nonatomic) IBOutlet UIView *treatInfoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *treatInfoViewHeight;

@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (strong,nonatomic)UIImage *image;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pictureButtonItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *printButtonItem;

@property (strong,nonatomic)BETimeLine *timeLine;
/**
 *  判断各部分cell是否显示
 */
@property (nonatomic, assign) BOOL hasAlertMessage;
@property (nonatomic, assign) BOOL hasPicture;
@property (nonatomic, assign) BOOL hasAdvice;
@property (weak, nonatomic) IBOutlet UITextView *adviceTextView;

@property (nonatomic, strong) NSString *advice;
@property (nonatomic, assign) BOOL hasVedio;
@end

@implementation ReportTableViewController {
    NSMutableArray *alertDatas;
}
#pragma mark - Init
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0xf8f8f8);
    self.navigationController.navigationBar.tintColor = UIColorFromHex(0x272727);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColorFromHex(0x272727)}];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = UIColorFromHex(0x3A87C7);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAll];
}
- (void)getTreatInfomationData {
//    NSMutableArray *paramList = [NSMutableArray arrayWithObjects:
//                                 @{
//                                   @"showName":@"治疗模式",@"value":@"标准治疗"
//                                   },
//                                 @{
//                                   @"showName":@"治疗压力",@"value":@"200mmHg"
//                                   },
//                                 @{
//                                   @"showName":@"红光治疗时间",@"value":@"40min"
//                                   },
//                                 @{
//                                   @"showName":@"红光治疗模式",@"value":@"连续"
//                                   },
//                                 @{
//                                   @"showName":@"红光治疗能量",@"value":@"4"
//                                   },
//                                 @{
//                                   @"showName":@"蓝光治疗时间",@"value":@"20min"
//                                   },
//                                 @{
//                                   @"showName":@"蓝光治疗模式",@"value":@"脉冲"
//                                   },
//                                 @{
//                                   @"showName":@"蓝光治疗能量",@"value":@"1"
//                                   },
//                                 @{
//                                   @"showName":@"温度检测开关",@"value":@"开"
//                                   },
//                                 @{
//                                   @"showName":@"温度设定值",@"value":@"38°"
//                                   },
//                                 @{
//                                   @"showName":@"治疗方案",@"value":@"5"
//                                   },
//                                 @{
//                                   @"showName":@"附件类型",@"value":@"耳道"
//                                   },
//                                 @{
//                                   @"showName":@"附件光源",@"value":@"red"
//                                   },
//                                 @{
//                                   @"showName":@"附件时间",@"value":@"20min"
//                                   }, nil];
    NSMutableArray *paramList = [NSMutableArray arrayWithObjects:
                                 @{
                                   @"showName":@"红光治疗时间",@"value":@"40min"
                                   },
                                 @{
                                   @"showName":@"红光治疗模式",@"value":@"连续"
                                   },
                                 @{
                                   @"showName":@"红光治疗能量",@"value":@"4"
                                   },
                                 @{
                                   @"showName":@"蓝光治疗时间",@"value":@"20min"
                                   },
                                 @{
                                   @"showName":@"蓝光治疗模式",@"value":@"脉冲"
                                   },
                                 @{
                                   @"showName":@"蓝光治疗能量",@"value":@"1"
                                   },

                                 @{
                                   @"showName":@"附件光源",@"value":@"red"
                                   },
                                 @{
                                   @"showName":@"附件时间",@"value":@"20min"
                                   }, nil];
    [paramList insertObject:@{@"showName":@"主治医生",@"value":@"李医生"} atIndex:0];
    [paramList insertObject:@{@"showName":@"执行护士",@"value":@"小护士"} atIndex:1];
    
    //两列参数一行 计算行数
    NSInteger numberOfLines =( [paramList count] +1 )/2 ;
    
    for (int i = 0; i < numberOfLines ; i++) {
        
        UIView *containView = [[UIView alloc]initWithFrame:CGRectMake(0, LineHeight * i + 20, kScreenWidth, 52)];
        UIView *underLineView = [[UIView alloc]initWithFrame:CGRectMake(25, 51, kScreenWidth - 25*2, 1)];
        [containView addSubview:underLineView];
        underLineView.backgroundColor = UIColorFromHex(0xECE8E8);
        
        [self.treatInfoView addSubview:containView];
        NSString *showName = [paramList[i*2] objectForKey:@"showName"];
        NSString *value = [paramList[i*2] objectForKey:@"value"];
        UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 16, 260, 21)];
        firstLabel.textColor = UIColorFromHex(0x212121);
        firstLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightThin];
        firstLabel.text = [NSString stringWithFormat:@"%@:%@",showName,value];
        [containView addSubview:firstLabel];
        
        if ([paramList count] % 2 == 0) {
            NSString *showName = [paramList[i*2 + 1] objectForKey:@"showName"];
            NSString *value = [paramList[i*2 + 1] objectForKey:@"value"];
            UILabel *secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(400, 16, 260, 21)];
            secondLabel.textColor = UIColorFromHex(0x212121);
            secondLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightThin];
            secondLabel.text = [NSString stringWithFormat:@"%@:%@",showName,value];
            [containView addSubview:secondLabel];
        }
        
    }
    //scollview contentheight 重新计算
    self.treatInfoViewHeight.constant = numberOfLines * LineHeight + 60;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
- (void)getAlertInfomationData {
    NSMutableArray *datas = [[NSMutableArray alloc]initWithCapacity:20];
    NSMutableArray *testDatas = [NSMutableArray arrayWithObjects:
  @{@"title":@"风扇异常",@"timeStamp":@"1547028360"},
  @{@"title":@"温度报警",@"timeStamp":@"1547031960"},nil];
    for (NSDictionary *dataDic in testDatas) {
        NSError *error;
        TimeLineModel *model = [[TimeLineModel alloc]initWithDictionary:dataDic error:&error];
        BOOL containSameModel = NO;
        for (TimeLineModel *timeLineModel in alertDatas) {
            if ([timeLineModel.timeStamp integerValue] == [model.timeStamp integerValue]) {
                containSameModel = YES;
                break;
            }
        }
        if (!containSameModel) {
            [alertDatas addObject:model];
        }
        CGRect frame = self.alertContentView.frame;
        //每一个cell的高度固定为150
        frame.size.height = 150 * [alertDatas count];
        self.alertContentView.frame = frame;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        self.timeLine = [[BETimeLine alloc]init];
        [self.timeLine setSuperView:self.alertContentView DataArray:alertDatas];
    }
}
- (void)initAll {
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]init];
    backButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    self.hasAlertMessage = YES;
    self.hasPicture = NO;
    self.hasVedio = YES;
    self.hasAdvice = NO;
    alertDatas = [NSMutableArray arrayWithCapacity:20];
    [self getAlertInfomationData];
    [self getTreatInfomationData];
    
    if (self.image) {
        self.resultImageView.image = self.image;
        //图片添加点击放大手势
        UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImageClick:)];
        [self.resultImageView addGestureRecognizer:tapGestureRecognizer1];
        //让UIImageView和它的父类开启用户交互属性
        [self.resultImageView setUserInteractionEnabled:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 70;
    }
    else if (indexPath.row == 1) {
//        return 253;
        return UITableViewAutomaticDimension;
    }
    else if (indexPath.row == 2) {
        if (self.hasAlertMessage) {
            return 44 + [alertDatas count]*150;
        }
        return 0;

    }
    else if (indexPath.row == 3) {
        if (self.hasAdvice) {
            return 200;
        }
        return 0;

    }
    else if (indexPath.row == 4) {
        if (self.hasPicture) {
            return UITableViewAutomaticDimension;
        }
        return 0;
    }
    return 0;
}

#pragma mark - Action

- (IBAction)addAction:(id)sender {

    PopoverAction *action1 = [PopoverAction actionWithTitle:@"添加/编辑医嘱" handler:^(PopoverAction *action) {
        
        AddAdviceView *view = [[AddAdviceView alloc]initWithContent:self.advice return:^(NSString *newAdvice) {
            self.advice = newAdvice;
            self.hasAdvice = YES;
            self.adviceTextView.text = newAdvice;
            [self.tableView reloadData];
        }];
        [view showInWindow];
        
    }];
    PopoverAction *action2 = [PopoverAction actionWithTitle:@"治疗效果图" handler:^(PopoverAction *action) {
        [self addPhotoAction:nil];
    }];
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.style = PopoverViewStyleDefault;
    [popoverView showToView:sender withActions:@[action1,action2]];
}
- (IBAction)printAction:(id)sender {
//    MMPopupItemHandler block = ^(NSInteger index){
//        switch (index) {
//            case 0:
//
//                break;
//            case 1:
//
//                break;
//            default:
//                break;
//        }
//    };
//
//    MMPopupCompletionBlock completeBlock = ^(MMPopupView *popupView, BOOL finished){
//
//    };
//
//    NSArray *items =
//    @[MMItemMake(@"打印预览", MMItemTypeNormal, block),
//      MMItemMake(@"打印", MMItemTypeNormal, block),
//      MMItemMake(@"取消", MMItemTypeNormal, block)];
//
//    [[[MMAlertView alloc] initWithTitle:@"连接工作站打印机"
//                                 detail:@""
//                                  items:items]
//     showWithBlock:completeBlock];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@"是否打印治疗报告？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:confirmAction];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)addPhotoAction:(id)sender {
    MMPopupItemHandler block = ^(NSInteger index){
        switch (index) {
            case 0:
            {
                UIImagePickerController *pickerImage = [[UIImagePickerController alloc]init];
                pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickerImage.allowsEditing = NO;
                pickerImage.delegate = self;
                self.picker = pickerImage;
                [self presentViewController:self.picker animated:YES completion:nil];
            }
                break;
            case 1:
            {
                UIImagePickerController *pickerImage = [[UIImagePickerController alloc]init];
                pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                pickerImage.allowsEditing = YES;
                pickerImage.delegate = self;
                self.picker = pickerImage;
                [self presentViewController:self.picker animated:YES completion:nil];
            }
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
- (void)uploadImage:(id)sender {
    if (self.image) {
//        //上传照片完毕后 更换右上角保存按钮
//        UIBarButtonItem *pictureBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"photo"] style:UIBarButtonItemStylePlain target:self action:@selector(addPhotoAction:)];
//        pictureBarButtonItem.tintColor = UIColorFromHex(0x6DA3E0);
//        self.navigationItem.rightBarButtonItems = @[self.printButtonItem,pictureBarButtonItem];
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.picker dismissViewControllerAnimated:YES completion:NULL];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

//    //待上传照片 更换右上角保存按钮
//    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(uploadImage:)];
//    self.navigationItem.rightBarButtonItems = @[self.printButtonItem,saveBarButtonItem];
    
    //获取图片
    UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage]fixOrientation];
    
    self.image = image;
    self.resultImageView.image = self.image;
    //图片添加点击放大手势
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImageClick:)];
    [self.resultImageView addGestureRecognizer:tapGestureRecognizer1];
    //让UIImageView和它的父类开启用户交互属性
    [self.resultImageView setUserInteractionEnabled:YES];

    self.hasPicture = YES;
    [self.picker dismissViewControllerAnimated:YES completion:^{
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
-(void)scanImageClick:(UITapGestureRecognizer *)tap{
    
    UIImageView *clickedImageView = (UIImageView *)tap.view;
    [JLImageMagnification scanBigImageWithImageView:clickedImageView alpha:1];
}

#pragma mark - Setter
- (NSString *)advice {
    if (!_advice) {
        _advice = [[NSString alloc]init];
    }
    return _advice;
}
@end
