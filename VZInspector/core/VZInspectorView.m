//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import "VZInspectorView.h"

@implementation VZInspectorView

- (id)initWithFrame:(CGRect)frame parentViewController:(UIViewController* )controller
{
    self.parentViewController = controller;
    return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    return self;
}

- (void)update
{
    //noop
}

- (void)pop
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.parentViewController performSelector:@selector(onBack)];
#pragma clang diagnostic pop
}

- (BOOL)canTouchPassThrough:(CGPoint)pt
{
    return NO;
}

@end
