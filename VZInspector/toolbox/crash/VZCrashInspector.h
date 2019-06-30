//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZCrashInspector : NSObject

+ (instancetype)sharedInstance;
- (void)install;
- (NSDictionary* )crashForKey:(NSString* )key;
- (NSArray* )crashPlist;
- (NSArray* )crashLogs;


@end
