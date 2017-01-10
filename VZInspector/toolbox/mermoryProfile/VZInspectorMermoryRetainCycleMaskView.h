//
//  VZInspectorMermoryRetainCycleMaskView.h
//  APInspector
//
//  Created by 净枫 on 2016/12/21.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorMaskView.h"
#import "VZInspectorMermoryRetainCycleResultItem.h"

@interface VZInspectorMermoryRetainCycleMaskView : VZInspectorMaskView

- (instancetype)initWithFrame:(CGRect)frame rootView:(UIView *)rootView data:(VZInspectorMermoryRetainCycleResultItem *)item;


@end
