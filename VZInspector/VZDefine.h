//
//  VZDefine.h
//  VZInspector
//
//  Created by John Wong on 8/3/15.
//  Copyright (c) 2015 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)
#define flessthan(a,b) (fabs(a) < fabs(b)+FLT_EPSILON)
