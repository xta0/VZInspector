//
//  VZImageInspector.h
//  VZInspector
//
//  Created by John Wong on 7/31/15.
//  Copyright (c) 2015 VizLabe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZImageInspector : NSObject

+ (instancetype)sharedInstance;

- (void)inspect;

@end
