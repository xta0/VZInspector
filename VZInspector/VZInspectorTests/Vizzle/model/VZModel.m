// VZModel.m 
// iCoupon 
//created by Jayson Xu on 2014-09-15 15:35:19 +0800. 
// Copyright (c) @VizLab. All rights reserved.
// 

#import "VZModel.h"

@interface VZModel()
@property(nonatomic,copy) VZModelCallback requestCallback;
@end

@implementation VZModel

- (void)load
{
    if ([self shouldLoad]) {
        _error = nil;
        [self reset];
    }
    else
    {
        //noop.
    }
}
- (void)cancel
{
    _state = VZModelStateReady;
}

- (void)reset
{
    [self cancel];
}


- (void)loadWithCompletion:(VZModelCallback)aCallback
{
    if (aCallback) {
        self.requestCallback = aCallback;
    }
    [self load];
}


@end



@implementation VZModel(CallBack)

- (void)didStartLoading
{
    _state = VZModelStateLoading;
    
    if ([self.delegate respondsToSelector:@selector(modelDidStart:)]) {
        [self.delegate modelDidStart:self];
    }

}
- (void)didFinishLoading
{
    _state = VZModelStateFinished;
    
    if ([self.delegate respondsToSelector:@selector(modelDidFinish:)]) {
        [self.delegate modelDidFinish:self];
    }

    if (self.requestCallback) {
        self.requestCallback(self,nil);
        self.requestCallback = nil;
    }
}
- (void)didFailWithError:(NSError* )error
{
    _state = VZModelStateError;
    _error = error;
    
    if ([self.delegate respondsToSelector:@selector(modelDidFail:withError:)]) {
        [self.delegate modelDidFail:self withError:error];
    }
    
    if (self.requestCallback) {
        self.requestCallback(self,error);
        self.requestCallback = nil;
    }
}

@end

@implementation VZModel(SubclassingHooks)

- (BOOL)shouldLoad
{
    return YES;
}


@end