//
//  O2OMethodTraceView.m
//  VZInspector
//
//  Created by lingwan on 10/16/15.
//  Copyright © 2015 VizLab. All rights reserved.
//

#import "O2OMethodTraceView.h"
#import "O2OMethodTrace.h"
#import "O2OMethodTrace+Statistic.h"

#define kO2OScreenWidth [UIApplication sharedApplication].keyWindow.frame.size.width
#define kO2OScreenHeight [UIApplication sharedApplication].keyWindow.frame.size.height

@interface O2OMethodTraceView ()
@property (nonatomic, strong) UITextView* statisticTextView;
@property (nonatomic, strong) UITextView* stackTextView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UILabel *classNameLabel;
@end

@implementation O2OMethodTraceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _classNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 13, frame.size.width, 18)];
        _classNameLabel.textAlignment = NSTextAlignmentCenter;
        _classNameLabel.textColor = [UIColor whiteColor];
        _classNameLabel.backgroundColor = [UIColor clearColor];
        _classNameLabel.font = [UIFont systemFontOfSize:18.0f];
        _classNameLabel.text = @"MTrace";
        [self addSubview:_classNameLabel];
        
        _statisticTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 40, CGRectGetWidth(frame)-20, 120)];
        _statisticTextView.font = [UIFont fontWithName:@"Courier-Bold" size:12];
        _statisticTextView.textColor = [UIColor orangeColor];
        _statisticTextView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        _statisticTextView.indicatorStyle = 0;
        _statisticTextView.editable = NO;
        _statisticTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _statisticTextView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        _statisticTextView.layer.borderWidth = 2.0f;
        [self addSubview:_statisticTextView];
        
        _stackTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, _statisticTextView.frame.origin.y + _statisticTextView.frame.size.height + 5, CGRectGetWidth(frame)-20, kO2OScreenHeight - 60 - _statisticTextView.frame.size.height)];
        _stackTextView.font = [UIFont fontWithName:@"Courier-Bold" size:12];
        _stackTextView.textColor = [UIColor orangeColor];
        _stackTextView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        _stackTextView.indicatorStyle = 0;
        _stackTextView.editable = NO;
        _stackTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _stackTextView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        _stackTextView.layer.borderWidth = 2.0f;
        [self addSubview:_stackTextView];
        
        _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 32, 32)];
        _backBtn.backgroundColor = [UIColor clearColor];
        [_backBtn setTitle:@"<-" forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [_backBtn addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backBtn];
    }
    
    return self;
}

- (void)setClassName:(NSString *)className {
    if (![className isEqualToString:_className]) {
        _className = className;
        self.classNameLabel.text = className;
        [self traceMethod];
    }
}

- (void)traceMethod {
    NSString *className = self.className;
    [O2OMethodTrace traceClass:NSClassFromString(className)];
    
    __weak typeof(self) weakSelf = self;
    [O2OMethodTrace setShowResultBlock:^(NSString *stack, NSString *statistic) {
        [UIView setAnimationsEnabled:NO];

        weakSelf.statisticTextView.text = statistic;
        weakSelf.stackTextView.text = stack;
        [weakSelf scrollTextViewToEnd:weakSelf.statisticTextView];
        [weakSelf scrollTextViewToEnd:weakSelf.stackTextView];

        [UIView setAnimationsEnabled:YES];
    }];
}

- (void)scrollTextViewToEnd:(UITextView *)textView {
    if(textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(textView.text.length - 1, 1);
        [textView scrollRangeToVisible:bottom];
    }
}

- (void)pop
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.parentViewController performSelector:@selector(onBack)];
#pragma clang diagnostic pop
}

@end
