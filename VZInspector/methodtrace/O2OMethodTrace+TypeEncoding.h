//
//  O2OMethodTrace+TypeEncoding.h
//  testinvocation
//
//  Created by lingwan on 10/15/15.
//  Copyright © 2015 lingwan. All rights reserved.
//

#import "O2OMethodTrace.h"

typedef NS_ENUM(NSUInteger, O2OMethodTraceType) {
    O2OMethodTraceTypeUnknow,
    O2OMethodTraceTypeChar,
    O2OMethodTraceTypeInt,
    O2OMethodTraceTypeShort,
    O2OMethodTraceTypeLong,
    O2OMethodTraceTypeLongLong,
    O2OMethodTraceTypeUnsignedChar,
    O2OMethodTraceTypeUnsignedInt,
    O2OMethodTraceTypeUnsignedShort,
    O2OMethodTraceTypeUnsignedLong,
    O2OMethodTraceTypeUnsignedLongLong,
    O2OMethodTraceTypeFloat,
    O2OMethodTraceTypeDouble,
    O2OMethodTraceTypeBool,
    O2OMethodTraceTypeVoid,
    O2OMethodTraceTypeVoidPointer,
    O2OMethodTraceTypeCharPointer,
    O2OMethodTraceTypeObject,
    O2OMethodTraceTypeClass,
    O2OMethodTraceTypeSelector,
    O2OMethodTraceTypeCGRect,
    O2OMethodTraceTypeCGPoint,
    O2OMethodTraceTypeCGSize,
    O2OMethodTraceTypeCGAffineTransform,
    O2OMethodTraceTypeUIEdgeInsets,
    O2OMethodTraceTypeUIOffset,
};

@interface O2OMethodTrace (TypeEncoding)

O2OMethodTraceType typeEncoding(NSString* type);

@end
