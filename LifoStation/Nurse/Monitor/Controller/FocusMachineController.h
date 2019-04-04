//
//  FocusMachineController.h
//  LifoStation
//
//  Created by Binger Zeng on 2019/1/25.
//  Copyright © 2019年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MachineModel.h"
@interface FocusMachineController : UIViewController
@property (nonatomic, strong) MachineModel *machine;
@property (strong, nonatomic) MQTTSessionManager *manager;
@end
