//
//  VZOverviewInspector.h
//  VZInspector
//
//  Created by moxin.xt on 14-12-6.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NSString*(^vz_overview_callback)(void);
@interface VZOverviewInspector : NSObject

+ (VZOverviewInspector* )sharedInstance;

@property(nonatomic,copy) NSMutableArray<vz_overview_callback> *observingCallbacks;

@end
