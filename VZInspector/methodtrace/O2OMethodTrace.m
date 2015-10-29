//
//  O2OMethodTrace.m
//  O2O
//
//  Created by lingwan on 10/14/15.
//  Copyright © 2015 Alipay. All rights reserved.
//

#import "O2OMethodTrace.h"
#import <objc/runtime.h>
#import "O2OMethodTrace+TypeEncoding.h"
#import "O2OMethodTrace+IMPs.h"
#import "O2OMethodTraceInputView.h"

#define dstLength 256
#define kInputTextViewTag 111

@implementation O2OMethodTrace

+ (void)traceClass:(Class)className {
    [O2OMethodTrace swizzleMethod:className];
    
    Class metaClass = objc_getMetaClass(class_getName(className));
    [O2OMethodTrace swizzleMethod:metaClass];
}

+ (void)swizzleMethod:(Class)className {
    unsigned int methodCount;
    Method *methodList = class_copyMethodList(className, &methodCount);
    
    for (int i = 0; i < methodCount; i++) {
        char returnTypeBuffer[dstLength];
        method_getReturnType(methodList[i], returnTypeBuffer, dstLength);
        O2OMethodTraceType returnType = typeEncoding([NSString stringWithUTF8String:returnTypeBuffer]);
        SEL originSelector = method_getName(methodList[i]);
        NSString *swizzleName = [NSString stringWithFormat:@"%@_%@", o2oSwizzlePrefix, NSStringFromSelector(originSelector)];
        SEL newSelector = NSSelectorFromString(swizzleName);
        BOOL didAddMethod = NO;
        
        switch (returnType) {
            case O2OMethodTraceTypeChar:
                didAddMethod = class_addMethod(className, newSelector, (IMP)charMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeInt:
                didAddMethod = class_addMethod(className, newSelector, (IMP)intMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeShort:
                didAddMethod = class_addMethod(className, newSelector, (IMP)shortMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeLong:
                didAddMethod = class_addMethod(className, newSelector, (IMP)longMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeLongLong:
                didAddMethod = class_addMethod(className, newSelector, (IMP)longlongMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeUnsignedChar:
                didAddMethod = class_addMethod(className, newSelector, (IMP)unsignedCharMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeUnsignedInt:
                didAddMethod = class_addMethod(className, newSelector, (IMP)unsignedIntMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeUnsignedShort:
                didAddMethod = class_addMethod(className, newSelector, (IMP)unsignedShortMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeUnsignedLong:
                didAddMethod = class_addMethod(className, newSelector, (IMP)unsignedLongMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeUnsignedLongLong:
                didAddMethod = class_addMethod(className, newSelector, (IMP)unsignedLongLongMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeFloat:
                didAddMethod = class_addMethod(className, newSelector, (IMP)floatMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeDouble:
                didAddMethod = class_addMethod(className, newSelector, (IMP)doubleMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeBool:
                didAddMethod = class_addMethod(className, newSelector, (IMP)boolMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeVoid:
                didAddMethod = class_addMethod(className, newSelector, (IMP)voidMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeCharPointer:
                didAddMethod = class_addMethod(className, newSelector, (IMP)charPointerMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeObject:
                didAddMethod = class_addMethod(className, newSelector, (IMP)idMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeClass:
                didAddMethod = class_addMethod(className, newSelector, (IMP)classMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeSelector:
                didAddMethod = class_addMethod(className, newSelector, (IMP)selectorMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeCGRect:
                didAddMethod = class_addMethod(className, newSelector, (IMP)cgRectMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeCGPoint:
                didAddMethod = class_addMethod(className, newSelector, (IMP)cgPointMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeCGSize:
                didAddMethod = class_addMethod(className, newSelector, (IMP)cgSizeMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeCGAffineTransform:
                didAddMethod = class_addMethod(className, newSelector, (IMP)cgAffineTransformMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeUIEdgeInsets:
                didAddMethod = class_addMethod(className, newSelector, (IMP)uiEdgeInsetsMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            case O2OMethodTraceTypeUIOffset:
                didAddMethod = class_addMethod(className, newSelector, (IMP)uiOffsetMethodImp, method_getTypeEncoding(methodList[i]));
                break;
            default:
                break;
        }
        
        if (didAddMethod) {
            Method originalMethod = class_getInstanceMethod(className, originSelector);
            Method swizzleMethod = class_getInstanceMethod(className, newSelector);
            
            method_exchangeImplementations(originalMethod, swizzleMethod);
        }
    }
    
    free(methodList);
}

+ (O2OMethodTraceInputView *)inputView {
    O2OMethodTraceInputView *inputView = [[O2OMethodTraceInputView alloc] initWithFrame:CGRectZero];
    inputView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2 - 60);
    
    return inputView;
}

@end