//
//  AppDelegate.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "AppDelegate.h"
#import "VZInspector.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"3d2" ofType:@"png"];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    
//    NSUInteger len = [data length];
//    Byte *byteData = (Byte*)malloc(len);
//    memcpy(byteData, [data bytes], len);
//    
//    for (int i=0; i<len; i++) {
//        
//        printf("0x%x,",byteData[i]);
//    }
    

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [VZInspector setClassPrefixName:@"VZ"];
        [VZInspector setShouldHandleCrash:true];
        [VZInspector setShouldHookNetworkRequest:true];
        [VZInspector setLogNumbers:10];
        [VZInspector setObserveCallback:^NSString *{
            
            NSString* v = [NSString stringWithFormat:@"System Ver:%@\n",[UIDevice currentDevice].systemVersion];
            NSString* n = [NSString stringWithFormat:@"System Name:%@\n",[UIDevice currentDevice].systemName];
            
            NSString* ret = [v stringByAppendingString:n];
            
            return ret;
        }];
        
        [VZInspector setDefaultAPIEnvIndex:2];
        [VZInspector showOnStatusBar];
    });



    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
