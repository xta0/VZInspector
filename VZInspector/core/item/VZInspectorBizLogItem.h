//
//  VZInspectorBizLogItem.h
//  APInspector
//
//  Created by 净枫 on 16/6/20.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZInspectorBizLogItem : NSObject<NSCoding ,NSCopying>

@property (nonatomic, assign) float itemHeight;

@property (nonatomic, assign) Class cellClass;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end
