//
//  VZNetworkResponseView.m
//  VZInspector
//
//  Created by moxin on 15/4/15.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import "VZInspectorNetworkResponseView.h"
#import "VZNetworkTransaction.h"
#import "VZInspectorUtility.h"


@interface VZInspectorNetworkResponseView()

@property(nonatomic,strong) UITextView* responseView;
@property(nonatomic,strong) UILabel* textLabel;
@property(nonatomic,strong) UIButton* backBtn;
@property(nonatomic,strong) UIButton* detailBtn;


@end


@implementation VZInspectorNetworkResponseView

-(id)initWithFrame:(CGRect)frame
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
        
        
        self.detailBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-10-44, 0, 44, 44)];
        self.detailBtn.backgroundColor = [UIColor clearColor];
        [self.detailBtn setTitle:@"->" forState:UIControlStateNormal];
        [self.detailBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [self.detailBtn addTarget:self action:@selector(toDetail) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.detailBtn];
        
        
        // Initialization code
        _responseView = [[UITextView alloc] initWithFrame:CGRectMake(0, 44 , frame.size.width, frame.size.height-44)];
        _responseView.font = [UIFont fontWithName:@"Courier-Bold" size:14];
        _responseView.textColor = [UIColor orangeColor];
        _responseView.backgroundColor = [UIColor clearColor];
        _responseView.indicatorStyle = 0;
        _responseView.editable = NO;
        _responseView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _responseView.backgroundColor = [UIColor clearColor];
        _responseView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        _responseView.layer.borderWidth = 2.0f;
        [self addSubview:_responseView];

        
    }
    return self;
}

- (void)setTransaction:(VZNetworkTransaction *)transaction
{
    _transaction = transaction;

}


+ (NSData *)postBodyDataForTransaction:(VZNetworkTransaction *)transaction
{
    NSData *bodyData = transaction.request.HTTPBody;
    if ([bodyData length] > 0) {
        NSString *contentEncoding = [transaction.request valueForHTTPHeaderField:@"Content-Encoding"];
        if ([contentEncoding rangeOfString:@"deflate" options:NSCaseInsensitiveSearch].length > 0 || [contentEncoding rangeOfString:@"gzip" options:NSCaseInsensitiveSearch].length > 0) {
            bodyData = [VZInspectorUtility inflatedDataFromCompressedData:bodyData];
        }
    }
    return bodyData;
}

@end
