//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import "VZInspectorView.h"
#import "VZInspectorToolItem.h"

@interface VZInspectorToolboxView : VZInspectorView

- (void)addToolItem:(VZInspectorToolItem *)toolItem;
- (void)setIcon:(UIImage *)icon;

- (void)updateCollectionView;

@end
