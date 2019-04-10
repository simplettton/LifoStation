//
//  AlertSettingViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/7.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AlertSettingViewController.h"
#import "JTMaterialSwitch.h"
#import <MediaPlayer/MediaPlayer.h>
/** 音频库文件 */
#import <AVFoundation/AVFoundation.h>
@interface AlertSettingViewController ()
@property (nonatomic, strong) JTMaterialSwitch *alertSwitch;
@property (nonatomic, strong) JTMaterialSwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UIView *alertSwitchLine;
@property (weak, nonatomic) IBOutlet UIView *soundSwitchLine;
@property (weak, nonatomic) IBOutlet UIView *volumeLine;
/// 系统提供的获取音量的控件
@property (nonatomic, strong) MPVolumeView *volumeView;
/// 从上一个控件遍历得到的 Slider
@property (nonatomic, weak) UISlider *mpVolumeSlider;
/// 自己的slider
@property (weak, nonatomic) IBOutlet UISlider *slider;

/**
 播放器
 */
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) float value;

@end

@implementation AlertSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /** 报警提示 */
    BOOL isAlertSwitchOn = [UserDefault boolForKey:@"IsAlertSwitchOn"];
    JTMaterialSwitchState state;
    if (isAlertSwitchOn) {
        state = JTMaterialSwitchStateOn;
    } else {
        state = JTMaterialSwitchStateOff;
    }
    JTMaterialSwitch *switch1 = [[JTMaterialSwitch alloc]initWithSize:JTMaterialSwitchSizeNormal style:JTMaterialSwitchStyleDefault state:state];

    switch1.center = CGPointMake(720, 20);
    [self.alertSwitchLine addSubview:switch1];
    self.alertSwitch = switch1;

    [self.alertSwitch addTarget:self action:@selector(didChangeSwitch:) forControlEvents:UIControlEventAllEvents];
    
    
    /** 报警开关 */
    BOOL isSoundSwitchOn = [UserDefault boolForKey:@"IsSoundSwitchOn"];
    if (isSoundSwitchOn) {
        state = JTMaterialSwitchStateOn;
    } else {
        state = JTMaterialSwitchStateOff;
    }
    JTMaterialSwitch *switch2 = [[JTMaterialSwitch alloc]initWithSize:JTMaterialSwitchSizeNormal style:JTMaterialSwitchStyleDefault state:state];
    switch2.center = CGPointMake(720, 20);
    [self.soundSwitchLine addSubview:switch2];
    self.soundSwitch = switch2;
    [self.soundSwitch addTarget:self action:@selector(didChangeSwitch:) forControlEvents:UIControlEventAllEvents];
    
    /** 滑块音量注释 */
    [self setupSlider];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemVolumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    BOOL isAlertSwitchOn = [self.alertSwitch getSwitchState];
    BOOL isSoundSwitchOn = [self.soundSwitch getSwitchState];
    [UserDefault setBool:isAlertSwitchOn forKey:@"IsAlertSwitchOn"];
    [UserDefault setBool:isSoundSwitchOn forKey:@"IsSoundSwitchOn"];
    [UserDefault synchronize];
}
- (void)systemVolumeChanged:(NSNotification *)notification {
    if([[notification.userInfo objectForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"] isEqualToString:@"ExplicitVolumeChange"]) {
        float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
        _mpVolumeSlider.value = volume;
        [self.slider setValue:volume animated:YES];
    }
}
#pragma mark - JTMaterialSwitch

- (void)didChangeSwitch:(id)sender {
    if ([sender isEqual:self.alertSwitch]) {
        if (![self.alertSwitch getSwitchState]) {
            [self.soundSwitch setOn:NO animated:YES];
            [self.slider setEnabled:NO];
        } else {
            [self.soundSwitch setOn:YES animated:YES];
            [self.slider setEnabled:YES];
        }
    } else {
        if (![self.soundSwitch getSwitchState]) {
            [self.slider setEnabled:NO];
        } else {
            if (![self.alertSwitch getSwitchState]) {
                [self.soundSwitch setOn:NO animated:YES];
                 [self.slider setEnabled:NO];
            } else {
                [self.slider setEnabled:YES];
            }

        }

    }
}
#pragma mark - Slider
- (void)setupSlider {
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    CGFloat systemVolume = audioSession.outputVolume;
    self.slider.tintColor = [UIColor clearColor];
    self.slider.minimumTrackTintColor = UIColorFromHex(0x3A87C7); //滑轮左边颜色，如果设置了左边的图片就不会显示
    self.slider.value = systemVolume;
    self.slider.maximumTrackTintColor = UIColorFromHex(0xf8f8f8);
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];

    _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -100, 100, 100)];
    [_volumeView setShowsVolumeSlider:YES];
    _volumeView.showsRouteButton = NO;
    [_volumeView sizeToFit];
    [self.view addSubview:_volumeView];
    for (UIView *subView in [_volumeView subviews]) {
        if ([subView.class.description isEqualToString:@"MPVolumeSlider"]){
            _mpVolumeSlider = (UISlider*)subView;
            break;
        }
    }
    if (![self.soundSwitch getSwitchState] || ![self.alertSwitch getSwitchState]) {
        self.slider.enabled = NO;
    }
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    _mpVolumeSlider.value = slider.value;
    LxDBAnyVar(_mpVolumeSlider.value);
    self.value = slider.value;
    self.player.volume = self.value;
    [self.player play];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

#pragma mark - lazy
- (AVAudioPlayer *)player {
    if (!_player) {
        NSError *err;
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"warninglow" withExtension:@"wav"];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
        _player.volume = 0.5;
        [_player prepareToPlay];
        
    }
    return _player;
}
@end
