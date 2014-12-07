//
//  VZHTTPRequest.m
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import "VZHTTPRequest.h"


@implementation VZHTTPRequest

@synthesize delegate = _delegate;
@synthesize isPost = _isPost;
@synthesize requestURL = _requestURL;
@synthesize stringEncoding = _stringEncoding;
@synthesize timeoutSeconds = _timeoutSeconds;
@synthesize responseObject = _responseObject;
@synthesize responseString = _responseString;

- (void)initRequestWithBaseURL:(NSString*)url
{
    
}

- (void)addHeaderParams:(NSDictionary *)params
{

}

- (void)addQueries:(NSDictionary *)queries
{
    
}
- (void)addBodyData:(NSDictionary *)aData forKey:(NSString *)key
{
    
}
- (void)load
{
    
}
- (void)cancel
{
    
}


@end
