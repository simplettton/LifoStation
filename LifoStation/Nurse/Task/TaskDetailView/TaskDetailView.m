//
//  TaskDetailView.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/27.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "TaskDetailView.h"
#import "UIView+TYAlertView.h"
#import "TaskModel.h"
#define LineHeight 52
@interface TaskDetailView()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *treatInfoViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *patientInfoHeight;

@property (nonatomic, strong) NSDictionary *dataDic;
@property (weak, nonatomic) IBOutlet UITextView *suggestTextView;
@property (weak, nonatomic) IBOutlet UIView *treatInfoView;

@end
@implementation TaskDetailView
- (instancetype)initWithModel:(TaskModel *)model {
    if (self = [super init]) {
        TaskDetailView *view = [TaskDetailView createViewFromNib];
        view.model = model;
        return view;
    }
    return self;
}

- (void)layoutSubviews {
    [self initAll];
    [self addParams];
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
- (void)initAll {
    NSString *medicalNumberString = [NSString stringWithFormat:@"病历号:%@",self.model.patient.medicalNumber];

    self.medicalNumLabel.text = medicalNumberString;
    self.nameLabel.text = [NSString stringWithFormat:@"姓名:%@",self.model.patient.personName];
    NSString *address = (self.model.patient.treatAddress == nil) ? @"-":self.model.patient.treatAddress;
    self.treatAddressLabel.text = [NSString stringWithFormat:@"位置:%@",address];
    NSString *gender = (self.model.patient.gender == nil) ? @"-" :self.model.patient.gender;
    self.genderLabel.text = [NSString stringWithFormat:@"性别:%@",gender];
    NSString *age = (self.model.patient.age == nil) ? @"-":self.model.patient.age;
    self.ageLabel.text = [NSString stringWithFormat:@"年龄:%@岁",age];
    self.creatDateLabel.text = [NSString stringWithFormat:@"就诊时间:%@",[self stringFromTimeIntervalString:self.model.creatTime dateFormat:@"yyyy-MM-dd"]];
    
    if ([self.model.suggest length] > 0) {
        self.suggestTextView.text = self.model.suggest;
    } else {
        self.suggestTextView.text = @"无";
    }
    
    //病历号有两行时重新计算高度
    if (_medicalNumLabel.bounds.size.height > 22.5) {
        self.patientInfoHeight.constant = 125;
    }
}
- (void)addParams {
    NSMutableArray *paramList = [self.model.solution.paramList mutableCopy];
//    NSMutableArray *paramList = [NSMutableArray arrayWithObjects:
//                                       @{
//                                           @"showName":@"治疗模式",@"value":@"标准治疗"
//                                           },
//                                       @{
//                                           @"showName":@"治疗压力",@"value":@"200mmHg"
//                                           },
//                                       @{
//                                           @"showName":@"红光治疗时间",@"value":@"40min"
//                                           },
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
//                                       @{
//                                           @"showName":@"附件时间",@"value":@"20min"
//                                           }, nil];

    //防止重复添加
    NSDictionary *typeDic = [UserDefault objectForKey:@"MachineTypeDic"];
    if (![paramList containsObject:@{@"showName":@"主治医生",@"value":self.model.creatorName}]) {
        [paramList insertObject:@{@"showName":@"主治医生",@"value":self.model.creatorName} atIndex:0];
        if ([self.model.state integerValue] == 2) {
            //排队中任务
            [paramList insertObject:@{@"showName":@"治疗设备",@"value":typeDic[self.model.solution.machineType]} atIndex:1];
        } else {
            //治疗中已完成任务
            [paramList insertObject:@{@"showName":@"执行护士",@"value":self.model.operatorName} atIndex:1];
            [paramList insertObject:@{@"showName":@"治疗设备",@"value":typeDic[self.model.solution.machineType]} atIndex:2];
            [paramList insertObject:@{@"showName":@"设备名称",@"value":self.model.machine.name} atIndex:2];
        }


    }


    
    //两列参数一行 计算行数
    NSInteger numberOfLines =( [paramList count] +1 )/2 ;

    for (int i = 0; i < numberOfLines ; i++) {

        UIView *containView = [[UIView alloc]initWithFrame:CGRectMake(0, LineHeight * i, 630, 52)];
        UIView *underLineView = [[UIView alloc]initWithFrame:CGRectMake(25, 51, 630 - 25*2, 1)];
        [containView addSubview:underLineView];
        underLineView.backgroundColor = UIColorFromHex(0xECE8E8);

        [self.treatInfoView addSubview:containView];
        NSString *showName = [paramList[i*2] objectForKey:@"showName"];
        NSString *value = [paramList[i*2] objectForKey:@"value"];
        UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 16, 260, 21)];
        firstLabel.textColor = UIColorFromHex(0x212121);
        firstLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightThin];
        firstLabel.text = [NSString stringWithFormat:@"%@: %@",showName,value];
        [containView addSubview:firstLabel];
        
        //判断某行第一个是不是最后一个param
        if ((i*2+1) != [paramList count]) {
            NSString *showName = [paramList[i*2 + 1] objectForKey:@"showName"];
            NSString *value = [paramList[i*2 + 1] objectForKey:@"value"];
            UILabel *secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(300, 16, 260, 21)];
            secondLabel.textColor = UIColorFromHex(0x212121);
            secondLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightThin];
            secondLabel.text = [NSString stringWithFormat:@"%@: %@",showName,value];
            [containView addSubview:secondLabel];
        }

    }
    //scollview contentheight 重新计算
    self.treatInfoViewHeight.constant = numberOfLines * LineHeight + 40;
}
#pragma mark - Private Method
//时间戳字符串转化为日期或时间
- (NSString *)stringFromTimeIntervalString:(NSString *)timeString dateFormat:(NSString*)dateFormat
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone: [NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:dateFormat];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}
@end
