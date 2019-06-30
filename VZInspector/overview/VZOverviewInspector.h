//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NSString*(^vz_overview_callback)(void);
@interface VZOverviewInspector : NSObject

+ (VZOverviewInspector* )sharedInstance;

@property(nonatomic,copy) NSMutableArray<vz_overview_callback> *observingCallbacks;

@end
