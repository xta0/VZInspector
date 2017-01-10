//
//  VZToolboxView.h
//  VZInspector
//
//  Created by lingwan on 15/4/16.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZInspectorView.h"
#import "VZInspectorToolItem.h"

@interface VZInspectorToolboxView : VZInspectorView

- (void)addToolItem:(VZInspectorToolItem *)toolItem;
- (void)setIcon:(UIImage *)icon;

- (void)updateCollectionView;

@end
