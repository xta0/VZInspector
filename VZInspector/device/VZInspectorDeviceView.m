//
//  VZInspectorDeviceView.m
//  VZInspector
//
//  Created by John Wong on 5/10/15.
//  Copyright (c) 2015 VizLabe. All rights reserved.
//

#import "VZInspectorDeviceView.h"
#import "VZDevice.h"

@interface VZInspectorDeviceView ()

@property (nonatomic, strong) UITextView* textView;
@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation VZInspectorDeviceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 13, frame.size.width, 18)];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = [UIFont systemFontOfSize:18.0f];
        textLabel.text = @"Device Info";
        [self addSubview:textLabel];
        
        
        _textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 44, CGRectGetWidth(frame)-20, CGRectGetHeight(frame)-20)];
        _textView.font = [UIFont fontWithName:@"Courier-Bold" size:15];
        _textView.textColor = [UIColor orangeColor];
        _textView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        _textView.indicatorStyle = 0;
        _textView.editable = NO;
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _textView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        _textView.layer.borderWidth = 2.0f;
        _textView.text = [[VZDevice infoArray] componentsJoinedByString:@"\n"];
        [self addSubview:_textView];
        
        _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 44, 44)];
        _backBtn.backgroundColor = [UIColor clearColor];
        [_backBtn setTitle:@"<-" forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [_backBtn addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backBtn];
        
    }
    return self;
}

- (void)pop
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.parentViewController performSelector:@selector(onBack)];
#pragma clang diagnostic pop
}

@end
