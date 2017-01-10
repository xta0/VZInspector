//
//  VZDevice.h
//  VZInspector
//
//  Created by John Wong on 5/10/15.
//  Copyright (c) 2015 VizLabe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZDevice : NSObject

+ (NSString *)systemVersion;
+ (NSString *)systemName;
+ (NSString *)name;
+ (NSString *)model;
+ (NSString *)locationAuth;
+ (NSString *)uuid;

+ (NSString *)networkType;
+ (NSArray *)infoArray;

@end
