//
//  VZItem.h
//  Vizzle
//
//  Created by Jayson Xu on 14-9-15.
//  Copyright (c) 2014年 VizLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZItem : NSObject

/**
 *  自动进行KVC绑定
 *
 *  VZMV* => 1.1
 *
 *  @param dictionary
 */
- (void)autoKVCBinding:(NSDictionary* )dictionary;
/**
 *  VZMV* => 1.2
 *
 *  @return 序列化为dictionary
 */
- (NSDictionary* )toDictionary;

/**
 *  VZMV* => 1.2
 *
 *  @return 所有property的名称
 */
+ (NSSet* )propertyNames;

@end
