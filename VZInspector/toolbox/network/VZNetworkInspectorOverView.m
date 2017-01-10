////
////  VZNetworkInspectorOverView.m
////  VZInspector
////
////  Created by moxin.xt on 14-9-23.
////  Copyright (c) 2014年 VizLab. All rights reserved.
////
//
//#include <QuartzCore/QuartzCore.h>
//#import "VZNetworkInspectorOverView.h"
//#import "VZInspectorPlotView.h"
//#import "NSObject+VZInspector.h"
//#import "VZNetworkInspector.h"
//
//
//
//@implementation VZNetworkInspectorOverView
//{
//    UILabel *			_titleView;
//    UILabel *			_statusView;
//    VZInspectorPlotView*	_plotView1;
//}
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        
//        //self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
//        self.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
//        self.layer.borderWidth = 1.0f;
//        
//        CGRect plotFrame;
//        plotFrame.size.width = frame.size.width;
//        plotFrame.size.height = frame.size.height - 20.0f;
//        plotFrame.origin.x = 0.0f;
//        plotFrame.origin.y = 20.0f;
//        
//        //draw http connection pool
//        _plotView1 = [[VZInspectorPlotView alloc] initWithFrame:plotFrame];
//        _plotView1.alpha = 0.6f;
//        _plotView1.lowerBound = 0.0f;
//        _plotView1.upperBound = 0.0f;
//        _plotView1.lineColor = [UIColor yellowColor];
//        _plotView1.lineWidth = 2.0f;
//        _plotView1.capacity = 50;
//        _plotView1.fill = NO;
//        [self addSubview:_plotView1];
//        
//        
//        CGRect titleFrame;
//        titleFrame.size.width = 120.0f;
//        titleFrame.size.height = 20.0f;
//        titleFrame.origin.x = 8.0f;
//        titleFrame.origin.y = 0.0f;
//        
//        _titleView = [[UILabel alloc] initWithFrame:titleFrame];
//        _titleView.textColor = [UIColor orangeColor];
//        _titleView.textAlignment = NSTextAlignmentLeft;
//        _titleView.font = [UIFont boldSystemFontOfSize:12.0f];
//        _titleView.lineBreakMode = NSLineBreakByClipping;
//        _titleView.backgroundColor = [UIColor clearColor];
//        _titleView.numberOfLines = 1;
//        _titleView.text = @"Network";
//        [self addSubview:_titleView];
//        
//        CGRect statusFrame;
//        statusFrame.size.width = 200;
//        statusFrame.size.height = 20.0f;
//        statusFrame.origin.x = frame.size.width - 200 -10;
//        statusFrame.origin.y = 0.0f;
//        
//        _statusView = [[UILabel alloc] initWithFrame:statusFrame];
//        _statusView.textColor = [UIColor whiteColor];
//        _statusView.textAlignment = NSTextAlignmentRight;
//        _statusView.font = [UIFont boldSystemFontOfSize:12.0f];
//        _statusView.lineBreakMode = NSLineBreakByClipping;
//        _statusView.numberOfLines = 1;
//        _statusView.backgroundColor = [UIColor clearColor];
//        [self addSubview:_statusView];
//        
//    }
//    return self;
//}
//
//- (void)handleRead
//{
//    [[VZNetworkInspector sharedInstance] vz_heartBeat];
//}
//- (void)handleWrite
//{
//    [self writeHeartBeat];
//}
//
//- (void)writeHeartBeat
//{
// 
//    NSMutableString * text = [NSMutableString string];
//    [text appendFormat:@"Count: %ld",(long)[VZNetworkInspector sharedInstance].totalNetworkCount];
//    [text appendFormat:@"  Bytes:%@  ",[self number2String:[VZNetworkInspector sharedInstance].totalResponseBytes]];
//    
//    _statusView.text = text;
//    
//    //http connection pool
//    NSArray* tmp2 = [VZNetworkInspector sharedInstance].samplePoints.copy;
//    CGFloat _upperBound2 = 1;
//    CGFloat _lowerBound2 = 0;
//    
//    for ( NSNumber * n in tmp2 )
//    {
//        if ( n.intValue > _upperBound2 )
//        {
//            _upperBound2 = n.intValue;
//            if ( _upperBound2 < _lowerBound2 )
//            {
//                _lowerBound2 = _upperBound2;
//            }
//        }
//        else if ( n.intValue < _lowerBound2 )
//        {
//            _lowerBound2 = n.intValue;
//        }
//    }
//    
//    [_plotView1 setPlots:tmp2];
//    [_plotView1 setLowerBound:_lowerBound2];
//    [_plotView1 setUpperBound:_upperBound2];
//    [_plotView1 setNeedsDisplay];
//    
//}
//#define KB	(1024)
//#define MB	(KB * 1024)
//#define GB	(MB * 1024)
//
//- (NSString* )number2String:(int64_t)n
//{
//    if ( n < KB )
//    {
//        return [NSString stringWithFormat:@"%lldB", n];
//    }
//    else if ( n < MB )
//    {
//        return [NSString stringWithFormat:@"%.1fK", (float)n / (float)KB];
//    }
//    else if ( n < GB )
//    {
//        return [NSString stringWithFormat:@"%.1fM", (float)n / (float)MB];
//    }
//    else
//    {
//        return [NSString stringWithFormat:@"%.1fG", (float)n / (float)GB];
//    }
//}
//
//
//@end
