// VZViewController.m 
// iCoupon 
//created by Jayson Xu on 2014-09-15 15:35:19 +0800. 
// Copyright (c) @VizLab. All rights reserved.
// 

#import "VZViewController.h"
#import "VZViewControllerLogic.h"
#import "VizzleConfig.h"
#import "VZHTTPModel.h"
#import <libkern/OSAtomic.h>

@interface VZViewController ()<VZViewControllerLogicInterface>
{

    //VZMV* => 1.4 Internal states of viewcontroller
    NSMutableDictionary* _states; //<key:model's key, value>
    
    //lock here
    OSSpinLock _lock;
}

@end

@implementation VZViewController
@synthesize logic = _logic;


////////////////////////////////////////////////////////////////////////////////////
#pragma mark - setters

- (void)setLogic:(VZViewControllerLogic *)logic
{
    _logic = logic;
    _logic.viewController = self;
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark - getters

- (NSDictionary*)modelDictionary
{
    return [_modelDictInternal copy];
}
- (VZViewControllerLogic* )logic
{
    if (!_logic) {
        _logic = [VZViewControllerLogic new];
        _logic.viewController = self;
    }
    return _logic;
}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark - life cycle


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self = [self init];
        
        
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        _modelDictInternal = [NSMutableDictionary new];
        _states = [NSMutableDictionary new];
        _lock = OS_SPINLOCK_INIT;
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.logic logic_view_did_load];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.logic logic_view_will_appear];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.logic logic_view_did_appear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.logic logic_view_will_disappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.logic logic_view_did_disappear];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

-(void)dealloc {
    
    VZLog(@"[%@]-->dealloc",self.class);
    
    [_logic logic_dealloc];
    
    OSSpinLockLock(&_lock);
    [_modelDictInternal removeAllObjects];
    [_states removeAllObjects];
    OSSpinLockUnlock(&_lock);

}

////////////////////////////////////////////////////////////////////////////////////
#pragma mark - public

- (void)registerModel:(VZModel *)model{
    
    model.delegate = self;
    
    NSAssert(model.key != nil, @"model must have a key");
    
    OSSpinLockLock(&_lock);
    [_modelDictInternal setObject:model forKey:model.key];
    [_states setObject:@"ready" forKey:model.key];
    OSSpinLockUnlock(&_lock);
}

- (void)unRegisterModel:(VZModel *)model{
    
     NSAssert(model.key != nil, @"model must have a key");
    
    OSSpinLockLock(&_lock);
    [_modelDictInternal removeObjectForKey:model.key];
    [_states removeObjectForKey:model.key];
    OSSpinLockUnlock(&_lock);
}

- (void)load {
    
    //解决遍历dictionary的时候，调用方调用unregister方法
    [_modelDictInternal  enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        VZHTTPModel *model = (VZHTTPModel*)obj;
        
        //to the next runloop
        dispatch_async(dispatch_get_main_queue(), ^{
            [model load];
        });
    }];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - model callback

- (void)modelDidStart:(VZModel *)model {
    
    [self showLoading:model];
    [self updateState:@"loading" withKey:model.key];
}

- (void)modelDidFinish:(VZModel *)model {
    
    [self didLoadModel:model];
    
    //VZMV* 1.1 => 修改了showEmpty逻辑
    if ([self canShowModel:model])
    {
        [self showModel:model];
        [self updateState:@"finished" withKey:model.key];
    }
    else
    {
        
        [self showEmpty:model];
        [self updateState:@"empty" withKey:model.key];
    }
}

- (void)modelDidFail:(VZModel *)model withError:(NSError *)error {
    
    [self showError:error withModel:model];
    [self updateState:@"error" withKey:model.key];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - logic action callback

- (void)onControllerShouldPerformAction:(int)type args:(NSDictionary* )dict
{
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - private 

- (void)updateState:(id) status withKey:(NSString* )key
{
    if (status && key) {
        
        OSSpinLockLock(&_lock);
        
        _states[key] = status;
        VZLog(@"[%@]-->status:%@",self.class,_states);
        
        OSSpinLockUnlock(&_lock);
    }
}

@end 


////////////////////////////////////////////////////////////////////////
@implementation VZViewController(Subclassing)

- (void)didLoadModel:(VZModel*)model{
}

- (BOOL)canShowModel:(VZModel*)model
{
    if ([_modelDictInternal.allKeys containsObject:model.key]) {
        return YES;
    }
    else
        return NO;
    
}

- (void)showModel:(VZModel *)model
{
    //todo:
}

- (void)showEmpty:(VZModel *)model
{
    //todo:
}


- (void)showLoading:(VZModel*)model
{
    //todo:
}

- (void)showError:(NSError *)error withModel:(VZModel*)model
{
    //todo:
}

@end

@implementation VZViewController(MemoryWarning)

- (BOOL)shouldHandleMemoryWarning
{
    return YES;
}

@end