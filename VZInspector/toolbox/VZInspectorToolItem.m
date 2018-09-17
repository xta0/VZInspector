//
//  VZInspectorToolItem.m
//  VZInspector
//
//  Created by Sleen on 2016/12/7.
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import "VZInspectorToolItem.h"

@implementation VZInspectorToolItem

+ (instancetype)statusItemWithName:(NSString *)name icon:(UIImage *)icon callback:(NSString *(^)(NSString *status))callback {
    VZInspectorToolItem *item = [VZInspectorToolItem new];
    item.name = name;
    item.icon = icon;
    item.callback = callback;
    return item;
}

+ (instancetype)itemWithName:(NSString *)name icon:(UIImage *)icon callback:(void (^)(void))callback {
    return [self statusItemWithName:name icon:icon callback:^NSString *(NSString *status) {
        callback();
        return status;
    }];
}

+ (instancetype)switchItemWithName:(NSString *)name icon:(UIImage *)icon callback:(BOOL (^)(BOOL on))callback {
    return [self statusItemWithName:name icon:icon callback:^(NSString *status) {
        return callback(!!status) ? @"ON" : nil;
    }];
}



- (void)performAction {
    if (self.callback) {
        self.status = self.callback(self.status);
    }
}

@end
