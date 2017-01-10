/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "VZKeyCommands.h"
#import "VZInspectorUtility.h"
#import "VZInspectorAssert.h"

#import <UIKit/UIKit.h>

static BOOL RCTIsIOS8OrEarlier()
{
    return [UIDevice currentDevice].systemVersion.floatValue < 9;
}

@interface VZKeyCommand : NSObject <NSCopying>

@property (nonatomic, strong) UIKeyCommand *keyCommand;
@property (nonatomic, copy) void (^block)(UIKeyCommand *);

@end

@implementation VZKeyCommand

- (instancetype)initWithKeyCommand:(UIKeyCommand *)keyCommand
                             block:(void (^)(UIKeyCommand *))block
{
    if ((self = [super init])) {
        _keyCommand = keyCommand;
        _block = block;
    }
    return self;
}

- (id)copyWithZone:(__unused NSZone *)zone
{
    return self;
}

- (NSUInteger)hash
{
    return _keyCommand.input.hash ^ _keyCommand.modifierFlags;
}

- (BOOL)isEqual:(VZKeyCommand *)object
{
    if (![object isKindOfClass:[VZKeyCommand class]]) {
        return NO;
    }
    return [self matchesInput:object.keyCommand.input
                        flags:object.keyCommand.modifierFlags];
}

- (BOOL)matchesInput:(NSString *)input flags:(UIKeyModifierFlags)flags
{
    return [_keyCommand.input isEqual:input] && _keyCommand.modifierFlags == flags;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p input=\"%@\" flags=%zd hasBlock=%@>",
            [self class], self, _keyCommand.input, _keyCommand.modifierFlags,
            _block ? @"YES" : @"NO"];
}

@end

@interface VZKeyCommands ()

@property (nonatomic, strong) NSMutableSet<VZKeyCommand *> *commands;

@end

@implementation UIResponder (VZKeyCommands)

+ (UIResponder *)RCT_getFirstResponder:(UIResponder *)view
{
    UIResponder *firstResponder = nil;
    
    if (view.isFirstResponder) {
        return view;
    } else if ([view isKindOfClass:[UIViewController class]]) {
        if ([(UIViewController *)view parentViewController]) {
            firstResponder = [UIResponder RCT_getFirstResponder: [(UIViewController *)view parentViewController]];
        }
        return firstResponder ? firstResponder : [UIResponder RCT_getFirstResponder: [(UIViewController *)view view]];
    } else if ([view isKindOfClass:[UIView class]]) {
        for (UIView *subview in [(UIView *)view subviews]) {
            firstResponder = [UIResponder RCT_getFirstResponder: subview];
            if (firstResponder) {
                return firstResponder;
            }
        }
    }
    
    return firstResponder;
}

- (NSArray<UIKeyCommand *> *)RCT_keyCommands
{
    NSSet<VZKeyCommand *> *commands = [VZKeyCommands sharedInstance].commands;
    return [[commands valueForKeyPath:@"keyCommand"] allObjects];
}

/**
 * Single Press Key Command Response
 * Command + KeyEvent (Command + R/D, etc.)
 */
- (void)RCT_handleKeyCommand:(UIKeyCommand *)key
{
    // NOTE: throttle the key handler because on iOS 9 the handleKeyCommand:
    // method gets called repeatedly if the command key is held down.
    static NSTimeInterval lastCommand = 0;
    if (RCTIsIOS8OrEarlier() || CACurrentMediaTime() - lastCommand > 0.5) {
        for (VZKeyCommand *command in [VZKeyCommands sharedInstance].commands) {
            if ([command.keyCommand.input isEqualToString:key.input] &&
                command.keyCommand.modifierFlags == key.modifierFlags) {
                if (command.block) {
                    command.block(key);
                    lastCommand = CACurrentMediaTime();
                }
            }
        }
    }
}

/**
 * Double Press Key Command Response
 * Double KeyEvent (Double R, etc.)
 */
- (void)RCT_handleDoublePressKeyCommand:(UIKeyCommand *)key
{
    static BOOL firstPress = YES;
    static NSTimeInterval lastCommand = 0;
    static NSTimeInterval lastDoubleCommand = 0;
    static NSString *lastInput = nil;
    static UIKeyModifierFlags lastModifierFlags = nil;
    
    if (firstPress) {
        for (VZKeyCommand *command in [VZKeyCommands sharedInstance].commands) {
            if ([command.keyCommand.input isEqualToString:key.input] &&
                command.keyCommand.modifierFlags == key.modifierFlags &&
                command.block) {
                
                firstPress = NO;
                lastCommand = CACurrentMediaTime();
                lastInput = key.input;
                lastModifierFlags = key.modifierFlags;
                return;
            }
        }
    } else {
        // Second keyevent within 0.2 second,
        // with the same key as the first one.
        if (CACurrentMediaTime() - lastCommand < 0.2 &&
            lastInput == key.input &&
            lastModifierFlags == key.modifierFlags) {
            
            for (VZKeyCommand *command in [VZKeyCommands sharedInstance].commands) {
                if ([command.keyCommand.input isEqualToString:key.input] &&
                    command.keyCommand.modifierFlags == key.modifierFlags &&
                    command.block) {
                    
                    // NOTE: throttle the key handler because on iOS 9 the handleKeyCommand:
                    // method gets called repeatedly if the command key is held down.
                    if (RCTIsIOS8OrEarlier() || CACurrentMediaTime() - lastDoubleCommand > 0.5) {
                        command.block(key);
                        lastDoubleCommand = CACurrentMediaTime();
                    }
                    firstPress = YES;
                    return;
                }
            }
        }
        
        lastCommand = CACurrentMediaTime();
        lastInput = key.input;
        lastModifierFlags = key.modifierFlags;
    }
}

@end

@implementation UIApplication (VZKeyCommands)

// Required for iOS 8.x
- (BOOL)RCT_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event
{
    if (action == @selector(RCT_handleKeyCommand:)) {
        [self RCT_handleKeyCommand:sender];
        return YES;
    } else if (action == @selector(RCT_handleDoublePressKeyCommand:)) {
        [self RCT_handleDoublePressKeyCommand:sender];
        return YES;
    }
    return [self RCT_sendAction:action to:target from:sender forEvent:event];
}

@end

@implementation VZKeyCommands

+ (void)initialize
{
    if (RCTIsIOS8OrEarlier()) {
        
        // swizzle UIApplication
        VZSwapInstanceMethods([UIApplication class],
                               @selector(keyCommands),
                               @selector(RCT_keyCommands));
        
        VZSwapInstanceMethods([UIApplication class],
                               @selector(sendAction:to:from:forEvent:),
                               @selector(RCT_sendAction:to:from:forEvent:));
    } else {
        
        // swizzle UIResponder
        VZSwapInstanceMethods([UIResponder class],
                               @selector(keyCommands),
                               @selector(RCT_keyCommands));
    }
}

+ (instancetype)sharedInstance
{
    static VZKeyCommands *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _commands = [NSMutableSet new];
    }
    return self;
}

- (void)registerKeyCommandWithInput:(NSString *)input
                      modifierFlags:(UIKeyModifierFlags)flags
                             action:(void (^)(UIKeyCommand *))block
{
    vz_isMainThread();
    
    if (input.length && flags && RCTIsIOS8OrEarlier()) {
        
        // Workaround around the first cmd not working: http://openradar.appspot.com/19613391
        // You can register just the cmd key and do nothing. This ensures that
        // command-key modified commands will work first time. Fixed in iOS 9.
        
        [self registerKeyCommandWithInput:@""
                            modifierFlags:flags
                                   action:nil];
    }
    
    UIKeyCommand *command = [UIKeyCommand keyCommandWithInput:input
                                                modifierFlags:flags
                                                       action:@selector(RCT_handleKeyCommand:)];
    
    VZKeyCommand *keyCommand = [[VZKeyCommand alloc] initWithKeyCommand:command block:block];
    [_commands removeObject:keyCommand];
    [_commands addObject:keyCommand];
}

- (void)unregisterKeyCommandWithInput:(NSString *)input
                        modifierFlags:(UIKeyModifierFlags)flags
{
    vz_isMainThread();
    
    for (VZKeyCommand *command in _commands.allObjects) {
        if ([command matchesInput:input flags:flags]) {
            [_commands removeObject:command];
            break;
        }
    }
}

- (BOOL)isKeyCommandRegisteredForInput:(NSString *)input
                         modifierFlags:(UIKeyModifierFlags)flags
{
    vz_isMainThread();
    
    for (VZKeyCommand *command in _commands) {
        if ([command matchesInput:input flags:flags]) {
            return YES;
        }
    }
    return NO;
}

- (void)registerDoublePressKeyCommandWithInput:(NSString *)input
                                 modifierFlags:(UIKeyModifierFlags)flags
                                        action:(void (^)(UIKeyCommand *))block
{
    vz_isMainThread();
    
    if (input.length && flags && RCTIsIOS8OrEarlier()) {
        
        // Workaround around the first cmd not working: http://openradar.appspot.com/19613391
        // You can register just the cmd key and do nothing. This ensures that
        // command-key modified commands will work first time. Fixed in iOS 9.
        
        [self registerDoublePressKeyCommandWithInput:@""
                                       modifierFlags:flags
                                              action:nil];
    }
    
    UIKeyCommand *command = [UIKeyCommand keyCommandWithInput:input
                                                modifierFlags:flags
                                                       action:@selector(RCT_handleDoublePressKeyCommand:)];
    
    VZKeyCommand *keyCommand = [[VZKeyCommand alloc] initWithKeyCommand:command block:block];
    [_commands removeObject:keyCommand];
    [_commands addObject:keyCommand];
}

- (void)unregisterDoublePressKeyCommandWithInput:(NSString *)input
                                   modifierFlags:(UIKeyModifierFlags)flags
{
    vz_isMainThread();
    
    for (VZKeyCommand *command in _commands.allObjects) {
        if ([command matchesInput:input flags:flags]) {
            [_commands removeObject:command];
            break;
        }
    }
}

- (BOOL)isDoublePressKeyCommandRegisteredForInput:(NSString *)input
                                    modifierFlags:(UIKeyModifierFlags)flags
{
    vz_isMainThread();
    
    for (VZKeyCommand *command in _commands) {
        if ([command matchesInput:input flags:flags]) {
            return YES;
        }
    }
    return NO;
}

@end
