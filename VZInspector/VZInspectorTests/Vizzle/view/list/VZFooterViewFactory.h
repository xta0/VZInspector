//
//  VZFooterViewFactory.h
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <UIkit/UIKit.h>

@interface VZFooterViewFactory : NSObject

+ (UIView*)clickableFooterView:(CGRect)frame Text:(NSString*)text Target:(id)target Action:(SEL)action;
+ (UIView*)normalFooterView:(CGRect)frame Text:(NSString*)text;
+ (UIView*)loadingFooterView:(CGRect)frame Text:(NSString*)text;
+ (UIView*)errorFooterView:(CGRect)frame Text:(NSString*)text;

@end
