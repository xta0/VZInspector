//
//  VZInspectorPlotView.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZInspectorPlotView.h"

@implementation VZInspectorPlotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.fill = YES;
        self.border = YES;
        self.lineScale = 0.8f;
        self.lineColor = [UIColor whiteColor];
        self.lineWidth = 2.0f;
        self.lowerBound = 0.0f;
        self.upperBound = 1.0f;
        self.capacity = 50;
    }
    return self;
}

- (void)dealloc
{
    _lineColor = nil;
    _plots = nil;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ( context )
    {
        CGContextClearRect( context, self.bounds );
        
        if ( self.fill )
        {
            CGRect bound = CGRectInset( self.bounds, 4.0f, 2.0f );
            CGPoint baseLine;
            baseLine.x = bound.origin.x;
            baseLine.y = bound.origin.y + bound.size.height;
            
            UIBezierPath * pathLines = [UIBezierPath bezierPath];
            [pathLines moveToPoint:baseLine];
            
            NSUInteger step = 0;
            
            for ( NSNumber * value in [_plots copy] )
            {
                CGFloat v = value.floatValue;
                
                if ( v < _lowerBound )
                {
                    v = _lowerBound;
                }
                else if ( v > _upperBound )
                {
                    v = _upperBound;
                }
                
                CGFloat f = (v - _lowerBound) / (_upperBound - _lowerBound) * _lineScale;
                CGPoint p = CGPointMake( baseLine.x, baseLine.y - bound.size.height * f );
                [pathLines addLineToPoint:p];
                
                baseLine.x += bound.size.width / _capacity;
                
                step += 1;
                if ( step >= _capacity )
                    break;
            }
            
            [self.lineColor set];
            
            [pathLines addLineToPoint:baseLine];
            //		[pathLines fill];
            [pathLines fillWithBlendMode:kCGBlendModeXOR alpha:0.6f];
        }
        
        if ( self.border )
        {
            CGRect bound = CGRectInset( self.bounds, 4.0f, 2.0f );
            CGPoint baseLine;
            baseLine.x = bound.origin.x;
            baseLine.y = bound.origin.y + bound.size.height;
            
            CGContextMoveToPoint( context, baseLine.x, baseLine.y );
            
            NSUInteger step = 0;
            
            for ( NSNumber * value in [_plots copy] )
            {
                CGFloat v = value.floatValue;
                
                if ( v < _lowerBound )
                {
                    v = _lowerBound;
                }
                else if ( v > _upperBound )
                {
                    v = _upperBound;
                }
                
                CGFloat f = (v - _lowerBound) / (_upperBound - _lowerBound) * _lineScale;
                CGPoint p = CGPointMake( baseLine.x, baseLine.y - bound.size.height * f );
                
                CGContextAddLineToPoint( context, p.x, p.y );
                
                //                if (v == _upperBound) {
                //                    [[UIColor redColor] set];
                //                    [@"top" drawAtPoint:p withFont:[UIFont systemFontOfSize:13]];
                //                }
                CGContextSetStrokeColorWithColor( context, self.lineColor.CGColor );
                CGContextSetLineWidth( context, self.lineWidth );
                CGContextSetLineCap( context, kCGLineCapRound );
                CGContextSetLineJoin( context, kCGLineJoinRound );
                CGContextStrokePath( context );
                
                CGContextMoveToPoint( context, p.x, p.y );
                baseLine.x += bound.size.width / _capacity;
                
                step += 1;
                if ( step >= _capacity )
                    break;
            }
        }
    }
}


@end
