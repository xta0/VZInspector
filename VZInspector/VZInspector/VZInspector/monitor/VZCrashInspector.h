//
//  VZCrashInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLabe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZCrashInspector : NSObject

+ (instancetype)sharedInstance;

- (void)install;
- (NSDictionary* )crashReport;


@end
