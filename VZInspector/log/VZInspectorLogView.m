//
//  VZInspectorLogView.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "VZInspectorLogView.h"
#import "VZLogInspector.h"


@interface VZInspectorLogView()<UITextFieldDelegate,VZLogInspectorDelegate>

@property(nonatomic,strong)UITextView* textView;
@property(nonatomic,strong)NSAttributedString *attStr;
@property(nonatomic,strong)UIButton* refreshBtn;
@property(nonatomic,strong)UIButton* autoRefreshBtn;
@property(nonatomic,strong)UITextField *filterTextField;
@property(nonatomic,strong)UIActivityIndicatorView* indicator;
@property(nonatomic,assign) BOOL autorefresh;
@end

@implementation VZInspectorLogView{
    NSTimer *_delayTimer;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _autorefresh = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        _filterTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(frame)-20, 30)];
        _filterTextField.delegate = self;
        _filterTextField.backgroundColor = [UIColor clearColor];
        _filterTextField.textColor = [UIColor whiteColor];
        _filterTextField.layer.borderColor = [UIColor whiteColor].CGColor;
        _filterTextField.layer.borderWidth = 2;
        NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:@"search key"];
        [placeholder addAttribute:NSForegroundColorAttributeName
                            value:[UIColor grayColor]
                            range:NSMakeRange(0, @"Search Key".length)];
        _filterTextField.attributedPlaceholder = placeholder;
        [self addSubview:_filterTextField];
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        _filterTextField.leftView = paddingView;
        _filterTextField.leftViewMode = UITextFieldViewModeAlways;
        UIView *paddingViewRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        _filterTextField.rightView = paddingViewRight;
        _filterTextField.rightViewMode = UITextFieldViewModeAlways;
        
        NSArray *list = [VZLogInspector sharedInstance].searchList;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_filterTextField.frame), CGRectGetWidth(_filterTextField.frame), list.count > 0 ? 40 : 0)];
        [self addSubview:scrollView];
        CGFloat left = -5;
        for (int index =0; index<list.count;index ++ ) {
            CGSize s = [list[index] sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(100, 40)];
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(left+5, 2, s.width+5, 30)];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            btn.layer.cornerRadius = 4;
            btn.clipsToBounds = YES;
            [btn setTitle:list[index] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor whiteColor];
            [btn addTarget:self action:@selector(searchKeyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:btn];
            left = CGRectGetMaxX(btn.frame);
        }
        scrollView.contentSize = CGSizeMake(MAX(left, CGRectGetWidth(scrollView.frame)), CGRectGetHeight(scrollView.frame));
        
        _textView = [[UITextView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(scrollView.frame), CGRectGetWidth(frame)-20, CGRectGetHeight(frame)-CGRectGetMaxY(scrollView.frame)-10)];
        _textView.font = [UIFont fontWithName:@"Courier-Bold" size:12];
        _textView.textColor = [UIColor orangeColor];
        _textView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        _textView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _textView.editable = NO;
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _textView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        _textView.layer.borderWidth = 2.0f;
        [self addSubview:_textView];
        
        UIButton *scrollTopBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(_textView.bounds) - 54, CGRectGetMaxY(_textView.frame)-54-64-64, 44, 44)];
        scrollTopBtn.layer.cornerRadius = 22;
        scrollTopBtn.layer.masksToBounds = true;
        scrollTopBtn.layer.borderColor = [UIColor grayColor].CGColor;
        scrollTopBtn.layer.borderWidth = 2.0f;
        [scrollTopBtn setTitle:@"↑" forState:UIControlStateNormal];
        [scrollTopBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [scrollTopBtn addTarget:self action:@selector(scrollTopClick) forControlEvents:UIControlEventTouchUpInside];
        scrollTopBtn.alpha = 0.5;
        scrollTopBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:scrollTopBtn];
        
        
        _autoRefreshBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(_textView.bounds) - 54, CGRectGetMaxY(_textView.frame)-54-64, 44, 44)];
        _autoRefreshBtn.layer.cornerRadius = 22;
        _autoRefreshBtn.layer.masksToBounds = true;
        _autoRefreshBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _autoRefreshBtn.layer.borderWidth = 2.0f;
        [_autoRefreshBtn setTitle:@"A" forState:UIControlStateNormal];
        [_autoRefreshBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_autoRefreshBtn addTarget:self action:@selector(autoRefreshClick) forControlEvents:UIControlEventTouchUpInside];
        _autoRefreshBtn.alpha = 0.5;
        _autoRefreshBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_autoRefreshBtn];

        
        _refreshBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(_textView.bounds) - 54, CGRectGetMaxY(_textView.frame)-54, 44, 44)];
        _refreshBtn.layer.cornerRadius = 22;
        _refreshBtn.layer.masksToBounds = true;
        _refreshBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _refreshBtn.layer.borderWidth = 2.0f;
        [_refreshBtn setTitle:@"R" forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_refreshBtn addTarget:self action:@selector(refreshClick) forControlEvents:UIControlEventTouchUpInside];
        _refreshBtn.alpha = 0.5;
        _refreshBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_refreshBtn];
        
        
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.color = [UIColor whiteColor];
        _indicator.center = _textView.center;
        _indicator.hidesWhenStopped=true;
        [self addSubview:_indicator];
        
        [self onRefresh];
    }
    return self;
}

-(void)scrollTopClick{
    [_textView setContentOffset:CGPointZero animated:YES];
}

-(void)autoRefreshClick{
    _autorefresh = !_autorefresh;
    if (_autorefresh) {
        //切换到自动刷新
        _autoRefreshBtn.backgroundColor = [UIColor greenColor];
        
        if(![[VZLogInspector sharedInstance].observers containsObject:self]){
            [[VZLogInspector sharedInstance] addObserver:self];
        }
        
        [VZLogInspector start];
    }else{
        //手动刷新
        _autoRefreshBtn.backgroundColor = [UIColor clearColor];
        [[VZLogInspector sharedInstance] removeObserver:self];
       
    }
}

-(void)refreshClick{
    [self onRefresh];
}

-(void)searchKeyButtonClick:(UIButton *)btn{
    NSString *s = btn.titleLabel.text;
    self.filterTextField.text = s;
    [_delayTimer invalidate];
    _delayTimer = nil;
    if (!_autorefresh) {
        [self onRefresh];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    [_delayTimer invalidate];
    _delayTimer = nil;
    
    if (!_autorefresh) {
        _delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onRefresh) userInfo:nil repeats:NO];
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_delayTimer invalidate];
    _delayTimer = nil;
    if (!_autorefresh) {
        [self onRefresh];
    }
    return YES;
}

- (void)onRefresh
{
    [_delayTimer invalidate];
    _delayTimer = nil;
    
    [self.indicator startAnimating];
    NSString *searchKey = _filterTextField.text;
   // self.textView.text = @"";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSAttributedString* str = [VZLogInspector logsString:searchKey];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.attStr = str;
            self.textView.attributedText = str;
            [self.indicator stopAnimating];
        });
    });
    
}

//VZLogInspectorDelegate
- (void)logMessage:(VZLogInspectorEntity *)message{
    if (!_autorefresh) {
        return;
    }
    NSAttributedString* aLog = [VZLogInspector formatLog:message searchkey:_filterTextField.text];
    if (aLog) {
        
        NSMutableAttributedString *newLog = [NSMutableAttributedString new];
        [newLog appendAttributedString:aLog];
        if (self.attStr) {
            [newLog appendAttributedString:self.attStr];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(newLog.length>500000) {
                self.attStr = [newLog attributedSubstringFromRange:NSMakeRange(0, 500000)];
            }else{
                self.attStr = newLog;
            }
            self.textView.attributedText = self.attStr;
        });
    }
}

@end
