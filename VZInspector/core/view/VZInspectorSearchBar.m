//
//  Copyright © 2016年 Vizlab. All rights reserved.
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
