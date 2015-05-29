//
//  VZInspectorPlotView.h
//  VZInspector
//
//  Created by moxin.xt on 14-9-23.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VZInspectorPlotView : UIView

@property (nonatomic, assign) BOOL			fill;
@property (nonatomic, assign) BOOL			border;
@property (nonatomic, assign) CGFloat		lineScale;
@property (nonatomic, retain) UIColor *		lineColor;
@property (nonatomic, assign) CGFloat		lineWidth;
@property (nonatomic, assign) CGFloat		lowerBound;
@property (nonatomic, assign) CGFloat		upperBound;
@property (nonatomic, assign) NSUInteger	capacity;
@property (nonatomic, retain) NSArray *		plots;
@property (nonatomic, assign) CGFloat        dot;

@end
