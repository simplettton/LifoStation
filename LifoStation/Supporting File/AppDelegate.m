//
//  AppDelegate.m
//  LifoStation
//
//  Created by Binger Zeng on 2018/12/18.
//  Copyright © 2018年 Shenzhen Lifotronic Technology Co.,Ltd. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initRootViewController];
    [self configureNetWorkSetting];
    return YES;
}
- (void)initRootViewController {
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    __block UINavigationController *controller;
    if ([self isUserLogin]) {
        NSString *role = [UserDefault objectForKey:@"Role"];
        if ([role isEqualToString:@"Nurse"]) {
            controller = [mainStoryBoard instantiateViewControllerWithIdentifier:@"NurseNavigation"];
        } else {
            controller = [mainStoryBoard instantiateViewControllerWithIdentifier:@"AgentNavigation"];
        }
    } else {
        controller = [mainStoryBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    }

    [UIView transitionWithView:self.window duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.window.rootViewController = controller;
    } completion:nil];
    [self.window makeKeyAndVisible];
}
- (void)configureNetWorkSetting {
    NSDictionary *defaultNetworkConfiguration = @{
                                                  @"HTTPServerIP":@"192.168.2.127",
                                                  @"HTTPServerPort":@"80",
                                                  @"MQTTPort":@"18826"
                                                  };
    
    if (![UserDefault objectForKey:@"HTTPServerIP"]) {
        [UserDefault setObject:defaultNetworkConfiguration[@"HTTPServerIP"] forKey:@"HTTPServerIP"];
    }
    if (![UserDefault objectForKey:@"HTTPServerPort"]) {
        [UserDefault setObject:defaultNetworkConfiguration[@"HTTPServerPort"] forKey:@"HTTPServerPort"];
    }
    if (![UserDefault objectForKey:@"MQTTPort"]) {
        [UserDefault setObject:defaultNetworkConfiguration[@"MQTTPort"] forKey:@"MQTTPort"];
    }
    
    if (![UserDefault objectForKey:@"HTTPServerURLString"]) {
        [UserDefault setObject:[NSString stringWithFormat:@"http://192.168.2.127:80/"] forKey:@"HTTPServerURLString"];
    }
    
    [UserDefault synchronize];
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark -- LoginCheck
- (BOOL)isUserLogin {
    
    BOOL isLogined = [UserDefault boolForKey:@"IsLogined"];
    
    if (isLogined)
    {
        //已经登录
        return YES;
    }
    return NO;
}


@end
