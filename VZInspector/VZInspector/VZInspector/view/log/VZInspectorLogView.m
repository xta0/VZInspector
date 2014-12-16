//
//  VZInspectorLogView.m
//  VZInspector
//
//  Created by moxin.xt on 14-11-26.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZInspectorLogView.h"
#import "VZLogInspector.h"


@interface VZInspectorLogView()

@property(nonatomic,strong) UITextView* requestView;
@property(nonatomic,strong) UITextView* responseView;
@property(nonatomic,strong) NSMutableArray* requestLogs;
@property(nonatomic,strong) NSMutableArray* responseLogs;
@property(nonatomic,assign) NSInteger maxLogs;


@end

@implementation VZInspectorLogView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.requestLogs = [NSMutableArray new];
        self.responseLogs = [NSMutableArray new];
        self.maxLogs = 2;
        
        _requestView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height / 2)];
        _requestView.font = [UIFont fontWithName:@"Courier-Bold" size:10];
        _requestView.textColor = [UIColor orangeColor];
        _requestView.backgroundColor = [UIColor clearColor];
        _requestView.indicatorStyle = 0;
        _requestView.editable = NO;
        _requestView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _requestView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        _requestView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        _requestView.layer.borderWidth = 2.0f;
        [self addSubview:_requestView];
        
        UIButton* requestClearBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-20 - 10, frame.size.height/2 - 20-10 , 20, 20)];
        requestClearBtn.alpha = 0.6;
        requestClearBtn.backgroundColor = [UIColor darkGrayColor];
        requestClearBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        requestClearBtn.layer.borderWidth = 2.0f;
        requestClearBtn.layer.cornerRadius = 10.0f;
        requestClearBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [requestClearBtn setTitle:@"C" forState:UIControlStateNormal];
        [requestClearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [requestClearBtn addTarget:self action:@selector(clearRequestLog:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:requestClearBtn];
        
        
        _responseView = [[UITextView alloc] initWithFrame:CGRectMake(0, frame.size.height/2, frame.size.width, frame.size.height / 2)];
        _responseView.font = [UIFont fontWithName:@"Courier-Bold" size:10];
        _responseView.textColor = [UIColor orangeColor];
        _responseView.backgroundColor = [UIColor clearColor];
        _responseView.indicatorStyle = 0;
        _responseView.editable = NO;
        _responseView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _responseView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        _responseView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
        _responseView.layer.borderWidth = 2.0f;
        [self addSubview:_responseView];
        
        UIButton* responseClearBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-20 - 10, frame.size.height- 20 -10 , 20, 20)];
        responseClearBtn.alpha = 0.6;
        responseClearBtn.backgroundColor = [UIColor darkGrayColor];
        responseClearBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        responseClearBtn.layer.borderWidth = 2.0f;
        responseClearBtn.layer.cornerRadius = 10.0f;
        responseClearBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [responseClearBtn setTitle:@"C" forState:UIControlStateNormal];
        [responseClearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [responseClearBtn addTarget:self action:@selector(clearResponseLog:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:responseClearBtn];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestLog:) name:[VZLogInspector requestLogIdentifier] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseLog:) name:[VZLogInspector responseLogIdentifier] object:nil];
        
        
        [self setText:1];
        [self setText:0];
        
    }
    return self;
}

- (void)requestLog:(NSNotification* )notify
{
    NSString* urlpath = [VZLogInspector requestLogURLPath];
    NSURL* message = notify.userInfo[urlpath];
    
    if ([message isEqual:[NSNull null]]) {
        return;
    }
    else
    {
        NSString* urlString = message.absoluteString;
        
        //utf8 decode
        NSString* decodeURL = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if (decodeURL.length > 0) {
            
            [self.requestLogs addObject:[@"> " stringByAppendingString:decodeURL]];
            if ([self.requestLogs count] > self.maxLogs)
            {
                [self.requestLogs removeObjectAtIndex:0];
            }
            [self setText:1];
        }
    }
    
    
    
}

- (void)responseLog:(NSNotification* )notify
{
    NSString* response = [VZLogInspector responseLogStringPath];
    NSString*  json = notify.userInfo[response];
    
    if (json.length> 0 ) {
        
        NSString* errorpath = [VZLogInspector responseLogErrorPath];
        id error = notify.userInfo[errorpath];
        
        if (error) {
            json = [@"请求失败:" stringByAppendingString:json];
        }
        
//        NSData* data =  [json dataUsingEncoding:NSUTF8StringEncoding];
//        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        [self.responseLogs addObject:[@"> " stringByAppendingString:[NSString stringWithFormat:@"%@",json]]];
        if ([self.responseLogs count] > self.maxLogs)
        {
            [self.responseLogs removeObjectAtIndex:0];
        }
        [self setText:0];
    }
}



- (void)setText:(BOOL)request
{
    //requst log:
    if (request) {
        
        NSString* info = @"request comes from => VZHTTPRequest";
        info = [info stringByAppendingString:@"\n--------------------------------------\n"];
        info = [info stringByAppendingString:[[self.requestLogs arrayByAddingObject:@">"] componentsJoinedByString:@"\n"]];
        
        _requestView.text = info;
        //[_requestView scrollRangeToVisible:NSMakeRange(_requestView.text.length, 0)];
    }
    else
    {
        //response log:
        NSString* info = @"response comes from => VZHTTPRequest";
        info = [info stringByAppendingString:@"\n--------------------------------------\n"];
        info = [info stringByAppendingString:[[self.responseLogs arrayByAddingObject:@">"] componentsJoinedByString:@"\n"]];
        
        _responseView.text = info;
        //[_responseView scrollRangeToVisible:NSMakeRange(_responseView.text.length, 0)];
        
    }
    
}

- (void)clearRequestLog:(id)sender
{
    [self.requestLogs removeAllObjects];
    
    NSString* info = @"request comes from => VZHTTPRequest";
    info = [info stringByAppendingString:@"\n--------------------------------------\n"];
    info = [info stringByAppendingString:[[self.requestLogs arrayByAddingObject:@">"] componentsJoinedByString:@"\n"]];
    
    _requestView.text = info;
}

- (void)clearResponseLog:(id)sender
{
    [self.responseLogs removeAllObjects];
    
    //response log:
    NSString* info = @"response comes from => VZHTTPRequest";
    info = [info stringByAppendingString:@"\n--------------------------------------\n"];
    info = [info stringByAppendingString:[[self.responseLogs arrayByAddingObject:@">"] componentsJoinedByString:@"\n"]];
    _responseView.text = info;
}


@end
