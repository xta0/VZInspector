//
//  VZHTTPModel.m
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZHTTPModel.h"
#import "VZHTTPRequest.h"
#import "VizzleConfig.h"


@interface VZHTTPModel()<VZHTTPRequestDelegate>

@property(nonatomic,strong) id<VZHTTPRequestInterface> request;
@property(nonatomic,strong)NSMutableDictionary* requestParams;

@end

@implementation VZHTTPModel

////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - getters

- (NSMutableDictionary* )requestParams
{
    if (!_requestParams) {
        
        _requestParams =[ NSMutableDictionary new ];
    }
    return _requestParams;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - life cycle

- (void)dealloc {
    
    [self cancel];
    NSLog(@"[%@]--->dealloc", self.class);
}


////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - @override methods

- (BOOL)shouldLoad
{
    if (![super shouldLoad]) {
        return NO;
    }
    else
    {
        NSString *method = [self methodName];
        
        if (!method || method.length == 0) {
            [self requestDidFailWithError:[NSError errorWithDomain:VZErrorDomain code:kMethodNameError userInfo:@{NSLocalizedDescriptionKey:@"Missing Request API"}]];
            return NO;
        }
        else
            return YES;
    }
    
}

- (void)load
{
    [super load];
    [self loadInternal];
}

- (void)cancel
{
    if (self.request)
    {
        [self.request cancel];
        self.request = nil;
    }
    [super cancel];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public methods

- (void)setRequestParam:(id)value forKey:(id <NSCopying>)key;
{
    if (value && key) {
        [self.requestParams setObject:value forKey:key];
    }
}
- (void)removeRequestParamForKey:(id <NSCopying>)key
{
    if (key) {
        [self.requestParams removeObjectForKey:key];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - private methods

- (void)loadInternal {
    
    //2, create request
    NSString* clz = @"";
    if (self.requestType == VZModelDefault) {
        clz = @"VZNSURLRequest";
    }
    else if (self.requestType == VZModelAFNetworking)
    {
        clz = @"VZAFRequest";
    }
    else if (self.requestType == VZModelCustom)
    {
        clz = [self customRequestClassName];
        
        if (!clz ||clz.length == 0) {
            clz = @"VZHTTPRequest";
        }
    }
    else
        clz = @"VZHTTPRequest";
    
    self.request = [NSClassFromString(clz) new];
    self.request.delegate    = self;
    self.request.isPost     = [self isPost];
    
    
    //3, init request
    [self.request initRequestWithBaseURL:[self methodName]];
    
    
    //4, add request data
    [self.request addHeaderParams:[self headerParams]];
    [self.request addQueries:[self dataParams]];
    
    //VZMV* => 1.2:add post body data
    if ([self isPost]) {
        [self.request addBodyData:[self bodyData] forKey:@"file"];
    }
    
    
    //5, start loading
    [self.request load];
    
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - subclassing methods

- (NSDictionary *)dataParams {
    
    return self.requestParams;
}

- (NSDictionary* )headerParams{
    return nil;
}

- (NSString *)methodName {
    return nil;
}

- (BOOL)parseResponse:(id)JSON{
    
    return YES;
}
- (BOOL)useCache {
    return NO;
}

- (BOOL)isPost{
    return NO;
}

- (NSDictionary*)bodyData
{
    return nil;
}

- (NSString* )customRequestClassName
{
    return @"VZHTTPRequest";
}

////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - request callback


- (void)requestDidStart:(id<VZHTTPRequestInterface>)request
{
    NSLog(@"[%@]-->REQUEST_START:%@",self.class,request.requestURL);
    
    [self didStartLoading];
}


- (void)requestDidFinish:(id)JSON
{
    _responseString = self.request.responseString;
    _responseObject = self.request.responseObject;
    
    NSLog(@"[%@]-->REQUEST_FINISH:%@",self.class,JSON);
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        if ([self parseResponse:JSON]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self didFinishLoading];
            });
        
        }
        else
        {
            NSError* err = [NSError errorWithDomain:VZErrorDomain code:kParseJSONError userInfo:@{NSLocalizedDescriptionKey:@"Parse JSON Error"}];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self didFailWithError:err];

            });
        }
    });
}
- (void)requestDidFailWithError:(NSError *)error
{
    NSLog(@"[%@]-->REQUEST_FAILED:%@",self.class,error);
    
    
    _responseString = self.request.responseString;
    _responseObject = self.request.responseObject;
    
    [self didFailWithError:error];
}




@end
