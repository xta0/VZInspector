//
//  VZInspectorSearchBar.m
//  APInspector
//
//  Created by 净枫 on 2016/12/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorSearchBar.h"

@implementation VZInspectorSearchBar

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, _edgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, _edgeInsets)];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds{
    return [super leftViewRectForBounds:UIEdgeInsetsInsetRect(bounds, _edgeInsets)];
}


@end
