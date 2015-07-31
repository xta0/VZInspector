//
//  VZInspectorCrashView.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "VZInspectorCrashView.h"
#import "VZCrashInspector.h"

@interface VZInspectorCrashView()

@property(nonatomic,strong) UITextView* crashLogs;
@property(nonatomic,strong) UILabel* textLabel;
@property(nonatomic,strong) UIButton* backBtn;

@end

@implementation VZInspectorCrashView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.textLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, frame.size.width-80, 44)];
        self.textLabel.text = @"CrashLogs";
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:18.0f];
        [self addSubview:self.textLabel];
        
        self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 44, 44)];
        self.backBtn.backgroundColor = [UIColor clearColor];
        [self.backBtn setTitle:@"<-" forState:UIControlStateNormal];
        [self.backBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        self.backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];

        [self.backBtn addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
        [self addSubview:self.backBtn];
        
        
        // Initialization code
        _crashLogs = [[UITextView alloc] initWithFrame:CGRectMake(0, 44 , frame.size.width, frame.size.height-44)];
        _crashLogs.font = [UIFont fontWithName:@"Courier-Bold" size:14];
        _crashLogs.textColor = [UIColor orangeColor];
        _crashLogs.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];;
        _crashLogs.indicatorStyle = 0;
        _crashLogs.editable = NO;
        _crashLogs.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _crashLogs.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        _crashLogs.layer.borderWidth = 2.0f;
        [self addSubview:_crashLogs];
        
    }
    return self;
}

- (void)setPath:(NSString *)path
{
    _path = path;
    
    NSDictionary* logs = [[VZCrashInspector sharedInstance] crashForKey:path];
    
    NSString* header = @"crashes comes from => VZCrashInspector";
    header = [header stringByAppendingString:@"\n--------------------------------------\n"];
    _crashLogs.text = header;
    
    if (logs) {
        
        NSString* date = logs[@"date"];
        _crashLogs.text = [_crashLogs.text stringByAppendingString:[[@"> date :"stringByAppendingString:date] stringByAppendingString:@"\n"]];
        
        NSDictionary* info = logs[@"info"];
        
        //reason
        NSString* reason = info[@"reason"];
        _crashLogs.text = [[[_crashLogs.text stringByAppendingString:@"> reason: "] stringByAppendingString:reason] stringByAppendingString:@"\n"];
        
        //name
        NSString* name = info[@"name"];
        _crashLogs.text = [[[_crashLogs.text stringByAppendingString:@"> name: "] stringByAppendingString:name] stringByAppendingString:@"\n"];
        
        //call stack
        NSArray* callStack  = info[@"callStack"];
        _crashLogs.text = [[[_crashLogs.text stringByAppendingString:@"> callStack: \n"] stringByAppendingString:[NSString stringWithFormat:@"%@",callStack]] stringByAppendingString:@"\n"];
        
    }
}

- (void)onBack
{
    if (self.delegate) {
        [self.delegate onBack];
    }
}


@end
