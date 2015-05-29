//
//  UIWindow+VZInspector.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "UIWindow+VZInspector.h"
#include <UIKit/UIKit.h>
#include <QuartzCore/QuartzCore.h>
#include <objc/runtime.h>
#import "VZInspectorOverlay.h"


static bool g_blockEvent = false;
static bool g_swizzled = false;
static void (*g_sendEvent)(id,SEL,UIEvent* );



@implementation UIWindow (VZInspector)

+ (BOOL)isSwizzled
{
    UIWindow* keywindow = [UIApplication sharedApplication].keyWindow;
    
    if (keywindow == self)
    {
        return g_swizzled;
    }
    return NO;
}
+ (void)blockEvent:(BOOL) b
{
    g_blockEvent = b;
}

+ (void)swizzle:(BOOL)b
{
    g_swizzled = b;
    
    Method imp = class_getInstanceMethod([UIWindow class], @selector(sendEvent:));
    
    if (b) {
        g_sendEvent = (void* )class_getMethodImplementation([UIWindow class],@selector(sendEvent:));
    }
    
    IMP swizzleMethod = class_getMethodImplementation([UIWindow class], @selector(swizzle_SendEvent:));
    
    
    if (b) {
        method_setImplementation(imp, swizzleMethod);
    }
    else
    {
        method_setImplementation(imp, (IMP)g_sendEvent);
    }
    
}

- (void)swizzle_SendEvent:(UIEvent* )event
{
    switch (event.type)
    {
        case UIEventTypeTouches:
        {
            NSSet * allTouches = [event allTouches];
            
            if ( 1 == [allTouches count] )
            {
                UITouch* touch = [allTouches allObjects][0];
                
                if (touch.tapCount == 1)
                {
                    UIWindow* appWnd = [UIApplication sharedApplication].delegate.window;
                    
                    if (appWnd == self)
                    {
                        switch (touch.phase) {
                                
                            case UITouchPhaseBegan:
                            {
                                //NSLog( @"view '%@', touch began\n%@", [[touch.view class] description], [touch.view description] );
                                
                                UIView* border = [[UIView alloc]initWithFrame:CGRectMake(0, 0, touch.view.bounds.size.width, touch.view.bounds.size.height)];
                                border.layer.borderColor = [UIColor redColor].CGColor;
                                border.layer.borderWidth = 2.0f;
                                border.layer.backgroundColor = [UIColor clearColor].CGColor;
                                border.alpha = 0.8f;
                                [touch.view addSubview:border];
                                
                                
                                UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, touch.view.bounds.size.width-10, 10)];
                                label.text = [NSString stringWithFormat:@"[%.0f,%.0f,%.0f,%.0f]",touch.view.frame.origin.x,
                                              touch.view.frame.origin.y,
                                              touch.view.frame.size.width,
                                              touch.view.frame.size.height];
                                label.textAlignment = NSTextAlignmentRight;
                                label.textColor = [UIColor redColor];
                                label.font = [UIFont systemFontOfSize:10.0f];
                                label.backgroundColor = [UIColor clearColor];
                                [touch.view addSubview:label];
                                
                                [UIView animateWithDuration:0.8 animations:^{
                                    
                                    border.alpha = 0.0f;
                                    label.alpha = 0.0f;
                                    
                                    
                                } completion:^(BOOL finished) {
                                    
                                    [border removeFromSuperview];
                                    [label removeFromSuperview];
                                    
                                    
                                }];
                                
                                
                                break;
                            }
                            case UITouchPhaseMoved:
                            {
                                break;
                            }
                                
                            case UITouchPhaseEnded:
                            case UITouchPhaseCancelled:
                            {
                                
                                break;
                                
                            }
                            default:
                                break;
                        }//end of switch
                    }//end of if
                    else
                    {
                        [[self class] swizzle:NO];
                        
                        CGPoint pt = [touch locationInView:self];
                        
                        //show debugger:todo
                        if (CGRectContainsPoint([VZInspectorOverlay sharedInstance].frame, pt)) {
                            [[VZInspectorOverlay sharedInstance] sendEvent:event];
                        }
                    }
                }//end of if
                
            }//end of if
            
            break;
        }//end of case
        default:
            break;
    }//end of switch
    
    //pass event
    if (!g_blockEvent && g_sendEvent) {
        g_sendEvent(self,_cmd,event);
    }
}

@end
