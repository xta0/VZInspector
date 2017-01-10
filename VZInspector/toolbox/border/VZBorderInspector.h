//
//  VZBorderInspector.h
//  VZInspector
//
//  Created by lingwan on 15/4/16.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZBorderInspector : NSObject

@property(nonatomic,assign,readonly) BOOL isON;

+ (instancetype)sharedInstance;
+ (void)setViewClassPrefixName:(NSString* )name;

- (void)showBorder;
- (void)showViewClassName;

@end
