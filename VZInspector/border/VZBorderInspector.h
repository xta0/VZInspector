//
//  VZBorderInspector.h
//  VZInspector
//
//  Created by lingwan on 15/4/16.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, kVZBorderType) {
    kVZBorderTypeAllView,
    kVZBorderTypeBusinessView
};

@interface VZBorderInspector : NSObject

+ (instancetype)sharedInstance;
+ (void)setClassPrefixName:(NSString* )name;
- (void)updateBorderWithType:(kVZBorderType)type;

@end
