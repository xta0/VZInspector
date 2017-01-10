//
//  VZInspectorSettingView.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "VZInspectorSettingView.h"
#import "VZSettingInspector.h"


@implementation VZInspectorSettingView

#define cellHeight 40
#define cellColCount 4

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSArray* btns     = [VZSettingInspector currentAPIEnvButtons];
        int w = CGRectGetWidth(frame)/cellColCount;
        
        for (int i=0; i<btns.count; i++) {
            
            int x =   w*(i%cellColCount);
            int y =  (i/cellColCount)*cellHeight;
            
            NSDictionary* env = btns[i];
            UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(x,y, w, cellHeight)];
            btn.tag = i;
            btn.backgroundColor = [UIColor darkGrayColor];
            btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
            btn.layer.borderWidth = 2.0f;
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
            [btn setTitle:[env allKeys][0] forState:UIControlStateNormal];
            
            BOOL selected = [[env allValues][0][1] boolValue];
            [btn setTitleColor:selected?[UIColor orangeColor]:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(onBtnClikced:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            
        }
    }
    
    return self;
}

+ (CGFloat)heightForEnvButtons {
    CGFloat theHeight = 0;
    NSArray* btns = [VZSettingInspector currentAPIEnvButtons];
    theHeight = ceil((double)btns.count/cellColCount) * cellHeight;
    
    return theHeight;
}

- (void)onBtnClikced:(UIButton* )sender
{
    for (UIView* v in self.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton* btn = (UIButton* )v;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    [sender setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
 
    NSInteger tag = sender.tag;
    NSDictionary* env = [VZSettingInspector currentAPIEnvButtons][tag];
    vz_api_env_callback callback = [env allValues][0][0];
    
    if (callback) {
        callback();
    }
    
    //close window
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.parentViewController performSelector:@selector(onClose)];
#pragma clang diagnostic pop
}



@end
