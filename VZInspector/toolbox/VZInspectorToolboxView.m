//
//  VZToolboxView.m
//  VZInspector
//
//  Created by lingwan on 15/4/16.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import "VZInspectorToolboxView.h"
#import "VZInspectorResource.h"
#import <objc/runtime.h>


@interface VZInspectorToolboxView()
{
    int  _marginTop;
    NSArray* _icons;
}


@end

@implementation VZInspectorToolboxView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _marginTop = 120;
       
        
        _icons = @[@{@"Logs":[VZInspectorResource network_logs]},
                   @{@"Heap":[VZInspectorResource heap]},
                   @{@"Crash":[VZInspectorResource crash]},
                   @{@"SandBox":[VZInspectorResource sandbox]},
                   @{@"Gird":[VZInspectorResource grid]}];

        float w = frame.size.width / 5;
        float h = w;
        
        //draw grid
        for (int i=0; i<6; i++) {
        
            int x1 = i*w;
            int y1 = _marginTop;
            
            if (i==5) {
                x1 -= 2;
            }
            UIView* verticalLine = [[UIView alloc]initWithFrame:CGRectMake(x1, y1, 2, h*4)];
            verticalLine.backgroundColor = [UIColor grayColor];
            [self addSubview:verticalLine];
        }
        
        for (int i=0; i<5; i++) {
            
            int y2 = i*h + _marginTop;
            int x2 = 0;
            
            UIView* horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(x2, y2, frame.size.width, 2)];
            horizontalLine.backgroundColor = [UIColor grayColor];
            [self addSubview:horizontalLine];
        }

        for (int i=0; i<_icons.count; i++) {
            
            int x =   w*i;
            int y = _marginTop + (i/5)*h*i;
            
            UIButton* btn  = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, w)];
            btn.backgroundColor = [UIColor clearColor];
            btn.imageView.backgroundColor = [UIColor clearColor];
            
            NSDictionary* tuple = _icons[i];
            NSString* title = [tuple allKeys][0];
            UIImage* icon   = [tuple allValues][0];
            [btn setTitle: title forState:UIControlStateNormal];
            [btn setImage: icon forState:UIControlStateNormal];
            
            [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
            [btn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, (w-icon.size.width)/2  , 0, 0)];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(icon.size.height+20, -(w-icon.size.width)/2, 0, 0)];
            
//            [btn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//            [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
//        
            [self addSubview:btn];
        
        }
    }
    return self;
}


@end
