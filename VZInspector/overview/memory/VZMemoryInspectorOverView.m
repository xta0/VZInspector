//
//  VZMemoryInspectorOverView.m
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "VZMemoryInspectorOverView.h"
#import "VZInspectorPlotView.h"
#import "VZMemoryInspector.h"
#import "NSObject+VZInspector.h"


const int kThreshHold = 60.0f;
@implementation VZMemoryInspectorOverView
{
    UILabel *			_titleView;
    UILabel *			_statusView;
    VZInspectorPlotView*	_plotView1;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        CGRect lineRect = CGRectMake(0, 0, frame.size.width, 1.0f);
        
        UIView *topLine = [[UIView alloc] initWithFrame:lineRect];
        topLine.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
        [self addSubview:topLine];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectOffset(lineRect, 0, frame.size.height)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
        [self addSubview:bottomLine];
        
        CGRect titleFrame;
        titleFrame.size.width = 90.0f;
        titleFrame.size.height = 20.0f;
        titleFrame.origin.x = 8.0f;
        titleFrame.origin.y = 0.0f;
        
        _titleView = [[UILabel alloc] initWithFrame:titleFrame];
        _titleView.textColor = [UIColor orangeColor];
        _titleView.textAlignment = NSTextAlignmentLeft;
        _titleView.font = [UIFont boldSystemFontOfSize:12.0f];
        _titleView.lineBreakMode = NSLineBreakByClipping;
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.numberOfLines = 1;
        _titleView.text = @"Memory Usage";
        [self addSubview:_titleView];
        
        CGRect statusFrame;
        statusFrame.size.width = 200;
        statusFrame.size.height = 20.0f;
        statusFrame.origin.x = frame.size.width - 200-10;
        statusFrame.origin.y = 0.0f;
        
        _statusView = [[UILabel alloc] initWithFrame:statusFrame];
        _statusView.textColor = [UIColor whiteColor];
        _statusView.textAlignment = NSTextAlignmentRight;
        _statusView.font = [UIFont boldSystemFontOfSize:12.0f];
        _statusView.lineBreakMode = NSLineBreakByClipping;
        _statusView.numberOfLines = 1;
        _statusView.backgroundColor = [UIColor clearColor];
        [self addSubview:_statusView];
        
        CGRect plotFrame;
        plotFrame.size.width = frame.size.width;
        plotFrame.size.height = frame.size.height - 20;
        plotFrame.origin.x = 0.0f;
        plotFrame.origin.y = 20.0f;
        
        _plotView1 = [[VZInspectorPlotView alloc] initWithFrame:plotFrame];
        _plotView1.alpha = 0.6f;
        _plotView1.lowerBound = 0.0f;
        _plotView1.upperBound = 0.0f;
        _plotView1.lineColor = [UIColor orangeColor];
        _plotView1.lineWidth = 2.0f;
        _plotView1.capacity = 50;
        _plotView1.fill = NO;
        [self addSubview:_plotView1];
    }
    
    return self;
}

- (void)dealloc
{
    //NSLog(@"[%@]-->dealloc",self.class);
}

- (void)handleRead
{
    [[VZMemoryInspector sharedInstance] vz_heartBeat];
}
- (void)handleWrite
{
    [self writeHeartBeat];
}

- (void)writeHeartBeat
{
    //NSLog(@"writeHeartBeat");
    
    float used = [VZMemoryInspector bytesOfUsedMemory];
    float total = [VZMemoryInspector bytesOfTotalMemory];
    
    float percent = (total > 0.0f) ? ((float)used / (float)total * 100.0f) : 0.0f;
    if ( percent >= kThreshHold )
    {
        //预警
        [UIView animateWithDuration:0.6f
                              delay:0.0f
                            options: UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                         animations: ^(void){self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6f];}
                         completion:NULL];
    }
    else
    {
        
        [UIView animateWithDuration:0.6f
                              delay:0.0f
                            options: UIViewAnimationOptionBeginFromCurrentState
                         animations: ^(void){self.backgroundColor = [UIColor clearColor];}
                         completion:NULL];
    }
    
    NSMutableArray* tmp = [VZMemoryInspector sharedInstance].samplePoints;
    CGFloat _upperBound = 1;
    CGFloat _lowerBound = 0;
    
    for ( NSNumber * n in tmp )
    {
        if ( n.intValue > _upperBound )
        {
            _upperBound = n.intValue;
            if ( _upperBound < _lowerBound )
            {
                _lowerBound = _upperBound;
            }
        }
        else if ( n.intValue < _lowerBound )
        {
            _lowerBound = n.intValue;
        }
    }
    
    
    [_plotView1 setPlots:tmp];
    [_plotView1 setLowerBound:_lowerBound];
    [_plotView1 setUpperBound:_upperBound];
    [_plotView1 setNeedsDisplay];
    
    
    
    NSMutableString * text = [NSMutableString string];
    [text appendFormat:@"used:%@ (%.0f%%)   ", [self number2String:used], percent];
    [text appendFormat:@"free:%@  ", [self number2String:total - used]];
    _statusView.text = text;
}

#define KB	(1024)
#define MB	(KB * 1024)
#define GB	(MB * 1024)

- (NSString* )number2String:(int64_t)n
{
    if ( n < KB )
    {
        return [NSString stringWithFormat:@"%lldB", n];
    }
    else if ( n < MB )
    {
        return [NSString stringWithFormat:@"%.1fK", (float)n / (float)KB];
    }
    else if ( n < GB )
    {
        return [NSString stringWithFormat:@"%.1fM", (float)n / (float)MB];
    }
    else
    {
        return [NSString stringWithFormat:@"%.1fG", (float)n / (float)GB];
    }
}

@end
