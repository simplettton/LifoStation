//
//  AlertSettingViewController.m
//  LifoStation
//
//  Created by Binger Zeng on 2019/3/7.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AlertSettingViewController.h"
#import "JTMaterialSwitch.h"
@interface AlertSettingViewController ()
@property (nonatomic, strong) JTMaterialSwitch *alertSwitch;
@property (nonatomic, strong) JTMaterialSwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UIView *alertSwitchLine;
@property (weak, nonatomic) IBOutlet UIView *soundSwitchLine;
@property (weak, nonatomic) IBOutlet UIView *volumeLine;

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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    BOOL isAlertSwitchOn = [self.alertSwitch getSwitchState];
    BOOL isSoundSwitchOn = [self.soundSwitch getSwitchState];
    [UserDefault setBool:isAlertSwitchOn forKey:@"IsAlertSwitchOn"];
    [UserDefault setBool:isSoundSwitchOn forKey:@"IsSoundSwitchOn"];
    [UserDefault synchronize];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
