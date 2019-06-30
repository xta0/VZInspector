//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZBorderInspector : NSObject

@property(nonatomic,assign,readonly) BOOL isON;

+ (instancetype)sharedInstance;
+ (void)setViewClassPrefixName:(NSString* )name;

- (void)showBorder;
- (void)showViewClassName;

@end
