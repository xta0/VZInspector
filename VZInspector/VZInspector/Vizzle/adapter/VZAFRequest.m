//
//  VZAFRequest.m
//  VizzleListExample
//
//  Created by moxin.xt on 14-9-29.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZAFRequest.h"
#import "VizzleConfig.h"

#ifdef _AFNETWORKING_
#import "AFNetworking.h"
@interface VZAFClient : AFHTTPSessionManager

+ (instancetype) sharedClient;

@end

@implementation VZAFClient

+ (instancetype) sharedClient
{
    static VZAFClient* client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[VZAFClient alloc]initWithBaseURL:nil];
    });
    return client;
}


@end
#endif


@interface VZAFRequest()

#ifdef _AFNETWORKING_
@property(nonatomic,strong) VZAFClient* afClient;
#endif

@property(nonatomic,strong) NSString* url;
@property(nonatomic,copy) NSDictionary* queries;
#ifdef _AFNETWORKING_
@property(nonatomic,strong) NSURLSessionTask* currentTask;
#endif

@end

@implementation VZAFRequest

@synthesize isPost = _isPost;
@synthesize delegate = _delegate;
@synthesize requestURL     = _requestURL;
@synthesize stringEncoding = _stringEncoding;
@synthesize timeoutSeconds = _timeoutSeconds;
@synthesize responseObject = _responseObject;
@synthesize responseString = _responseString;
@synthesize responseError  = _responseError;

- (void)initRequestWithBaseURL:(NSString*)url
{
#ifdef _AFNETWORKING_
    
    NSParameterAssert(url);
    
    if (url.length == 0) {
        [self requestDidFailWithError:[NSError errorWithDomain:VZErrorDomain code:kMethodNameError userInfo:@{NSLocalizedDescriptionKey : @"kMethodNameError"}]];
        return;
    }
    
    self.timeoutSeconds = 10.0f;
    self.stringEncoding = NSUTF8StringEncoding;
    self.url = url;

    self.afClient = [VZAFClient sharedClient];
    self.afClient.session.configuration.timeoutIntervalForRequest = self.timeoutSeconds;

#else
    
     [self requestDidFailWithError:[NSError errorWithDomain:VZErrorDomain code:kAFNetworkingError userInfo:@{NSLocalizedDescriptionKey : @"Did not find AFNetworking!"}]];
    
#endif
    
}

- (void)addHeaderParams:(NSDictionary *)params
{
#ifdef _AFNETWORKING_
    self.afClient.session.configuration.HTTPAdditionalHeaders = params;
#endif
}

- (void)addQueries:(NSDictionary *)queries
{
#ifdef _AFNETWORKING_
    self.queries = queries;
#endif

}
- (void)addBodyData:(NSDictionary *)aData forKey:(NSString *)key
{
    
}
- (void)load
{
    
#ifdef _AFNETWORKING_

    
    NSMutableURLRequest *request = [self.afClient.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:self.url relativeToURL:nil] absoluteString] parameters:self.queries error:nil];
    
    self.requestURL = request.URL.absoluteString;
    
    [self requestDidStart];
    
    __weak typeof(self) weakSelf = self;
    self.currentTask = [self.afClient GET:self.url parameters:self.queries success:^(NSURLSessionDataTask *task, id responseObject) {
        
        __strong typeof (weakSelf) strongSelf = weakSelf;
        
        if (strongSelf) {
            strongSelf -> _responseObject = responseObject;
            strongSelf -> _responseString = [NSString stringWithFormat:@"%@",responseObject];
            
        }
        
        [weakSelf requestDidFinish:responseObject];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        weakSelf.responseError = error;
        [weakSelf requestDidFailWithError:error];
        
    }];
#endif
    
}
- (void)cancel
{
#ifdef _AFNETWORKING_
    [self.currentTask cancel];
#endif
}


- (void)requestDidStart
{
    
    if ([self.delegate respondsToSelector:@selector(requestDidStart:)]) {
        [self.delegate requestDidStart:self];
    }

}

- (void)requestDidFinish:(id)JSON
{
    if ([self.delegate respondsToSelector:@selector(requestDidFinish:)]) {
        [self.delegate requestDidFinish:JSON];
    }
}

- (void)requestDidFailWithError:(NSError* )error
{
    if ([self.delegate respondsToSelector:@selector(requestDidFailWithError:)]) {
        [self.delegate requestDidFailWithError:error];
    }

}



@end
