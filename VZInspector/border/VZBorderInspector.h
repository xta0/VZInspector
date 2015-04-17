//
//  VZBorderInspector.h
//  VZInspector
//
//  Created by lingwan on 15/4/16.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZBorderInspector : NSObject

+ (instancetype)sharedInstance;
+ (void)setClassPrefixName:(NSString* )name;
- (void)updateBorderCore:(NSNumber *)status ifShowBusinessBorder:(BOOL)flag;

@end
