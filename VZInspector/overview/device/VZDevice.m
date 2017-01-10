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
#include <ifaddrs.h>
#include <arpa/inet.h>

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

+ (NSString *)uuid{
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
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
    
    NSError *error;
    NSString *stringToBeWritten = @"This is a test.";
    [stringToBeWritten writeToFile:@"/private/jailbreak.txt"
                        atomically:YES
                          encoding:NSUTF8StringEncoding error:&error];
    if(error==nil){
        //Device is jailbroken
        return YES;
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    }
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]){
        //Device is jailbroken
        return YES;
    }
#endif
    return NO;
}

+ (NSString *)networkType {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    id itemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            itemView = subview;
            break;
        }
    }
    
    NSString *netType = @"none";
    NSNumber * num = [itemView valueForKey:@"dataNetworkType"];
    if (num != nil) {
        NSInteger n = [num intValue];
        if (n == 1) {
            netType = @"2G";
        } else if (n == 2) {
            netType = @"3G";
        } else if (n == 3) {
            // 不确定4G是什么
            netType = @"4G";
        } else if (n != 0) {
            netType = @"Wifi";
        }
    }
    return netType;
}

+ (NSString *)proxy {
    
    CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();
    BOOL proxyHttpEnable = [(__bridge NSNumber *)CFDictionaryGetValue(dicRef, (const void*)kCFNetworkProxiesHTTPEnable) boolValue];
    if (proxyHttpEnable) {
        NSString *host = (__bridge NSString *)CFDictionaryGetValue(dicRef, (const void*)kCFNetworkProxiesHTTPProxy);
        NSString *port = (__bridge NSString *)CFDictionaryGetValue(dicRef, (const void*)kCFNetworkProxiesHTTPPort);
        CFRelease(dicRef);
        return [NSString stringWithFormat:@"manual %@:%@", host, port];
    }
    
    BOOL proxyAutoEnable = [(__bridge NSNumber *)CFDictionaryGetValue(dicRef, (const void*)kCFNetworkProxiesProxyAutoConfigEnable) boolValue];
    if (proxyAutoEnable) {
        NSString *configUrl = (__bridge NSString *)CFDictionaryGetValue(dicRef, (const void*)kCFNetworkProxiesProxyAutoConfigURLString);
        CFRelease(dicRef);
        return [NSString stringWithFormat:@"auto %@", configUrl];
    }
    CFRelease(dicRef);
    return @"disabled";
}

+ (NSString *)ipAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (NSString *)operator {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    id itemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarServiceItemView") class]]) {
            itemView = subview;
            break;
        }
    }
    NSString * service = [itemView valueForKey:@"serviceString"];
    return service ? : @"none";
}

+ (NSArray *)infoArray {
    return @[
             [NSString stringWithFormat:@"System Ver: %@", [self systemVersion]],
             [NSString stringWithFormat:@"System Name: %@", [self systemName]],
             [NSString stringWithFormat:@"Device Name: %@", [self name]],
             [NSString stringWithFormat:@"Device Model: %@", [self model]],
             [NSString stringWithFormat:@"Location Auth: %@", [self locationAuth]],
             [NSString stringWithFormat:@"Jailbroken: %@", [self isJailbroken] ? @"YES" : @"NO"],
             [NSString stringWithFormat:@"Network: %@", [self networkType]],
             [NSString stringWithFormat:@"Proxy: %@", [self proxy]],
             [NSString stringWithFormat:@"IP: %@", [self ipAddress]],
             [NSString stringWithFormat:@"Operator: %@", [self operator]]
             ];
}


@end
