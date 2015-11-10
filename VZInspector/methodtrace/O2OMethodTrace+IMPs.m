//
//  O2OMethodTrace+IMPs.m
//  testinvocation
//
//  Created by lingwan on 10/15/15.
//  Copyright © 2015 lingwan. All rights reserved.
//

#import "O2OMethodTrace+IMPs.h"
#import "O2OMethodTrace+TypeEncoding.h"
#import "O2OMethodTrace+Statistic.h"

#define createAndCallInvocation \
NSString *methodName = NSStringFromSelector(_cmd);\
NSString *swizzleName = [NSString stringWithFormat:@"%@_%@", o2oSwizzlePrefix, methodName];\
NSMethodSignature *signature = [self methodSignatureForSelector:NSSelectorFromString(swizzleName)];\
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
invocation.target = self;\
invocation.selector = NSSelectorFromString(swizzleName);\
\
va_list list;\
va_start(list, _cmd);\
addArguments(invocation, list);\
va_end(list);\
\
[invocation invoke];

#define statisticsSnippet \
[O2OMethodTrace processNewSEL:_cmd];

@implementation O2OMethodTrace (IMPs)

void addArguments(NSInvocation *invocation, va_list list) {
    for (NSUInteger i = 2; i < [[invocation methodSignature] numberOfArguments]; i++) {
        const char *argumentType = [[invocation methodSignature] getArgumentTypeAtIndex:i];
        O2OMethodTraceType type = typeEncoding([NSString stringWithUTF8String:argumentType]);
        switch (type) {
            case O2OMethodTraceTypeChar:
            {
                char argument = va_arg(list, int);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeInt:
            {
                int argument = va_arg(list, int);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeShort:
            {
                short argument = va_arg(list, int);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeLong:
            {
                long argument = va_arg(list, long);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeLongLong:
            {
                long long argument = va_arg(list, long long);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeUnsignedChar:
            {
                unsigned char argument = va_arg(list, int);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeUnsignedInt:
            {
                unsigned int argument = va_arg(list, unsigned int);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeUnsignedShort:
            {
                unsigned short argument = va_arg(list, int);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeUnsignedLong:
            {
                unsigned long argument = va_arg(list, unsigned long);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeUnsignedLongLong:
            {
                unsigned long long argument = va_arg(list, unsigned long long);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeFloat:
            {
                float argument = va_arg(list, double);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeDouble:
            {
                double argument = va_arg(list, double);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeBool:
            {
                BOOL argument = va_arg(list, int);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeVoidPointer:
            {
                char *argument = va_arg(list, void*);
                [invocation setArgument:argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeCharPointer:
            {
                char *argument = va_arg(list, char*);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeObject:
            {
                id argument = va_arg(list, id);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeClass:
            {
                Class argument = va_arg(list, Class);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeSelector:
            {
                SEL argument = va_arg(list, SEL);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeCGRect:
            {
                CGRect argument = va_arg(list, CGRect);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeCGPoint:
            {
                CGPoint argument = va_arg(list, CGPoint);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeCGSize:
            {
                CGSize argument = va_arg(list, CGSize);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeCGAffineTransform:
            {
                CGAffineTransform argument = va_arg(list, CGAffineTransform);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeUIEdgeInsets:
            {
                UIEdgeInsets argument = va_arg(list, UIEdgeInsets);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            case O2OMethodTraceTypeUIOffset:
            {
                UIOffset argument = va_arg(list, UIOffset);
                [invocation setArgument:&argument atIndex:i];
                break;
            }
            default:
                break;
        }
    }
}

char charMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    char returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

int intMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    int returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

short shortMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    short returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

long longMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    long returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

long long longlongMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    long long returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

unsigned char unsignedCharMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    unsigned char returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

unsigned int unsignedIntMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    unsigned int returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

unsigned short unsignedShortMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    unsigned short returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

unsigned long unsignedLongMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    unsigned long returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

unsigned long long unsignedLongLongMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    unsigned long long returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

float floatMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    float returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

double doubleMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    double returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

BOOL boolMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    BOOL returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

void voidMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
}

void* voidPointerMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    void *returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

char* charPointerMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    char *returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

id idMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    __unsafe_unretained id returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

Class classMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    Class returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

SEL selectorMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    SEL returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

CGRect cgRectMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    CGRect returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

CGPoint cgPointMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    CGPoint returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

CGSize cgSizeMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    CGSize returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

CGAffineTransform cgAffineTransformMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    CGAffineTransform returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

UIEdgeInsets uiEdgeInsetsMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    UIEdgeInsets returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

UIOffset uiOffsetMethodImp(id self, SEL _cmd, ...) {
    createAndCallInvocation;
    statisticsSnippet;
    
    UIOffset returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

@end
