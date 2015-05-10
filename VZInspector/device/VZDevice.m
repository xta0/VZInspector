//
//  VZDevice.m
//  VZInspector
//
//  Created by John Wong on 5/10/15.
//  Copyright (c) 2015 VizLabe. All rights reserved.
//

#import "VZDevice.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@implementation VZDevice

+ (NSString *)systemVersion {
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString *)systemName {
    return [UIDevice currentDevice].systemName;
}

+ (NSString *)name {
    return [UIDevice currentDevice].name;
}

+ (NSString *)model {
    return [UIDevice currentDevice].model;
}

+ (NSString *)locationAuth {
    NSString *authStaus;
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            authStaus = @"kCLAuthorizationStatusNotDetermined";
            break;
        case kCLAuthorizationStatusRestricted:
            authStaus = @"kCLAuthorizationStatusRestricted";
            break;
        case kCLAuthorizationStatusDenied:
            authStaus = @"kCLAuthorizationStatusDenied";
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            authStaus = @"kCLAuthorizationStatusAuthorizedAlways";
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            authStaus = @"kCLAuthorizationStatusAuthorizedWhenInUse";
            break;
        default:
            break;
    }
    return authStaus;
}

+ (BOOL)isJailbroken {
    NSString *result = nil;
#if !(TARGET_IPHONE_SIMULATOR)
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"]){
        return YES;
    }else if([[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"]){
        return YES;
    }
    
    if (result == nil) {
        NSError *error;
        NSString *stringToBeWritten = @"This is a test.";
        [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES
                              encoding:NSUTF8StringEncoding error:&amp;error];
        if(error==nil){
            //Device is jailbroken
            return YES;
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
        }
    }
    
    if(result == nil && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]){
        //Device is jailbroken
        return YES;
    }
#endif
    return NO;
}

+ (NSArray *)infoArray {
    return @[
             [NSString stringWithFormat:@"System Ver: %@", [self systemVersion]],
             [NSString stringWithFormat:@"System Name: %@", [self systemName]],
             [NSString stringWithFormat:@"Device Name: %@", [self name]],
             [NSString stringWithFormat:@"Device Model: %@", [self model]],
             [NSString stringWithFormat:@"Location Auth: %@", [self locationAuth]],
             [NSString stringWithFormat:@"Jailbroken: %@", [self isJailbroken] ? @"YES" : @"NO"]
             ];
}

@end
