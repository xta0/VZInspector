//
//  Copyright © 2016年 Vizlab. All rights reserved.
//

#import "VZInspectorView.h"


@interface VZInspectorOverview : VZInspectorView

@property(nonatomic,assign) BOOL memoryWarning;

- (void)updateGlobalInfo;

- (void)startTimer;

- (void)stopTimer;

@end
