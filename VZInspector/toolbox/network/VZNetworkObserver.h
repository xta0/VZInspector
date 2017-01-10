//
//  VZNetworkObserver.h
//  Derived from:
//
//  FLEXNetworkObserver
//  Flipboard
//
//  Created by Ryan Olson
//  Copyright (c) 2015 Flipboard. All rights reserved.
//



#import <Foundation/Foundation.h>

extern NSString *const kVZNetworkObserverEnabledStateChangedNotification;


@interface VZNetworkObserver : NSObject


+ (void)setEnabled:(BOOL)enabled;
+ (BOOL)isEnabled;

+ (void)setShouldEnableOnLaunch:(BOOL)shouldEnableOnLaunch;
+ (BOOL)shouldEnableOnLaunch;
+ (void)setIgnoreDelegateClasses:(NSSet *)classes;

@end
