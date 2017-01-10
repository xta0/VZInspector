//
//  VZNetworkObserver.m
//  Derived from:
//
//  FLEXNetworkObserver
//  Flipboard
//
//  Created by Ryan Olson
//  Copyright (c) 2015 Flipboard. All rights reserved.
//

#import "VZNetworkObserver.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <dispatch/queue.h>
#import "VZNetworkRecorder.h"

NSString *const kVZNetworkObserverEnabledStateChangedNotification = @"kVZNetworkObserverEnabledStateChangedNotification";
static NSString *const kVZNetworkObserverEnableOnLaunchDefaultsKey = @"com.VZ.VZNetworkObserver.enableOnLaunch";

typedef void (^NSURLSessionAsyncCompletion)(id fileURLOrData, NSURLResponse *response, NSError *error);

#define kVZNetowrkIgnore if ([self shouldIgnoreDelegate:delegate]) { return; }


@interface VZNetworkObserverInternalRequestState : NSObject

@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, strong) NSMutableData *dataAccumulator;

@end

@implementation VZNetworkObserverInternalRequestState

@end

//NSString *const kVZNetworkObserverEnabledStateChangedNotification = @"kVZNetworkObserverEnabledStateChangedNotification";
//static NSString *const kVZNetworkObserverEnableOnLaunchDefaultsKey = @"com.VZ.VZNetworkObserver.enableOnLaunch";

@interface VZNetworkObserver(NSURLConnection)


- (void)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response delegate:(id <NSURLConnectionDelegate>)delegate;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response delegate:(id <NSURLConnectionDelegate>)delegate;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data delegate:(id <NSURLConnectionDelegate>)delegate;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection delegate:(id <NSURLConnectionDelegate>)delegate;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error delegate:(id <NSURLConnectionDelegate>)delegate;

- (void)connectionWillCancel:(NSURLConnection *)connection;

@end


@interface VZNetworkObserver (NSURLSessionTaskHelpers)

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler delegate:(id <NSURLSessionDelegate>)delegate;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler delegate:(id <NSURLSessionDelegate>)delegate;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data delegate:(id <NSURLSessionDelegate>)delegate;
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask delegate:(id <NSURLSessionDelegate>)delegate;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error delegate:(id <NSURLSessionDelegate>)delegate;
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite delegate:(id <NSURLSessionDelegate>)delegate;
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location data:(NSData *)data delegate:(id <NSURLSessionDelegate>)delegate;

- (void)URLSessionTaskWillResume:(NSURLSessionTask *)task;

@end

@interface VZNetworkObserver ()

@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, strong) NSMutableDictionary *requestStatesForRequestIDs;
//@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSSet *ignoreDelegateClasses;

@end

@implementation VZNetworkObserver
{
    dispatch_queue_t _queue;
}

#pragma mark - Public Methods

+ (void)setEnabled:(BOOL)enabled
{
    if (enabled) {
        // Inject if needed. This injection is protected with a dispatch_once, so we're ok calling it multiple times.
        // By doing the injection lazily, we keep the impact of the tool lower when this feature isn't enabled.
        [self injectIntoAllNSURLConnectionDelegateClasses];
    }
    [[self sharedObserver] setEnabled:enabled];
}

+ (BOOL)isEnabled
{
    return [[self sharedObserver] isEnabled];
}

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled != enabled) {
        _enabled = enabled;
        [[NSNotificationCenter defaultCenter] postNotificationName:kVZNetworkObserverEnabledStateChangedNotification object:self];
    }
}

+ (void)setShouldEnableOnLaunch:(BOOL)shouldEnableOnLaunch
{
    [[NSUserDefaults standardUserDefaults] setBool:shouldEnableOnLaunch forKey:kVZNetworkObserverEnableOnLaunchDefaultsKey];
}

+ (BOOL)shouldEnableOnLaunch
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kVZNetworkObserverEnableOnLaunchDefaultsKey] boolValue];
}

+ (void)load
{
    // We don't want to do the swizzling from +load because not all the classes may be loaded at this point.
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self shouldEnableOnLaunch]) {
            [self setEnabled:YES];
        }
    });
}

+ (void)setIgnoreDelegateClasses:(NSSet *)classes
{
    [[self sharedObserver] setIgnoreDelegateClasses:classes];
}

#pragma mark - Statics

+ (instancetype)sharedObserver
{
    static VZNetworkObserver *sharedObserver = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObserver = [[[self class] alloc] init];
    });
    return sharedObserver;
}

+ (NSString *)nextRequestID
{
    return [[NSUUID UUID] UUIDString];
}

#pragma mark Delegate Injection Convenience Methods

+ (SEL)swizzledSelectorForSelector:(SEL)selector
{
    return NSSelectorFromString([NSString stringWithFormat:@"_VZ_swizzle_%x_%@", arc4random(), NSStringFromSelector(selector)]);
}

/// All swizzled delegate methods should make use of this guard.
/// This will prevent duplicated sniffing when the original implementation calls up to a superclass implementation which we've also swizzled.
/// The superclass implementation (and implementations in classes above that) will be executed without inteference if called from the original implementation.
+ (void)sniffWithoutDuplicationForObject:(NSObject *)object selector:(SEL)selector sniffingBlock:(void (^)(void))sniffingBlock originalImplementationBlock:(void (^)(void))originalImplementationBlock
{
    if (!object) {
        return;
    }
    const void *key = selector;
    
    // Don't run the sniffing block if we're inside a nested call
    if (!objc_getAssociatedObject(object, key)) {
        sniffingBlock();
    }
    
    // Mark that we're calling through to the original so we can detect nested calls
    objc_setAssociatedObject(object, key, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    originalImplementationBlock();
    objc_setAssociatedObject(object, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)instanceRespondsButDoesNotImplementSelector:(SEL)selector class:(Class)cls
{
    if ([cls instancesRespondToSelector:selector]) {
        unsigned int numMethods = 0;
        Method *methods = class_copyMethodList(cls, &numMethods);
        
        BOOL implementsSelector = NO;
        for (int index = 0; index < numMethods; index++) {
            SEL methodSelector = method_getName(methods[index]);
            if (selector == methodSelector) {
                implementsSelector = YES;
                break;
            }
        }
        
        free(methods);
        
        if (!implementsSelector) {
            return YES;
        }
    }
    
    return NO;
}

+ (void)replaceImplementationOfKnownSelector:(SEL)originalSelector onClass:(Class)class withBlock:(id)block swizzledSelector:(SEL)swizzledSelector
{
    // This method is only intended for swizzling methods that are know to exist on the class.
    // Bail if that isn't the case.
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    if (!originalMethod) {
        return;
    }
    
    IMP implementation = imp_implementationWithBlock(block);
    class_addMethod(class, swizzledSelector, implementation, method_getTypeEncoding(originalMethod));
    Method newMethod = class_getInstanceMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, newMethod);
}

+ (void)replaceImplementationOfSelector:(SEL)selector withSelector:(SEL)swizzledSelector forClass:(Class)cls withMethodDescription:(struct objc_method_description)methodDescription implementationBlock:(id)implementationBlock undefinedBlock:(id)undefinedBlock
{
    if ([self instanceRespondsButDoesNotImplementSelector:selector class:cls]) {
        return;
    }
    
    IMP implementation = imp_implementationWithBlock((id)([cls instancesRespondToSelector:selector] ? implementationBlock : undefinedBlock));
    
    Method oldMethod = class_getInstanceMethod(cls, selector);
    if (oldMethod) {
        class_addMethod(cls, swizzledSelector, implementation, methodDescription.types);
        
        Method newMethod = class_getInstanceMethod(cls, swizzledSelector);
        
        method_exchangeImplementations(oldMethod, newMethod);
    } else {
        class_addMethod(cls, selector, implementation, methodDescription.types);
    }
}

#pragma mark - Delegate Injection

+ (void)injectIntoAllNSURLConnectionDelegateClasses
{
    // Only allow swizzling once.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Swizzle any classes that implement one of these selectors.
        const SEL selectors[] = {
            @selector(connectionDidFinishLoading:),
            @selector(connection:willSendRequest:redirectResponse:),
            @selector(connection:didReceiveResponse:),
            @selector(connection:didReceiveData:),
            @selector(connection:didFailWithError:),
            @selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:),
            @selector(URLSession:dataTask:didReceiveData:),
            @selector(URLSession:dataTask:didReceiveResponse:completionHandler:),
            @selector(URLSession:task:didCompleteWithError:),
            @selector(URLSession:dataTask:didBecomeDownloadTask:delegate:),
            @selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:),
            @selector(URLSession:downloadTask:didFinishDownloadingToURL:)
        };
        
        const int numSelectors = sizeof(selectors) / sizeof(SEL);
        
        Class *classes = NULL;
        int numClasses = objc_getClassList(NULL, 0);
        
        if (numClasses > 0) {
            classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            for (NSInteger classIndex = 0; classIndex < numClasses; ++classIndex) {
                Class class = classes[classIndex];
                
                if (class == [VZNetworkObserver class]) {
                    continue;
                }
                
                // Use the runtime API rather than the methods on NSObject to avoid sending messages to
                // classes we're not interested in swizzling. Otherwise we hit +initialize on all classes.
                // NOTE: calling class_getInstanceMethod() DOES send +initialize to the class. That's why we iterate through the method list.
                unsigned int methodCount = 0;
                Method *methods = class_copyMethodList(class, &methodCount);
                BOOL matchingSelectorFound = NO;
                for (unsigned int methodIndex = 0; methodIndex < methodCount; methodIndex++) {
                    for (int selectorIndex = 0; selectorIndex < numSelectors; ++selectorIndex) {
                        if (method_getName(methods[methodIndex]) == selectors[selectorIndex]) {
                            [self injectIntoDelegateClass:class];
                            matchingSelectorFound = YES;
                            break;
                        }
                    }
                    if (matchingSelectorFound) {
                        break;
                    }
                }
                free(methods);
            }
            
            free(classes);
        }
        
        [self injectIntoNSURLConnectionCancel];
        [self injectIntoNSURLSessionTaskResume];
        
        [self injectIntoNSURLConnectionAsynchronousClassMethod];
        [self injectIntoNSURLConnectionSynchronousClassMethod];
        
        [self injectIntoNSURLSessionAsyncDataAndDownloadTaskMethods];
        [self injectIntoNSURLSessionAsyncUploadTaskMethods];
    });
}

+ (void)injectIntoDelegateClass:(Class)cls
{
    // Connections
    [self injectWillSendRequestIntoDelegateClass:cls];
    [self injectDidReceiveDataIntoDelegateClass:cls];
    [self injectDidReceiveResponseIntoDelegateClass:cls];
    [self injectDidFinishLoadingIntoDelegateClass:cls];
    [self injectDidFailWithErrorIntoDelegateClass:cls];
    
    // Sessions
    [self injectTaskWillPerformHTTPRedirectionIntoDelegateClass:cls];
    [self injectTaskDidReceiveDataIntoDelegateClass:cls];
    [self injectTaskDidReceiveResponseIntoDelegateClass:cls];
    [self injectTaskDidCompleteWithErrorIntoDelegateClass:cls];
    [self injectRespondsToSelectorIntoDelegateClass:cls];
    
    // Data tasks
    [self injectDataTaskDidBecomeDownloadTaskIntoDelegateClass:cls];
    
    // Download tasks
    [self injectDownloadTaskDidWriteDataIntoDelegateClass:cls];
    [self injectDownloadTaskDidFinishDownloadingIntoDelegateClass:cls];
}

+ (void)injectIntoNSURLConnectionCancel
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [NSURLConnection class];
        SEL selector = @selector(cancel);
        SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
        Method originalCancel = class_getInstanceMethod(class, selector);
        
        void (^swizzleBlock)(NSURLConnection *) = ^(NSURLConnection *slf) {
            [[VZNetworkObserver sharedObserver] connectionWillCancel:slf];
            ((void(*)(id, SEL))objc_msgSend)(slf, swizzledSelector);
        };
        
        IMP implementation = imp_implementationWithBlock(swizzleBlock);
        class_addMethod(class, swizzledSelector, implementation, method_getTypeEncoding(originalCancel));
        Method newCancel = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalCancel, newCancel);
    });
}

+ (void)injectIntoNSURLSessionTaskResume
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [NSURLSessionTask class];
        SEL selector = @selector(resume);
        SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
        
        if ([self instanceRespondsButDoesNotImplementSelector:selector class:class]) {
            // Dummy NSURLSessionTask to get the actual class, needed for iOS 7 (__NSCFURLSessionTask)
            class = [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"about:blank"]] superclass];
        }
        
        Method originalResume = class_getInstanceMethod(class, selector);
        
        void (^swizzleBlock)(NSURLSessionTask *) = ^(NSURLSessionTask *slf) {
            [[VZNetworkObserver sharedObserver] URLSessionTaskWillResume:slf];
            ((void(*)(id, SEL))objc_msgSend)(slf, swizzledSelector);
        };
        
        IMP implementation = imp_implementationWithBlock(swizzleBlock);
        class_addMethod(class, swizzledSelector, implementation, method_getTypeEncoding(originalResume));
        Method newResume = class_getInstanceMethod(class, swizzledSelector);
        method_exchangeImplementations(originalResume, newResume);
    });
}

+ (void)injectIntoNSURLConnectionAsynchronousClassMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getMetaClass(class_getName([NSURLConnection class]));
        SEL selector = @selector(sendAsynchronousRequest:queue:completionHandler:);
        SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
        
        typedef void (^NSURLConnectionAsyncCompletion)(NSURLResponse* response, NSData* data, NSError* connectionError);
        
        void (^asyncSwizzleBlock)(Class, NSURLRequest *, NSOperationQueue *, NSURLConnectionAsyncCompletion) = ^(Class slf, NSURLRequest *request, NSOperationQueue *queue, NSURLConnectionAsyncCompletion completion)
        
            {
                if ([VZNetworkObserver isEnabled])
                {
                    NSString *requestID = [self nextRequestID];
                    
                    [[VZNetworkRecorder defaultRecorder] recordRequestWillBeSentWithRequestID:requestID request:request redirectResponse:nil];
                    
                    NSString *mechanism = [self mechansimFromClassMethod:selector onClass:class];
                    
                    [[VZNetworkRecorder defaultRecorder] recordMechanism:mechanism forRequestID:requestID];
                    
                    NSURLConnectionAsyncCompletion completionWrapper = ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    
                        [[VZNetworkRecorder defaultRecorder] recordResponseReceivedWithRequestID:requestID response:response];
                        [[VZNetworkRecorder defaultRecorder] recordDataReceivedWithRequestID:requestID dataLength:[data length]];
                        
                        if (connectionError) {
                            [[VZNetworkRecorder defaultRecorder] recordLoadingFailedWithRequestID:requestID error:connectionError];
                        } else {
                            [[VZNetworkRecorder defaultRecorder] recordLoadingFinishedWithRequestID:requestID responseBody:data];
                        }
                        
                        // Call through to the original completion handler
                        if (completion) {
                            completion(response, data, connectionError);
                        }
                    };
                    
                    ((void(*)(id, SEL, id, id, id))objc_msgSend)(slf, swizzledSelector, request, queue, completionWrapper);
                }
                else
                {
                    ((void(*)(id, SEL, id, id, id))objc_msgSend)(slf, swizzledSelector, request, queue, completion);
                }
            };
        
        [self replaceImplementationOfKnownSelector:selector onClass:class withBlock:asyncSwizzleBlock swizzledSelector:swizzledSelector];
    });//end of dispatch_once
}

+ (void)injectIntoNSURLConnectionSynchronousClassMethod
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getMetaClass(class_getName([NSURLConnection class]));
        SEL selector = @selector(sendSynchronousRequest:returningResponse:error:);
        SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
        
        NSData *(^syncSwizzleBlock)(Class, NSURLRequest *, NSURLResponse **, NSError **) = ^NSData *(Class slf, NSURLRequest *request, NSURLResponse **response, NSError **error) {
            NSData *data = nil;
            
            if ([VZNetworkObserver isEnabled])
            {
                NSString *requestID = [self nextRequestID];
                [[VZNetworkRecorder defaultRecorder] recordRequestWillBeSentWithRequestID:requestID request:request redirectResponse:nil];
                NSString *mechanism = [self mechansimFromClassMethod:selector onClass:class];
                [[VZNetworkRecorder defaultRecorder] recordMechanism:mechanism forRequestID:requestID];
                NSError *temporaryError = nil;
                NSURLResponse *temporaryResponse = nil;
                data = ((id(*)(id, SEL, id, NSURLResponse **, NSError **))objc_msgSend)(slf, swizzledSelector, request, &temporaryResponse, &temporaryError);
                [[VZNetworkRecorder defaultRecorder] recordResponseReceivedWithRequestID:requestID response:temporaryResponse];
                [[VZNetworkRecorder defaultRecorder] recordDataReceivedWithRequestID:requestID dataLength:[data length]];
                if (temporaryError) {
                    [[VZNetworkRecorder defaultRecorder] recordLoadingFailedWithRequestID:requestID error:temporaryError];
                } else {
                    [[VZNetworkRecorder defaultRecorder] recordLoadingFinishedWithRequestID:requestID responseBody:data];
                }
                if (error) {
                    *error = temporaryError;
                }
                if (response) {
                    *response = temporaryResponse;
                }
            } else {
                data = ((id(*)(id, SEL, id, NSURLResponse **, NSError **))objc_msgSend)(slf, swizzledSelector, request, response, error);
            }
            
            return data;
        };
        
        [self replaceImplementationOfKnownSelector:selector onClass:class withBlock:syncSwizzleBlock swizzledSelector:swizzledSelector];
    });
}

+ (void)injectIntoNSURLSessionAsyncDataAndDownloadTaskMethods
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [NSURLSession class];
        
        // The method signatures here are close enough that we can use the same logic to inject into all of them.
        const SEL selectors[] = {
            @selector(dataTaskWithHTTPGetRequest:completionHandler:),
            @selector(dataTaskWithRequest:completionHandler:),
            @selector(dataTaskWithURL:completionHandler:),
            @selector(downloadTaskWithRequest:completionHandler:),
            @selector(downloadTaskWithResumeData:completionHandler:),
            @selector(downloadTaskWithURL:completionHandler:)
        };
        
        const int numSelectors = sizeof(selectors) / sizeof(SEL);
        
        for (int selectorIndex = 0; selectorIndex < numSelectors; selectorIndex++) {
            SEL selector = selectors[selectorIndex];
            SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
            
            if ([self instanceRespondsButDoesNotImplementSelector:selector class:class]) {
                // iOS 7 does not implement these methods on NSURLSession. We actually want to
                // swizzle __NSCFURLSession, which we can get from the class of the shared session
                class = [[NSURLSession sharedSession] class];
            }
            
            NSURLSessionTask *(^asyncDataOrDownloadSwizzleBlock)(Class, id, NSURLSessionAsyncCompletion) = ^NSURLSessionTask *(Class slf, id argument, NSURLSessionAsyncCompletion completion) {
               
                NSURLSessionTask *task = nil;
                
                //监控开启
                // ⚠️completion为空时不应该做hook，应该走原来的逻辑，如果用了wrapper completion，原来的task的delegate就不会回调了
                if ([VZNetworkObserver isEnabled] && completion) {
                
                    //获取本次request对应的id
                    NSString *requestID = [self nextRequestID];
                    
                    //获取方法名
                    NSString *mechanism = [self mechansimFromClassMethod:selector onClass:class];
      
                    //回调callback
                    NSURLSessionAsyncCompletion completionWrapper = [self asyncCompletionWrapperForRequestID:requestID mechanism:mechanism completion:completion];
                    
                    task = ((id(*)(id, SEL, id, id))objc_msgSend)(slf, swizzledSelector, argument, completionWrapper);
                    
                    //记录这次请求
                    [[VZNetworkRecorder defaultRecorder] recordRequestWillBeSentWithRequestID:requestID request:task.currentRequest redirectResponse:nil];
                    
                    [self setRequestID:requestID forConnectionOrTask:task];
                
                }
                else
                {
                    task = ((id(*)(id, SEL, id, id))objc_msgSend)(slf, swizzledSelector, argument, completion);

                }
                return task;
            };
            
            [self replaceImplementationOfKnownSelector:selector onClass:class withBlock:asyncDataOrDownloadSwizzleBlock swizzledSelector:swizzledSelector];
        }
    });
}

+ (void)injectIntoNSURLSessionAsyncUploadTaskMethods
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [NSURLSession class];
        
        // The method signatures here are close enough that we can use the same logic to inject into both of them.
        // Note that they have 3 arguments, so we can't easily combine with the data and download method above.
        const SEL selectors[] = {
            @selector(uploadTaskWithRequest:fromData:completionHandler:),
            @selector(uploadTaskWithRequest:fromFile:completionHandler:)
        };
        
        const int numSelectors = sizeof(selectors) / sizeof(SEL);
        
        for (int selectorIndex = 0; selectorIndex < numSelectors; selectorIndex++) {
            SEL selector = selectors[selectorIndex];
            SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
            
            if ([self instanceRespondsButDoesNotImplementSelector:selector class:class]) {
                // iOS 7 does not implement these methods on NSURLSession. We actually want to
                // swizzle __NSCFURLSession, which we can get from the class of the shared session
                class = [[NSURLSession sharedSession] class];
            }
            
            NSURLSessionUploadTask *(^asyncUploadTaskSwizzleBlock)(Class, NSURLRequest *, id, NSURLSessionAsyncCompletion) = ^NSURLSessionUploadTask *(Class slf, NSURLRequest *request, id argument, NSURLSessionAsyncCompletion completion) {
                NSURLSessionUploadTask *task = nil;
                if ([VZNetworkObserver isEnabled]) {
                    NSString *requestID = [self nextRequestID];
                    NSString *mechanism = [self mechansimFromClassMethod:selector onClass:class];
                    NSURLSessionAsyncCompletion completionWrapper = [self asyncCompletionWrapperForRequestID:requestID mechanism:mechanism completion:completion];
                    task = ((id(*)(id, SEL, id, id, id))objc_msgSend)(slf, swizzledSelector, request, argument, completionWrapper);
                    
                    //记录这次请求
                    [[VZNetworkRecorder defaultRecorder] recordRequestWillBeSentWithRequestID:requestID request:task.currentRequest redirectResponse:nil];
                    [self setRequestID:requestID forConnectionOrTask:task];
                } else {
                    task = ((id(*)(id, SEL, id, id, id))objc_msgSend)(slf, swizzledSelector, request, argument, completion);
                }
                return task;
            };
            
            [self replaceImplementationOfKnownSelector:selector onClass:class withBlock:asyncUploadTaskSwizzleBlock swizzledSelector:swizzledSelector];
        }
    });
}

+ (NSString *)mechansimFromClassMethod:(SEL)selector onClass:(Class)class
{
    return [NSString stringWithFormat:@"+[%@ %@]", NSStringFromClass(class), NSStringFromSelector(selector)];
}

+ (NSURLSessionAsyncCompletion)asyncCompletionWrapperForRequestID:(NSString *)requestID mechanism:(NSString *)mechanism completion:(NSURLSessionAsyncCompletion)completion
{
    NSURLSessionAsyncCompletion completionWrapper = ^(id fileURLOrData, NSURLResponse *response, NSError *error) {
        [[VZNetworkRecorder defaultRecorder] recordMechanism:mechanism forRequestID:requestID];
        [[VZNetworkRecorder defaultRecorder] recordResponseReceivedWithRequestID:requestID response:response];
        NSData *data = nil;
        if ([fileURLOrData isKindOfClass:[NSURL class]]) {
            data = [NSData dataWithContentsOfURL:fileURLOrData];
        } else if ([fileURLOrData isKindOfClass:[NSData class]]) {
            data = fileURLOrData;
        }
        [[VZNetworkRecorder defaultRecorder] recordDataReceivedWithRequestID:requestID dataLength:[data length]];
        if (error) {
            [[VZNetworkRecorder defaultRecorder] recordLoadingFailedWithRequestID:requestID error:error];
        } else {
            [[VZNetworkRecorder defaultRecorder] recordLoadingFinishedWithRequestID:requestID responseBody:data];
        }
        
        // Call through to the original completion handler
        if (completion) {
            completion(fileURLOrData, response, error);
        }
    };
    return completionWrapper;
}

+ (void)injectWillSendRequestIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(connection:willSendRequest:redirectResponse:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLConnectionDataDelegate);
    if (!protocol) {
        protocol = @protocol(NSURLConnectionDelegate);
    }
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef NSURLRequest *(^NSURLConnectionWillSendRequestBlock)(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLRequest *request, NSURLResponse *response);
    
    NSURLConnectionWillSendRequestBlock undefinedBlock = ^NSURLRequest *(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLRequest *request, NSURLResponse *response) {
        [[VZNetworkObserver sharedObserver] connection:connection willSendRequest:request redirectResponse:response delegate:slf];
        return request;
    };
    
    NSURLConnectionWillSendRequestBlock implementationBlock = ^NSURLRequest *(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLRequest *request, NSURLResponse *response) {
        __block NSURLRequest *returnValue = nil;
        [self sniffWithoutDuplicationForObject:connection selector:selector sniffingBlock:^{
            undefinedBlock(slf, connection, request, response);
        } originalImplementationBlock:^{
            returnValue = ((id(*)(id, SEL, id, id, id))objc_msgSend)(slf, swizzledSelector, connection, request, response);
        }];
        return returnValue;
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
}

+ (void)injectDidReceiveResponseIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(connection:didReceiveResponse:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLConnectionDataDelegate);
    if (!protocol) {
        protocol = @protocol(NSURLConnectionDelegate);
    }
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^NSURLConnectionDidReceiveResponseBlock)(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLResponse *response);
    
    NSURLConnectionDidReceiveResponseBlock undefinedBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLResponse *response) {
        [[VZNetworkObserver sharedObserver] connection:connection didReceiveResponse:response delegate:slf];
    };
    
    NSURLConnectionDidReceiveResponseBlock implementationBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLResponse *response) {
        [self sniffWithoutDuplicationForObject:connection selector:selector sniffingBlock:^{
            undefinedBlock(slf, connection, response);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id))objc_msgSend)(slf, swizzledSelector, connection, response);
        }];
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
}

+ (void)injectDidReceiveDataIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(connection:didReceiveData:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLConnectionDataDelegate);
    if (!protocol) {
        protocol = @protocol(NSURLConnectionDelegate);
    }
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^NSURLConnectionDidReceiveDataBlock)(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSData *data);
    
    NSURLConnectionDidReceiveDataBlock undefinedBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSData *data) {
        [[VZNetworkObserver sharedObserver] connection:connection didReceiveData:data delegate:slf];
    };
    
    NSURLConnectionDidReceiveDataBlock implementationBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSData *data) {
        [self sniffWithoutDuplicationForObject:connection selector:selector sniffingBlock:^{
            undefinedBlock(slf, connection, data);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id))objc_msgSend)(slf, swizzledSelector, connection, data);
        }];
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
}

+ (void)injectDidFinishLoadingIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(connectionDidFinishLoading:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLConnectionDataDelegate);
    if (!protocol) {
        protocol = @protocol(NSURLConnectionDelegate);
    }
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^NSURLConnectionDidFinishLoadingBlock)(id <NSURLConnectionDelegate> slf, NSURLConnection *connection);
    
    NSURLConnectionDidFinishLoadingBlock undefinedBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection) {
        [[VZNetworkObserver sharedObserver] connectionDidFinishLoading:connection delegate:slf];
    };
    
    NSURLConnectionDidFinishLoadingBlock implementationBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection) {
        [self sniffWithoutDuplicationForObject:connection selector:selector sniffingBlock:^{
            undefinedBlock(slf, connection);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id))objc_msgSend)(slf, swizzledSelector, connection);
        }];
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
}

+ (void)injectDidFailWithErrorIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(connection:didFailWithError:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLConnectionDelegate);
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^NSURLConnectionDidFailWithErrorBlock)(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSError *error);
    
    NSURLConnectionDidFailWithErrorBlock undefinedBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSError *error) {
        [[VZNetworkObserver sharedObserver] connection:connection didFailWithError:error delegate:slf];
    };
    
    NSURLConnectionDidFailWithErrorBlock implementationBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSError *error) {
        [self sniffWithoutDuplicationForObject:connection selector:selector sniffingBlock:^{
            undefinedBlock(slf, connection, error);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id))objc_msgSend)(slf, swizzledSelector, connection, error);
        }];
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
}

+ (void)injectTaskWillPerformHTTPRedirectionIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLSessionTaskDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^NSURLSessionWillPerformHTTPRedirectionBlock)(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionTask *task, NSHTTPURLResponse *response, NSURLRequest *newRequest, void(^completionHandler)(NSURLRequest *));
    
    NSURLSessionWillPerformHTTPRedirectionBlock undefinedBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionTask *task, NSHTTPURLResponse *response, NSURLRequest *newRequest, void(^completionHandler)(NSURLRequest *)) {
        [[VZNetworkObserver sharedObserver] URLSession:session task:task willPerformHTTPRedirection:response newRequest:newRequest completionHandler:completionHandler delegate:slf];
    };
    
    NSURLSessionWillPerformHTTPRedirectionBlock implementationBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionTask *task, NSHTTPURLResponse *response, NSURLRequest *newRequest, void(^completionHandler)(NSURLRequest *)) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            undefinedBlock(slf, session, task, response, newRequest, completionHandler);
        } originalImplementationBlock:^{
            ((id(*)(id, SEL, id, id, id, id, void(^)()))objc_msgSend)(slf, swizzledSelector, session, task, response, newRequest, completionHandler);
        }];
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
    
}

+ (void)injectTaskDidReceiveDataIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:dataTask:didReceiveData:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLSessionDataDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^NSURLSessionDidReceiveDataBlock)(id <NSURLSessionDataDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data);
    
    NSURLSessionDidReceiveDataBlock undefinedBlock = ^(id <NSURLSessionDataDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
        [[VZNetworkObserver sharedObserver] URLSession:session dataTask:dataTask didReceiveData:data delegate:slf];
    };
    
    NSURLSessionDidReceiveDataBlock implementationBlock = ^(id <NSURLSessionDataDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            undefinedBlock(slf, session, dataTask, data);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(slf, swizzledSelector, session, dataTask, data);
        }];
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
    
}

+ (void)injectDataTaskDidBecomeDownloadTaskIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:dataTask:didBecomeDownloadTask:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLSessionDataDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^NSURLSessionDidBecomeDownloadTaskBlock)(id <NSURLSessionDataDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask);
    
    NSURLSessionDidBecomeDownloadTaskBlock undefinedBlock = ^(id <NSURLSessionDataDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask) {
        [[VZNetworkObserver sharedObserver] URLSession:session dataTask:dataTask didBecomeDownloadTask:downloadTask delegate:slf];
    };
    
    NSURLSessionDidBecomeDownloadTaskBlock implementationBlock = ^(id <NSURLSessionDataDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            undefinedBlock(slf, session, dataTask, downloadTask);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(slf, swizzledSelector, session, dataTask, downloadTask);
        }];
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
}

+ (void)injectTaskDidReceiveResponseIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:dataTask:didReceiveResponse:completionHandler:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLSessionDataDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^NSURLSessionDidReceiveResponseBlock)(id <NSURLSessionDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response, void(^completionHandler)(NSURLSessionResponseDisposition disposition));
    
    NSURLSessionDidReceiveResponseBlock undefinedBlock = ^(id <NSURLSessionDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response, void(^completionHandler)(NSURLSessionResponseDisposition disposition)) {
        [[VZNetworkObserver sharedObserver] URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler delegate:slf];
    };
    
    NSURLSessionDidReceiveResponseBlock implementationBlock = ^(id <NSURLSessionDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response, void(^completionHandler)(NSURLSessionResponseDisposition disposition)) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            undefinedBlock(slf, session, dataTask, response, completionHandler);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id, id, void(^)()))objc_msgSend)(slf, swizzledSelector, session, dataTask, response, completionHandler);
        }];
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
    
}

+ (void)injectTaskDidCompleteWithErrorIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:task:didCompleteWithError:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLSessionTaskDelegate);
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^NSURLSessionTaskDidCompleteWithErrorBlock)(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionTask *task, NSError *error);
    
    NSURLSessionTaskDidCompleteWithErrorBlock undefinedBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionTask *task, NSError *error) {
        [[VZNetworkObserver sharedObserver] URLSession:session task:task didCompleteWithError:error delegate:slf];
    };
    
    NSURLSessionTaskDidCompleteWithErrorBlock implementationBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionTask *task, NSError *error) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            undefinedBlock(slf, session, task, error);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(slf, swizzledSelector, session, task, error);
        }];
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
}

// Used for overriding AFNetworking behavior
+ (void)injectRespondsToSelectorIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(respondsToSelector:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    //Protocol *protocol = @protocol(NSURLSessionTaskDelegate);
    Method method = class_getInstanceMethod(cls, selector);
    struct objc_method_description methodDescription = *method_getDescription(method);
    
    typedef void (^NSURLSessionTaskDidCompleteWithErrorBlock)(id slf, SEL sel);
    
    BOOL (^undefinedBlock)(id <NSURLSessionTaskDelegate>, SEL) = ^(id slf, SEL sel) {
        return YES;
    };
    
    BOOL (^implementationBlock)(id <NSURLSessionTaskDelegate>, SEL) = ^(id <NSURLSessionTaskDelegate> slf, SEL sel) {
        if (sel == @selector(URLSession:dataTask:didReceiveResponse:completionHandler:)) {
            return undefinedBlock(slf, sel);
        }
        return ((BOOL(*)(id, SEL, SEL))objc_msgSend)(slf, swizzledSelector, sel);
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
}


+ (void)injectDownloadTaskDidFinishDownloadingIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:downloadTask:didFinishDownloadingToURL:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLSessionDownloadDelegate);
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^NSURLSessionDownloadTaskDidFinishDownloadingBlock)(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionDownloadTask *task, NSURL *location);
    
    NSURLSessionDownloadTaskDidFinishDownloadingBlock undefinedBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionDownloadTask *task, NSURL *location) {
        NSData *data = [NSData dataWithContentsOfFile:location.relativePath];
        [[VZNetworkObserver sharedObserver] URLSession:session task:task didFinishDownloadingToURL:location data:data delegate:slf];
    };
    
    NSURLSessionDownloadTaskDidFinishDownloadingBlock implementationBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionDownloadTask *task, NSURL *location) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            undefinedBlock(slf, session, task, location);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(slf, swizzledSelector, session, task, location);
        }];
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
}

+ (void)injectDownloadTaskDidWriteDataIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:);
    SEL swizzledSelector = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLSessionDownloadDelegate);
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^NSURLSessionDownloadTaskDidWriteDataBlock)(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionDownloadTask *task, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
    
    NSURLSessionDownloadTaskDidWriteDataBlock undefinedBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionDownloadTask *task, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        [[VZNetworkObserver sharedObserver] URLSession:session downloadTask:task didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite delegate:slf];
    };
    
    NSURLSessionDownloadTaskDidWriteDataBlock implementationBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionDownloadTask *task, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        [self sniffWithoutDuplicationForObject:session selector:selector sniffingBlock:^{
            undefinedBlock(slf, session, task, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        } originalImplementationBlock:^{
            ((void(*)(id, SEL, id, id, int64_t, int64_t, int64_t))objc_msgSend)(slf, swizzledSelector, session, task, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        }];
    };
    
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls withMethodDescription:methodDescription implementationBlock:implementationBlock undefinedBlock:undefinedBlock];
    
}

static char const * const kVZRequestIDKey = "kVZRequestIDKey";

+ (NSString *)requestIDForConnectionOrTask:(id)connectionOrTask
{
    NSString *requestID = objc_getAssociatedObject(connectionOrTask, kVZRequestIDKey);
    if (!requestID) {
        requestID = [self nextRequestID];
        [self setRequestID:requestID forConnectionOrTask:connectionOrTask];
    }
    return requestID;
}

+ (void)setRequestID:(NSString *)requestID forConnectionOrTask:(id)connectionOrTask
{
    objc_setAssociatedObject(connectionOrTask, kVZRequestIDKey, requestID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.requestStatesForRequestIDs = [[NSMutableDictionary alloc] init];
        _queue = dispatch_queue_create("com.VZ.VZNetworkObserver", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Private Methods

- (void)performBlock:(dispatch_block_t)block
{
    if (self.isEnabled) {
        dispatch_async(_queue, block);
    }
}

- (VZNetworkObserverInternalRequestState *)requestStateForRequestID:(NSString *)requestID
{
    VZNetworkObserverInternalRequestState *requestState = [self.requestStatesForRequestIDs objectForKey:requestID];
    if (!requestState) {
        requestState = [[VZNetworkObserverInternalRequestState alloc] init];
        [self.requestStatesForRequestIDs setObject:requestState forKey:requestID];
    }
    return requestState;
}

- (void)removeRequestStateForRequestID:(NSString *)requestID
{
    [self.requestStatesForRequestIDs removeObjectForKey:requestID];
}

@end


@implementation VZNetworkObserver (NSURLConnectionHelpers)

- (BOOL)shouldIgnoreDelegate:(id)delegate
{
    NSString *className = NSStringFromClass([delegate class]);
    if (_ignoreDelegateClasses && [_ignoreDelegateClasses containsObject:className]) {
        return YES;
    }
    return NO;
}

- (void)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response delegate:(id<NSURLConnectionDelegate>)delegate
{
    [self performBlock:^{
        kVZNetowrkIgnore
        NSString *requestID = [[self class] requestIDForConnectionOrTask:connection];
        VZNetworkObserverInternalRequestState *requestState = [self requestStateForRequestID:requestID];
        requestState.request = request;
        [[VZNetworkRecorder defaultRecorder] recordRequestWillBeSentWithRequestID:requestID request:request redirectResponse:response];
        NSString *mechanism = [NSString stringWithFormat:@"NSURLConnection (delegate: %@)", [delegate class]];
        [[VZNetworkRecorder defaultRecorder] recordMechanism:mechanism forRequestID:requestID];
    }];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response delegate:(id<NSURLConnectionDelegate>)delegate
{
    [self performBlock:^{
        kVZNetowrkIgnore
        NSString *requestID = [[self class] requestIDForConnectionOrTask:connection];
        VZNetworkObserverInternalRequestState *requestState = [self requestStateForRequestID:requestID];
        
        NSMutableData *dataAccumulator = nil;
        if (response.expectedContentLength < 0) {
            dataAccumulator = [[NSMutableData alloc] init];
        } else {
            dataAccumulator = [[NSMutableData alloc] initWithCapacity:(NSUInteger)response.expectedContentLength];
        }
        requestState.dataAccumulator = dataAccumulator;
        
        [[VZNetworkRecorder defaultRecorder] recordResponseReceivedWithRequestID:requestID response:response];
    }];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data delegate:(id<NSURLConnectionDelegate>)delegate
{
    // Just to be safe since we're doing this async
    data = [data copy];
    [self performBlock:^{
        kVZNetowrkIgnore
        NSString *requestID = [[self class] requestIDForConnectionOrTask:connection];
        VZNetworkObserverInternalRequestState *requestState = [self requestStateForRequestID:requestID];
        [requestState.dataAccumulator appendData:data];
        [[VZNetworkRecorder defaultRecorder] recordDataReceivedWithRequestID:requestID dataLength:data.length];
    }];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection delegate:(id<NSURLConnectionDelegate>)delegate
{
    [self performBlock:^{
        kVZNetowrkIgnore
        NSString *requestID = [[self class] requestIDForConnectionOrTask:connection];
        VZNetworkObserverInternalRequestState *requestState = [self requestStateForRequestID:requestID];
        [[VZNetworkRecorder defaultRecorder] recordLoadingFinishedWithRequestID:requestID responseBody:requestState.dataAccumulator];
        [self removeRequestStateForRequestID:requestID];
    }];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error delegate:(id<NSURLConnectionDelegate>)delegate
{
    [self performBlock:^{
        kVZNetowrkIgnore
        NSString *requestID = [[self class] requestIDForConnectionOrTask:connection];
        VZNetworkObserverInternalRequestState *requestState = [self requestStateForRequestID:requestID];
        
        // Cancellations can occur prior to the willSendRequest:... NSURLConnection delegate call.
        // These are pretty common and clutter up the logs. Only record the failure if the recorder already knows about the request through willSendRequest:...
        if (requestState.request) {
            [[VZNetworkRecorder defaultRecorder] recordLoadingFailedWithRequestID:requestID error:error];
        }
        
        [self removeRequestStateForRequestID:requestID];
    }];
}

- (void)connectionWillCancel:(NSURLConnection *)connection
{
    [self performBlock:^{
        // Mimic the behavior of NSURLSession which is to create an error on cancellation.
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"cancelled" };
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:userInfo];
        [self connection:connection didFailWithError:error delegate:nil];
    }];
}

@end


@implementation VZNetworkObserver (NSURLSessionTaskHelpers)

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler delegate:(id<NSURLSessionDelegate>)delegate
{
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:task];
        [[VZNetworkRecorder defaultRecorder] recordRequestWillBeSentWithRequestID:requestID request:request redirectResponse:response];
    }];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler delegate:(id<NSURLSessionDelegate>)delegate
{
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:dataTask];
        VZNetworkObserverInternalRequestState *requestState = [self requestStateForRequestID:requestID];
        
        NSMutableData *dataAccumulator = nil;
        if (response.expectedContentLength < 0) {
            dataAccumulator = [[NSMutableData alloc] init];
        } else {
            dataAccumulator = [[NSMutableData alloc] initWithCapacity:(NSUInteger)response.expectedContentLength];
        }
        requestState.dataAccumulator = dataAccumulator;
        
        NSString *requestMechanism = [NSString stringWithFormat:@"NSURLSessionDataTask (delegate: %@)", [delegate class]];
        [[VZNetworkRecorder defaultRecorder] recordMechanism:requestMechanism forRequestID:requestID];
        
        [[VZNetworkRecorder defaultRecorder] recordResponseReceivedWithRequestID:requestID response:response];
    }];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask delegate:(id<NSURLSessionDelegate>)delegate
{
    [self performBlock:^{
        // By setting the request ID of the download task to match the data task,
        // it can pick up where the data task left off.
        NSString *requestID = [[self class] requestIDForConnectionOrTask:dataTask];
        [[self class] setRequestID:requestID forConnectionOrTask:downloadTask];
    }];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data delegate:(id<NSURLSessionDelegate>)delegate
{
    // Just to be safe since we're doing this async
    data = [data copy];
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:dataTask];
        VZNetworkObserverInternalRequestState *requestState = [self requestStateForRequestID:requestID];
        
        [requestState.dataAccumulator appendData:data];
        
        [[VZNetworkRecorder defaultRecorder] recordDataReceivedWithRequestID:requestID dataLength:data.length];
    }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error delegate:(id<NSURLSessionDelegate>)delegate
{
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:task];
        VZNetworkObserverInternalRequestState *requestState = [self requestStateForRequestID:requestID];
        
        if (error) {
            [[VZNetworkRecorder defaultRecorder] recordLoadingFailedWithRequestID:requestID error:error];
        } else {
            [[VZNetworkRecorder defaultRecorder] recordLoadingFinishedWithRequestID:requestID responseBody:requestState.dataAccumulator];
        }
        
        [self removeRequestStateForRequestID:requestID];
    }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite delegate:(id<NSURLSessionDelegate>)delegate
{
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:downloadTask];
        VZNetworkObserverInternalRequestState *requestState = [self requestStateForRequestID:requestID];
        
        if (!requestState.dataAccumulator) {
            requestState.dataAccumulator = [[NSMutableData alloc] initWithCapacity:(NSUInteger)totalBytesExpectedToWrite];
            [[VZNetworkRecorder defaultRecorder] recordResponseReceivedWithRequestID:requestID response:downloadTask.response];
            
            NSString *requestMechanism = [NSString stringWithFormat:@"NSURLSessionDownloadTask (delegate: %@)", [delegate class]];
            [[VZNetworkRecorder defaultRecorder] recordMechanism:requestMechanism forRequestID:requestID];
        }
        
        [[VZNetworkRecorder defaultRecorder] recordDataReceivedWithRequestID:requestID dataLength:bytesWritten];
    }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location data:(NSData *)data delegate:(id<NSURLSessionDelegate>)delegate
{
    data = [data copy];
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:downloadTask];
        VZNetworkObserverInternalRequestState *requestState = [self requestStateForRequestID:requestID];
        [requestState.dataAccumulator appendData:data];
    }];
}

- (void)URLSessionTaskWillResume:(NSURLSessionTask *)task
{
    // Since resume can be called multiple times on the same task, only treat the first resume as
    // the equivalent to connection:willSendRequest:...
    [self performBlock:^{
        NSString *requestID = [[self class] requestIDForConnectionOrTask:task];
        VZNetworkObserverInternalRequestState *requestState = [self requestStateForRequestID:requestID];
        if (!requestState.request) {
            requestState.request = task.currentRequest;
            
            [[VZNetworkRecorder defaultRecorder] recordRequestWillBeSentWithRequestID:requestID request:task.currentRequest redirectResponse:nil];
        }
    }];
}
@end
