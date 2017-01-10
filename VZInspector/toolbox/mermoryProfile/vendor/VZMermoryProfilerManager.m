//
//  VZMermoryProfilerManager.m
//  APInspector
//
//  Created by 净枫 on 16/8/16.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZMermoryProfilerManager.h"
#import "VZAllocationTrackerManager.h"
#import "VZAssociationManager.h"
#import "VZRetainCycleDetector.h"
#import "VZAllocationTrackerSummary.h"
#import "VZDefine.h"

@interface VZMermoryProfilerManager()

@property (nonatomic, assign) BOOL isTracking;

@property (nonatomic, strong) NSMutableDictionary *analysisCache;

@property (nonatomic, strong) NSArray *mermoryClassBlackKeys;

@property (nonatomic, strong) NSArray *mermoryClassWhiteKeys;

@end

@implementation VZMermoryProfilerManager

+ (instancetype)sharedManager
{
    static VZMermoryProfilerManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [VZMermoryProfilerManager new];
    });
    return sharedManager;
}

- (instancetype)init{
    if(self = [super init]){
        _analysisCache = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)startTracking{
    
    _isTracking = YES;
    [[VZAllocationTrackerManager sharedManager] startTrackingAllocations];
    [VZAssociationManager hook];
}

- (void)endTracking{
    _isTracking = NO;
    [[VZAllocationTrackerManager sharedManager] stopTrackingAllocations];
    [VZAssociationManager unhook];
}

- (nullable NSArray<VZAllocationTrackerSummary *> *)currentAllocationSummary{
    return [[VZAllocationTrackerManager sharedManager] currentAllocationSummary];
}

- (nullable NSArray *)instancesOfClasses:(nonnull NSArray *)classes{
    return [[VZAllocationTrackerManager sharedManager] instancesOfClasses:classes];
}


- (nullable NSSet<Class> *)trackedClasses{
    
    return [self trackedClassesForRetainCycle:NO];
}

- (nullable NSSet<VZAllocationTrackerSummary *> *)trackedClassesForRetainCycle:(BOOL)retainCycle{
    NSSet<VZAllocationTrackerSummary *> * unfilerClasses = [[VZAllocationTrackerManager sharedManager] currentAllocationSummary];
    NSMutableSet<VZAllocationTrackerSummary *> *filerClasses = [[NSMutableSet alloc]init];
    for(VZAllocationTrackerSummary *summary in unfilerClasses){
        NSString *className = summary.className;
        if(vz_IsArrayValid(_mermoryClassWhiteKeys)){

            [_mermoryClassWhiteKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if([className hasPrefix:obj]){
                    if(vz_IsArrayValid(_mermoryClassBlackKeys)){
                        __block BOOL isBlackValue = NO;
                        [_mermoryClassBlackKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj,NSUInteger idx, BOOL * _Nonnull stop) {
                            if([className hasPrefix:obj]){
                                
                                isBlackValue = YES;
                                 *stop = YES;
                            }
                        }];
                        if(!isBlackValue){
                            if(retainCycle){
                                if([[_analysisCache objectForKey:className] integerValue] == VZMermoryRetainCycleStatusLeak){
                                    [filerClasses addObject:summary];
                                }
                            }else{
                                [filerClasses addObject:summary];
                            }

                        }
                    }else{
                        if(retainCycle){
                            if([[_analysisCache objectForKey:className] integerValue] == VZMermoryRetainCycleStatusLeak){
                                [filerClasses addObject:summary];
                            }
                        }else{
                            [filerClasses addObject:summary];
                        }
                    }
                    *stop = YES;
                }
            }];
        }else{
            if(retainCycle){
                if([[_analysisCache objectForKey:className] integerValue] == VZMermoryRetainCycleStatusLeak){
                    [filerClasses addObject:summary];
                }
            }else{
                [filerClasses addObject:summary];
            }
        }
        
    }
    
    NSSortDescriptor * d1 = [NSSortDescriptor sortDescriptorWithKey:@"className" ascending:YES];

    filerClasses = [filerClasses sortedArrayUsingDescriptors:@[d1]];
    
    return filerClasses;
    
}



- (NSSet<NSArray *> *)findRetainCyclesForClassName:(NSString *)className{
    
    if(className){
        Class aCls = NSClassFromString(className);
        NSArray *objects = [self instancesOfClasses:@[aCls]];
        VZRetainCycleDetector *detector = [[VZRetainCycleDetector alloc] init];
        for (id object in objects) {
            [detector addCandidate:object];
        }
        NSSet<NSArray<VZObjectiveCGraphElement *> *> *retainCycles =[detector findRetainCyclesWithMaxCycleLength:8];
        
        //将className与对应的循环依赖状态关联起来
        if(retainCycles.count > 0){
            [_analysisCache setObject:@(VZMermoryRetainCycleStatusLeak) forKey:className];
        }else{
            [_analysisCache setObject:@(VZMermoryRetainCycleStatusNotLeak) forKey:className];
        }
        return retainCycles;
    }
    
    return nil;
}

- (VZMermoryRetainCycleStatus)retainCycleStatusForClassName:(NSString *)className{
    if(className){
        return [[_analysisCache objectForKey:className] integerValue];
    }
    return VZMermoryRetainCycleStatusUnKnown;
}

- (void)updateMermoryClassBlackKeys:(NSArray<NSString *> *)blackKeys{
    _mermoryClassBlackKeys = [blackKeys copy];
}

- (void)updateMermoryClassWhiteKeys:(NSArray<NSString *> *)whiteKeys{
    _mermoryClassWhiteKeys = [whiteKeys copy];
}


@end
