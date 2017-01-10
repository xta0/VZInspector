//
//  VZControllerStack.m
//  APInspector
//
//  Created by John Wong on 6/16/16.
//  Copyright © 2016 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZControllerStack.h"

@implementation VZControllerStack

+ (NSString *)controllerStack
{
    UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    return [self controllerStackWithController:vc indent:0];
}

+ (NSString *)controllerStackWithController:(UIViewController *)vc indent:(int)indent
{
    if (!vc) {
        return @"";
    }
    NSMutableString *mutableResult = [NSMutableString string];
    for (int i = 0; i < indent - 1; i ++) {
        [mutableResult appendString:@" |"];
    }
    [mutableResult appendString:indent == 0 ? @"" : vc.presentingViewController.presentedViewController == vc ? @" +" : @" |"];
    [mutableResult appendString:[self descriptionForVc:vc]];
    indent += 1;
    for (UIViewController *childVc in vc.childViewControllers) {
        [mutableResult appendString:[self controllerStackWithController:childVc indent:indent]];
    }
    if (vc.presentedViewController.presentingViewController == vc) {
        [mutableResult appendString:[self controllerStackWithController:vc.presentedViewController indent:indent]];
    }
    return mutableResult;
}

+ (NSString *)descriptionForVc:(UIViewController *)vc
{
    int state = [[vc valueForKey:@"_appearState"] intValue];
    NSString *appearState = nil;
    switch (state) {
        case 0:
            appearState = @"disappeared";
            break;
        case 1:
            appearState = @"will appear";
            break;
        case 2:
            appearState = @"appeared";
            break;
        default:
            appearState = @"";
            break;
    }
    
    return [NSString stringWithFormat:@"<%@ %@>\n", vc.class, vc.isViewLoaded ? appearState : @"not loaded"];
}

@end
