//
//  AirWaveSetParameterView.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/19.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AirWaveSetParameterView.h"
typedef NS_ENUM(NSInteger , Treatmode){
    StandardMode = 1,
    GradientMode,
    ParameterMode
};
@interface AirWaveSetParameterView()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, assign) NSInteger selectedMode;

@property (weak, nonatomic) IBOutlet UIStackView *parameterStackView;
@property (weak, nonatomic) IBOutlet UIStackView *modeView;

@property (weak, nonatomic) IBOutlet UILabel *pressureTitle;
@property (weak, nonatomic) IBOutlet UILabel *timeTitle;
@property (weak, nonatomic) IBOutlet UILabel *modeTitle;
@property (weak, nonatomic) IBOutlet UIPickerView *pressurePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *timePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;

@end
@implementation AirWaveSetParameterView
{
    NSMutableArray *pressArray;
    NSArray *modeArray;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initAll];
}
- (void)initAll {
    self.selectedMode = StandardMode;
    [self initPickerView];
}
- (void)initPickerView {
    pressArray = [[NSMutableArray alloc]initWithCapacity:20];
    for (int i = 0; i< 241; i++)
    {
        [pressArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    minuteArray = [[NSMutableArray alloc]initWithCapacity:20];
    for (int i=0; i<600; i++)
    {
        [minuteArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [minuteArray addObject:@"持续时间"];
        modeArray = @[@"1",@"2",@"3",@"4",@"5",@"6"];
    [self.modePicker selectRow:3 inComponent:0 animated:YES];
    [self.timePicker selectRow:100 inComponent:0 animated:YES];
    [self.pressurePicker selectRow:100 inComponent:0 animated:YES];
}
- (IBAction)changeMode:(UIButton *)sender {
    self.selectedMode = [sender tag];
    for (UIButton *button in self.modeView.subviews) {
        if([button tag] == self.selectedMode) {
            button.backgroundColor = UIColorFromHex(0x61BEDD);
            [button setTitleColor:UIColorFromHex(0xffffff) forState:UIControlStateNormal];
        } else {
            button.backgroundColor = UIColorFromHex(0xF8F8F8);
            [button setTitleColor:UIColorFromHex(0x212121) forState:UIControlStateNormal];
        }
    }
    switch (self.selectedMode) {
        case StandardMode:
        {
            self.pressureTitle.hidden = NO;
            self.modeTitle.hidden = NO;
            self.pressurePicker.hidden = NO;
            self.modePicker.hidden = NO;
            self.parameterStackView.spacing = 10;
        }
            break;
        case GradientMode:
        {
            self.pressureTitle.hidden = NO;
            self.modeTitle.hidden = YES;
            self.pressurePicker.hidden = NO;
            self.modePicker.hidden = YES;
            self.parameterStackView.spacing = 40;
        }
            break;
        case ParameterMode:
        {
            self.pressureTitle.hidden = YES;
            self.modeTitle.hidden = NO;
            self.pressurePicker.hidden = YES;
            self.modePicker.hidden = NO;
            self.parameterStackView.spacing = 40;
        }
            break;
        default:
            break;
    }

}
#pragma mark - Picker View Datasource
- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    if (pickerView.tag == 1000) {   return pressArray.count;    }
    else if (pickerView.tag == 1001) {    return minuteArray.count;   }
    else if (pickerView.tag == 1002) {  return modeArray.count; }
    else return 0;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    
    if(label == nil)
    {
        label = [[UILabel alloc]init];
        label.font= [UIFont systemFontOfSize:17];
        label.textColor = UIColorFromHex(0x65bba9);
        [label setTextAlignment:NSTextAlignmentCenter];
    }
    if (pickerView.tag == 1000)
    {  label.text = [pressArray objectAtIndex:row];  }
    else if (pickerView.tag == 1001)
    {  label.text = [minuteArray objectAtIndex:row];  }
    else
    {  label.text = [modeArray objectAtIndex:row ];  }

    return label;
}
#pragma mark - Action
- (IBAction)saveAction:(id)sender {
}

- (IBAction)cancelAction:(id)sender {
    [self hideView];
}
@end
