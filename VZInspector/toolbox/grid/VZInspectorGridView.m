//
//  VZInspectorGridView.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "VZInspectorGridView.h"
#import "VZInspectorWindow.h"

@implementation VZInspectorGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        //self.userInteractionEnabled = YES;
        
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(300, 0, 20, 20)];
        btn.backgroundColor = [UIColor clearColor];
        btn.layer.cornerRadius = 10;
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor = [UIColor redColor].CGColor;
        btn.layer.borderWidth = 1.0f;
        [btn setTitle:@"X" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
    }
    return self;
}


- (BOOL)canTouchPassThrough:(CGPoint)pt {
    return pt.y > 20;
}


- (void)drawRect:(CGRect)rect
{
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //横线：
    int h = [UIScreen mainScreen].bounds.size.height;
    int w = [UIScreen mainScreen].bounds.size.width;
    
    for (int i=0; i<=h/20; i++) {
        
        [self drawSingleLine:context :(CGPoint){0, (i)*20} :(CGPoint){w,(i)*20} :[UIColor cyanColor] :0.5f];
        
        if (i%2 == 0) {
            
            NSString* str = [NSString stringWithFormat:@"%d",i*20];
            
            [[UIColor cyanColor] set];
            [str drawAtPoint:CGPointMake(0, (i*20)) withFont:[UIFont systemFontOfSize:8.0f]];
        }
    }
    
    //竖线：
    for (int i=0; i<=w/20; i++) {
        
        [self drawSingleLine:context :(CGPoint){i*20,0} :(CGPoint){i*20,h} :[UIColor cyanColor] : 0.5f];
        
        if (i % 2 == 0) {
            NSString* str = [NSString stringWithFormat:@"%d",i*20];
            
            [[UIColor cyanColor] set];
            [str drawAtPoint:CGPointMake((i*20),0) withFont:[UIFont systemFontOfSize:8.0f]];
            
        }
    }
}


- (void)onClicked:(id)sender
{

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.parentViewController performSelector:@selector(onBack) withObject:nil];
#pragma clang diagnostic pop
    
}

//draw a line
- (void) drawSingleLine:(CGContextRef)context :(CGPoint) startPt :(CGPoint) endPt :(UIColor*) strokeColor :(CGFloat) strokeLineWidth
{
    //CGFloat delta = strokeLineWidth/2;
    //CGFloat delta = 0;
    
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineWidth(context, strokeLineWidth);
    CGContextSetShouldAntialias(context, NO );
    //    CGContextMoveToPoint(context, startPt.x + delta, startPt.y + delta);
    //    CGContextAddLineToPoint(context, endPt.x - delta, endPt.y - delta);
    CGContextMoveToPoint(context, startPt.x+0.5, startPt.y+0.5);
    CGContextAddLineToPoint(context, endPt.x+0.5, endPt.y+0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}


- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if ([self.parentViewController valueForKey:@"topView"] != self ) {
        
        //        [UIWindow swizzle:YES];
        //        [UIWindow blockEvent:YES];
        //        [ETDebuggerWindow sharedInstance].backgroundColor = [UIColor clearColor];
        //        [ETDebuggerWindow sharedInstance].alpha = 1.0f;
        [VZInspectorWindow sharedInstance].backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    }
    else
    {
        //        [UIWindow swizzle:NO];
        //        [UIWindow blockEvent:NO];
        [VZInspectorWindow sharedInstance].backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
    }
    
}


@end
