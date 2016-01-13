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


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        NSArray* btns     = [VZSettingInspector currentAPIEnvs];
        
        NSUInteger count = btns.count;
        if (count > 4) {
            count = 4;
        }
        
        int w = CGRectGetWidth(frame)/count;
        int h = 40;
        
        for (int i=0; i<btns.count; i++) {
            
            int x =   w*(i%count);
            int y =  (i/count)*h;
            
            NSDictionary* env = btns[i];
            UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(x,y, w, 40)];
            btn.tag = i;
            btn.backgroundColor = [UIColor darkGrayColor];
            btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
            btn.layer.borderWidth = 2.0f;
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
            [btn setTitle:[env allKeys][0] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(onBtnClikced:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];

        }
    }
    
    return self;
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
    NSDictionary* env = [VZSettingInspector currentAPIEnvs][tag];
    vz_api_env_callback callback = [env allValues][0];
    
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
