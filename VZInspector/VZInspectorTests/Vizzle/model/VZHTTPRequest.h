//
//  VZHTTPRequest.h
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>




@protocol VZHTTPRequestInterface;
@protocol VZHTTPRequestDelegate <NSObject>

@required

- (void)requestDidStart:(id<VZHTTPRequestInterface>)request;
- (void)requestDidFinish:(id)JSON;
- (void)requestDidFailWithError:(NSError *)error;

@end

@protocol VZHTTPRequestInterface <NSObject>

@property (nonatomic,strong) NSString* requestURL;
@property (nonatomic,assign) NSTimeInterval timeoutSeconds;
@property (nonatomic,assign) NSStringEncoding stringEncoding;
@property (nonatomic) BOOL isPost;
@property (nonatomic,weak) id<VZHTTPRequestDelegate> delegate;

/**
 *
 *  增加返回的response string/obj
 *
 *  v = VZMV* : 1.2
 */
@property (nonatomic,strong,readonly) NSString* responseString;
@property(nonatomic,strong,readonly) id responseObject;

/**
 *  创建请求的request
 *
 *  @param url
 */
- (void)initRequestWithBaseURL:(NSString*)url;
/**
 *  增加HTTP GET请求参数
 *
 *  @param query 参数
 *  @param key     不同参数类型对应的key
 */
- (void)addQueries:(NSDictionary* )queries;

/**
 *  增加HTTP Header参数
 *
 *  @param param 参数
 *  @param key     不同参数类型对应的key
 */
- (void)addHeaderParams:(NSDictionary* )params;
/**
 *  增加HTTP的POST请求参数
 *
 *   v = VZMV* : 1.2
 *
 *   @param aData POST请求的BODY数据
 *   @param key 对应的key
 */
- (void)addBodyData:(NSDictionary* )aData forKey:(NSString* )key;
/**
 *  发起请求
 */
- (void)load;
/**
 *  取消请求
 */
- (void)cancel;


@end

@interface VZHTTPRequest : NSObject<VZHTTPRequestInterface>

@end
