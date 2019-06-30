//
//  Copyright © 2016年 Vizlab. All rights reserved.
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
