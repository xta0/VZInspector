//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (VZInspector)

/**
 for debugger use
 */
@property(nonatomic,strong) NSMutableArray* samplePoints;
/**
 for debugger use
 */
- (void)vz_heartBeat;

@end
