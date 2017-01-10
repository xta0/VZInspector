//
//  VZInspectorToolItem.h
//  APInspector
//
//  Created by Sleen on 2016/12/7.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VZInspectorToolItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *(^callback)(NSString *status);

+ (instancetype)itemWithName:(NSString *)name icon:(UIImage *)icon callback:(void(^)())callback;
+ (instancetype)switchItemWithName:(NSString *)name icon:(UIImage *)icon callback:(BOOL(^)(BOOL on))callback;
+ (instancetype)statusItemWithName:(NSString *)name icon:(UIImage *)icon callback:(NSString *(^)(NSString *status))callback;

- (void)performAction;

@end
