//
//  VZInspectorMermoryRetainCycleItem.h
//  APInspector
//
//  Created by 净枫 on 2016/12/21.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VZInspectorMermoryRetainCycleItem : NSObject

//变量持有的对象className
@property (nonatomic, strong)NSString *className;

//变量名
@property (nonatomic, strong)NSString *variable;

//变量的申明classname
@property (nonatomic, strong)NSString *variableClassName;

@property (nonatomic, strong)UIColor *backgroundColor;

@property (nonatomic, assign)BOOL isFirstOrLast;

@end
