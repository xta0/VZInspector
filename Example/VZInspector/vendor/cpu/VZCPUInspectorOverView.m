//
//  VZCPUInspectorOverView.m
//  VZInspector
//
//  Created by lingwan on 15/4/30.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZCPUInspectorOverView.h"
#import "VZCPUInspector.h"
#import "VZInspectorPlotView.h"
#import "NSObject+VZInspector.h"

@implementation VZCPUInspectorOverView {
    UILabel *			_titleView;
    UILabel *			_statusView;
    VZInspectorPlotView*	_plotView1;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        self.layer.borderWidth = 1.0f;
        
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
        _titleView.text = @"CPU Usage";
        [self addSubview:_titleView];
        
        CGRect statusFrame;
        statusFrame.size.width = 200;
        statusFrame.size.height = 20.0f;
        statusFrame.origin.x = frame.size.width - 200 -10;
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
        _plotView1.fill = NO;
        _plotView1.lowerBound = 0.0f;
        _plotView1.upperBound = 0.0f;
        _plotView1.lineColor = [UIColor orangeColor];
        _plotView1.lineWidth = 2.0f;
        _plotView1.capacity = 50;
        [self addSubview:_plotView1];
    }
    
    return self;
}

- (void)handleRead
{
    [[VZCPUInspector sharedInstance] vz_heartBeat];
}

- (void)handleWrite
{
    float cpuUsage = [VZCPUInspector cpuUsage];
    
    NSMutableArray* tmp = [VZCPUInspector sharedInstance].samplePoints;
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
    [text appendFormat:@"used:%.1f%%", cpuUsage];
    _statusView.text = text;
}

@end
