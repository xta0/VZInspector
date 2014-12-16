//
//  VZInspectorSettingView.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZInspectorSettingView.h"
#import "VZSettingInspector.h"


@implementation VZInspectorSettingView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        for (int i=0; i<3; i++) {
            
            UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/3*i, 0, frame.size.width/3, 40)];
            btn.tag = i;
            btn.backgroundColor = [UIColor darkGrayColor];
            btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
            btn.layer.borderWidth = 2.0f;
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(onBtnClikced:) forControlEvents:UIControlEventTouchUpInside];
            

            if (i==0) {
                [btn setTitle:@"线上" forState:UIControlStateNormal];
                
            }
            if (i==1) {
                [btn setTitle:@"预发" forState:UIControlStateNormal];
            
            }
            if (i==2) {
                [btn setTitle:@"日常" forState:UIControlStateNormal];
       
            }
            
            if (i == [VZSettingInspector sharedInstance].defaultEnvIndex) {
                [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            }
            
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
    
    switch (sender.tag) {
            
            
        case 0:
        {
            //todo:
            if ([VZSettingInspector sharedInstance].apiProductionCallback) {
                [VZSettingInspector sharedInstance].apiProductionCallback();
            }
            
            break;
        }
        case 1:
        {
            //todo:
            if ([VZSettingInspector sharedInstance].apiTestCallback) {
                [VZSettingInspector sharedInstance].apiTestCallback();
            }

            break;
        }
        case 2:
        {
            //todo:
            if ([VZSettingInspector sharedInstance].apiDevCallback) {
                [VZSettingInspector sharedInstance].apiDevCallback();
            }
     
            break;
        }
            
        default:
            break;
    }
    
    //close window
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.parentViewController performSelector:@selector(onClose)];
#pragma clang diagnostic pop
}



@end
