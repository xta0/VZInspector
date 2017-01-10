//
//  VZInspectorMermoryDataHelper.m
//  APInspector
//
//  Created by 净枫 on 2016/12/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZInspectorMermoryDataHelper.h"
#import "VZMermoryProfilerManager.h"
#import "VZAllocationTrackerSummary.h"
#import "VZInspectorMermoryItem.h"
#import "VZInspectorMermoryUtil.h"
#import "VZInspectorMermoryCell.h"
#import "VZInspectorMermoryInstanceItem.h"
#import "VZInspectorMermoryInstanceCell.h"
#import "VZInspectorMermoryRetainCycleResultItem.h"
#import "VZInspectorMermoryRetainCycleItem.h"
#import "VZObjectiveCGraphElement.h"
#import "VZDefine.h"

@interface VZInspectorMermoryDataHelper()

@property (nonatomic, strong) NSString *filterStr;

@property (nonatomic, strong) VZInspectorMermoryItem* selectedItem;

@property (nonatomic, strong) NSString *className;

@property (nonatomic, strong) NSMutableDictionary *classLoadingCache;

@property (nonatomic, assign) BOOL isRetainCycle;

@property (nonatomic, assign) BOOL isTrackable;

@end

@implementation VZInspectorMermoryDataHelper

+ (instancetype)sharedInstance{
    static VZInspectorMermoryDataHelper* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [VZInspectorMermoryDataHelper new];
    });
    return instance;
}

- (instancetype)init{
    if(self = [super init]){
        _classLoadingCache = [[NSMutableDictionary alloc]init];
        _isRetainCycle = NO;
        NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
        if(defaults){
            _isTrackable = [[defaults objectForKey:KVZInspectorMermoryCheckSwitch] boolValue];
        }

    }
    return self;
}

- (BOOL) canMermoryTrack{
    return _isTrackable;
}

- (void)updateMermoryTrackState:(BOOL)state{
    _isTrackable = state;
}

- (void)startTrackingIfNeed{
    if([self canMermoryTrack]){
        [[VZMermoryProfilerManager sharedManager] startTracking];
    }
}

- (void)endTrackingIfNeed{
    if(![self canMermoryTrack]){
        [[VZMermoryProfilerManager sharedManager] endTracking];
    }
}

- (void)setClassLoadingStatus:(BOOL)isLoading className:(NSString *)className{
    if(vz_IsStringValid(className)){
        [_classLoadingCache setObject:@(isLoading?1:0) forKey:className];
    }
}

- (NSMutableArray *)mermoryDatas{
    return [self prepareMermoryDatas:_filterStr isRetainCycle:_isRetainCycle];
}

- (NSMutableArray *)mermoryDatasForRetainCycle:(BOOL)isRetainCycle{
    _isRetainCycle = isRetainCycle;
    return [self prepareMermoryDatas:_filterStr isRetainCycle:_isRetainCycle];
}

- (NSMutableArray *)filterMermoryDatas:(NSString *)filter{
    _filterStr = filter;
    return [self prepareMermoryDatas:_filterStr isRetainCycle:_isRetainCycle];
}



- (NSMutableArray *)prepareMermoryDatas:(NSString *)filter isRetainCycle:(BOOL)isRetainCycle{
    
    if(![self canMermoryTrack]){
        return nil;
    }
    
    NSSet<VZAllocationTrackerSummary *> *trackedClasses = [[[VZMermoryProfilerManager sharedManager] trackedClassesForRetainCycle:isRetainCycle] copy];
    NSMutableArray *mermoryDatas = [[NSMutableArray alloc]init];
    [trackedClasses enumerateObjectsUsingBlock:^(VZAllocationTrackerSummary *summary, BOOL * _Nonnull stop) {
        if(summary && [summary isKindOfClass:[VZAllocationTrackerSummary class]]){
            NSString *className = summary.className;
            NSString *lowerClassName = [className lowercaseString];
            if(filter == nil || [filter isEqualToString:@""]){
                VZInspectorMermoryItem *item = [VZInspectorMermoryItem new];
                item.cellClass = [VZInspectorMermoryCell class];
                item.itemHeight = KVZInspectorMermoryCellHeight;
                item.className = className;
                item.objectCount = summary.aliveObjects;
                item.retainCycleStatus = [[VZMermoryProfilerManager sharedManager] retainCycleStatusForClassName:className];
                item.isLoading = [[_classLoadingCache objectForKey:className] boolValue];
                [mermoryDatas addObject:item];
            }else if([lowerClassName containsString:[filter lowercaseString]]){
                VZInspectorMermoryItem *item = [VZInspectorMermoryItem new];
                item.cellClass = [VZInspectorMermoryCell class];
                item.itemHeight = KVZInspectorMermoryCellHeight;
                item.className = className;
                item.objectCount = summary.aliveObjects;
                item.retainCycleStatus = [[VZMermoryProfilerManager sharedManager] retainCycleStatusForClassName:className];
                item.isLoading = [[_classLoadingCache objectForKey:className] boolValue];
                [mermoryDatas addObject:item];
            }
        }
    }];
    return mermoryDatas;
}

- (NSArray *)findRetainCyclesForInstances:(NSString *)className{
    if(![self canMermoryTrack]){
        return nil;
    }
    if(vz_IsStringValid(className)){
       NSArray *retainCycles =  [[VZMermoryProfilerManager sharedManager] findRetainCyclesForClassName:className];
        
        NSMutableArray *mermoryRetainCycles = [[NSMutableArray alloc]init];
        
        [retainCycles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            if([obj isKindOfClass:[NSArray class]]){
                NSArray *oneRCs = (NSArray *)obj;
                VZInspectorMermoryRetainCycleResultItem *resultItem = [VZInspectorMermoryRetainCycleResultItem new];
                [oneRCs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if([obj isKindOfClass:[VZObjectiveCGraphElement class]]){
                        VZObjectiveCGraphElement *element = (VZObjectiveCGraphElement *)obj;
                        VZInspectorMermoryRetainCycleItem *item = [VZInspectorMermoryRetainCycleItem new];
                        item.className = NSStringFromClass([element.object class]);
                        item.variable = [element namePathDescrible];
                        item.variableClassName = element.namePathClassName;
                        [resultItem.retainCycleDatas addObject:item];
                    }
                }];
                if(resultItem.retainCycleDatas.count > 0){
                    resultItem.cellClass = [VZInspectorMermoryInstanceCell class];
                    NSString *describle = [resultItem retainCycleDescrible];
                    if(describle){
                        CGSize describleSize = [describle boundingRectWithSize:CGSizeMake(screen_width - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size;
                        resultItem.itemHeight = describleSize.height + 10;
                        resultItem.describleSize = describleSize;
                    }else{
                        resultItem.itemHeight = KVZInspectorMermoryCellHeight;
                    }
                    [mermoryRetainCycles addObject:resultItem];
                }
            }
            
        }];
    
        return [mermoryRetainCycles copy];
    }
    return nil;
}


@end
