//
//  VZInspectorHeapObjectGraphicView.h
//  VZInspector
//
//  Created by moxin on 15/5/21.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VZInspectorHeapGraphicObject:NSObject

@property(nonatomic,strong)NSString* className;
@property(nonatomic,strong)NSString* ivarName;
@property(nonatomic,strong)NSString* address;

@end

@interface VZInspectorHeapObjectGraphicView : UIView

@property(nonatomic,strong) VZInspectorHeapGraphicObject* mainObject;
@property(nonatomic,strong) NSArray* referencedObjects; //list<VZInspectorHeapGraphicObject>

- (void)draw;
- (void)clear;

@end
