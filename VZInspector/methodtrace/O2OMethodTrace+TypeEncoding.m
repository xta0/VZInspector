//
//  O2OMethodTrace+TypeEncoding.m
//  testinvocation
//
//  Created by lingwan on 10/15/15.
//  Copyright © 2015 lingwan. All rights reserved.
//

#import "O2OMethodTrace+TypeEncoding.h"

@implementation O2OMethodTrace (TypeEncoding)

O2OMethodTraceType typeEncoding(NSString* type) {
    if (strncmp([type UTF8String], "?", 1) == 0) {
        return O2OMethodTraceTypeUnknow;
    } else if (strncmp([type UTF8String], "c", 1) == 0) {
        return O2OMethodTraceTypeChar;
    } else if (strncmp([type UTF8String], "i", 1) == 0) {
        return O2OMethodTraceTypeInt;
    } else if (strncmp([type UTF8String], "s", 1) == 0) {
        return O2OMethodTraceTypeShort;
    } else if (strncmp([type UTF8String], "l", 1) == 0) {
        return O2OMethodTraceTypeLong;
    } else if (strncmp([type UTF8String], "q", 1) == 0) {
        return O2OMethodTraceTypeLongLong;
    } else if (strncmp([type UTF8String], "C", 1) == 0) {
        return O2OMethodTraceTypeUnsignedChar;
    } else if (strncmp([type UTF8String], "I", 1) == 0) {
        return O2OMethodTraceTypeUnsignedInt;
    } else if (strncmp([type UTF8String], "S", 1) == 0) {
        return O2OMethodTraceTypeUnsignedShort;
    } else if (strncmp([type UTF8String], "L", 1) == 0) {
        return O2OMethodTraceTypeUnsignedLong;
    } else if (strncmp([type UTF8String], "Q", 1) == 0) {
        return O2OMethodTraceTypeUnsignedLongLong;
    } else if (strncmp([type UTF8String], "f", 1) == 0) {
        return O2OMethodTraceTypeFloat;
    } else if (strncmp([type UTF8String], "d", 1) == 0) {
        return O2OMethodTraceTypeDouble;
    } else if (strncmp([type UTF8String], "B", 1) == 0) {
        return O2OMethodTraceTypeBool;
    } else if (strncmp([type UTF8String], "v", 1) == 0) {
        return O2OMethodTraceTypeVoid;
    } else if (strncmp([type UTF8String], "^", 1) == 0) {
        return O2OMethodTraceTypeVoidPointer;
    } else if (strncmp([type UTF8String], "*", 1) == 0) {
        return O2OMethodTraceTypeCharPointer;
    } else if (strncmp([type UTF8String], "@", 1) == 0) {
        return O2OMethodTraceTypeObject;
    } else if (strncmp([type UTF8String], "#", 1) == 0) {
        return O2OMethodTraceTypeClass;
    } else if (strncmp([type UTF8String], ":", 1) == 0) {
        return O2OMethodTraceTypeSelector;
    } else if (strncmp([type UTF8String], "{CGRect=", 8) == 0) {
        return O2OMethodTraceTypeCGRect;
    } else if (strncmp([type UTF8String], "{CGPoint=", 9) == 0) {
        return O2OMethodTraceTypeCGPoint;
    } else if (strncmp([type UTF8String], "{CGSize=", 8) == 0) {
        return O2OMethodTraceTypeCGSize;
    } else if (strncmp([type UTF8String], "{CGAffineTransform=", 19) == 0) {
        return O2OMethodTraceTypeCGAffineTransform;
    } else if (strncmp([type UTF8String], "{UIEdgeInsets=", 14) == 0) {
        return O2OMethodTraceTypeUIEdgeInsets;
    } else if (strncmp([type UTF8String], "{UIOffset=", 10) == 0) {
        return O2OMethodTraceTypeUIOffset;
    }
    
    return -1;
}

@end
