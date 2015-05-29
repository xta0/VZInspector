//
//  VZInspectorAssert.h
//  VZInspector
//
//  Created by moxin on 15/5/28.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#ifndef VZInspector_VZInspectorAssert_h
#define VZInspector_VZInspectorAssert_h

#include <pthread.h>



static inline BOOL vz_isMainThread(){return 0 != pthread_main_np();};
#define VZIPAssert(...) Assert(__VA_ARGS__)

#endif
