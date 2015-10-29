//
//  O2OMethodTrace+IMPs.h
//  testinvocation
//
//  Created by lingwan on 10/15/15.
//  Copyright © 2015 lingwan. All rights reserved.
//

#import "O2OMethodTrace.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface O2OMethodTrace (IMPs)

char charMethodImp(id self, SEL _cmd, ...);

int intMethodImp(id self, SEL _cmd, ...);

short shortMethodImp(id self, SEL _cmd, ...);

long longMethodImp(id self, SEL _cmd, ...);

long long longlongMethodImp(id self, SEL _cmd, ...);

unsigned char unsignedCharMethodImp(id self, SEL _cmd, ...);

unsigned int unsignedIntMethodImp(id self, SEL _cmd, ...);

unsigned short unsignedShortMethodImp(id self, SEL _cmd, ...);

unsigned long unsignedLongMethodImp(id self, SEL _cmd, ...);

unsigned long long unsignedLongLongMethodImp(id self, SEL _cmd, ...);

float floatMethodImp(id self, SEL _cmd, ...);

double doubleMethodImp(id self, SEL _cmd, ...);

BOOL boolMethodImp(id self, SEL _cmd, ...);

void voidMethodImp(id self, SEL _cmd, ...);

char* charPointerMethodImp(id self, SEL _cmd, ...);

id idMethodImp(id self, SEL _cmd, ...);

Class classMethodImp(id self, SEL _cmd, ...);

SEL selectorMethodImp(id self, SEL _cmd, ...);

CGRect cgRectMethodImp(id self, SEL _cmd, ...);

CGPoint cgPointMethodImp(id self, SEL _cmd, ...);

CGSize cgSizeMethodImp(id self, SEL _cmd, ...);

CGAffineTransform cgAffineTransformMethodImp(id self, SEL _cmd, ...);

UIEdgeInsets uiEdgeInsetsMethodImp(id self, SEL _cmd, ...);

UIOffset uiOffsetMethodImp(id self, SEL _cmd, ...);

@end
