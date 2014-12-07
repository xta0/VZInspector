// VZModel.h 
// iCoupon 
//created by Jayson Xu on 2014-09-15 15:35:19 +0800. 
// Copyright (c) @VizLab. All rights reserved.
// 


#import <Foundation/Foundation.h>


/**
 * Model的状态
 *
 * v= VZModel=>1.1:增加finished
 */
typedef NS_OPTIONS(NSInteger, VZModelState) {
    VZModelStateError     = -1,
    VZModelStateReady     = 0,
    VZModelStateLoading   = 1,
    VZModelStateFinished  = 2
    
};



@class VZModel;


typedef void(^VZModelCallback) (VZModel* model, NSError* error);

@protocol VZModelDelegate <NSObject>

@optional
- (void)modelDidStart:(VZModel *)model;
- (void)modelDidFinish:(VZModel *)model;
- (void)modelDidFail:(VZModel *)model withError:(NSError *)error;

@end

@interface VZModel : NSObject

/**
 * Model的状态
 *
 * VZModel=>1.1
 */
@property (nonatomic, assign,readonly) VZModelState state;
/**
 *  Model的delegate，用于发送Model状态
 */
@property(nonatomic, weak) id<VZModelDelegate> delegate;
/**
 *  错误对象，默认为nil
 */
@property(nonatomic, strong,readonly) NSError *error;

/**
 *  Model的key，用于标识Model
 */
@property(nonatomic,strong) NSString* key;
/**
 *  model的请求操作，回调使用delegate
 */
- (void)load;
/**
 * model的请求操作，回调使用block
 *
 * VZModel=>1.1
 *
 * 使用这个方法需要注意：
 * model的状态不会和controller耦合，对界面的更新放到回调中执行
 * 注意block中使用__weak，避免循环引用！
 *
 */
- (void)loadWithCompletion:(VZModelCallback)aCallback;
/**
 *  取消model请求
 */
- (void)cancel;
/**
 *  清空model数据，重置model的状态
 */
- (void)reset;


@end


@interface VZModel(CallBack)

- (void)didStartLoading;
- (void)didFinishLoading;
- (void)didFailWithError:(NSError* )error;

@end


@interface VZModel(SubclassingHooks)

- (BOOL)shouldLoad;

@end

