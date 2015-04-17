//
//  VZToolboxView.m
//  VZInspector
//
//  Created by lingwan on 15/4/16.
//  Copyright (c) 2015年 VizLabe. All rights reserved.
//

#import "VZInspectorToolboxView.h"
#import <objc/runtime.h>

static const int kIconDimension = 48;

#define kButtonStatusKey @"VZButtonStatusKey"
#define VZImage(image) [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]

@interface VZInspectorToolboxView()<UITextFieldDelegate>

@property (nonatomic, strong) UITextView *consoleView;
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) NSMutableArray *logs;
@property(nonatomic,assign) NSInteger logMax;
@property(nonatomic,assign) CGRect oldFrm;

@property (nonatomic, strong) NSArray *buttonIconsArray;

@end

@implementation VZInspectorToolboxView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonIconsArray = @[VZImage(@"border"),
                                  VZImage(@"businessborder"),
                                  VZImage(@"sandbox"),
                                  VZImage(@"grid"),
                                  VZImage(@"crash"),
                                  VZImage(@"heap"),
                                  VZImage(@"warning")];
        
        float width = [UIScreen mainScreen].bounds.size.width / 4;
        float space = (width - kIconDimension) / 2;
        for (int i = 0; i < self.buttonIconsArray.count; i++) {
            float x = space + space * (i % 4) * 2 + (i % 4) * kIconDimension;
            float y = space + space * (int)(i / 4) * 2 + (int)(i / 4) * kIconDimension;
            CGRect frame = CGRectMake(x, y, kIconDimension, kIconDimension);
            
            UIButton *button = [[UIButton alloc] initWithFrame:frame];
            button.tintColor = [UIColor orangeColor];
            [button setImage:self.buttonIconsArray[i] forState:UIControlStateNormal];
            button.tag = i;
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            
            objc_setAssociatedObject(button, kButtonStatusKey, @0, OBJC_ASSOCIATION_COPY);
        }
    }
    return self;
}

//  @[VZImage(@"border"),
//VZImage(@"businessborder"),
//VZImage(@"sandbox"),
//VZImage(@"grid"),
//VZImage(@"crash"),
//VZImage(@"heap"),
//VZImage(@"warning")];
- (void)buttonPressed:(UIButton *)button {
    switch (button.tag) {
        case 0://border
        {
            NSNumber *status = objc_getAssociatedObject(button, kButtonStatusKey);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [self.parentViewController performSelector:@selector(showBorder:) withObject:status];
#pragma clang diagnostic pop
            if (status.integerValue == 0) {
                objc_setAssociatedObject(button, kButtonStatusKey, @1, OBJC_ASSOCIATION_COPY);
            } else {
                objc_setAssociatedObject(button, kButtonStatusKey, @0, OBJC_ASSOCIATION_COPY);
            }
            break;
        }
        case 1://business view's border and class name
        {
            NSNumber *status = objc_getAssociatedObject(button, kButtonStatusKey);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [self.parentViewController performSelector:@selector(showBusinessViewBorder:) withObject:status];
#pragma clang diagnostic pop
            if (status.integerValue == 0) {
                objc_setAssociatedObject(button, kButtonStatusKey, @1, OBJC_ASSOCIATION_COPY);
            } else {
                objc_setAssociatedObject(button, kButtonStatusKey, @0, OBJC_ASSOCIATION_COPY);
            }
            break;
        }
        case 2://sandbox
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [self.parentViewController performSelector:@selector(showSandBox) withObject:nil];
#pragma clang diagnostic pop
            break;
        case 3://grid
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [self.parentViewController performSelector:@selector(showGrid) withObject:nil];
#pragma clang diagnostic pop
            break;
        case 4://crash
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [self.parentViewController performSelector:@selector(showCrashLogs) withObject:nil];
#pragma clang diagnostic pop
        }
        case 5://heap
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [self.parentViewController performSelector:@selector(showHeap) withObject:nil];
#pragma clang diagnostic pop
        }
        case 6://warnning
        {
            [self.parentViewController setValue:@(YES) forKey:@"performMemoryWarning"];
        }
        case 7://network
        {
        }
        default:
            break;
    }
}

- (void)hideKeyboard
{
    [self.inputField  resignFirstResponder];
}

- (void)setConsoleText
{
    NSString *text = @"Let's Hack: See what you can do ?";
    text = [text stringByAppendingString:@"\n--------------------------------------\n"];
    text = [text stringByAppendingString:[[self.logs arrayByAddingObject:@">"] componentsJoinedByString:@"\n"]];
    _consoleView.text = text;
    
    [_consoleView scrollRangeToVisible:NSMakeRange(_consoleView.text.length, 0)];
}

- (void)keyboardWillShow:(NSNotification* )notification
{
    CGRect frame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve curve = [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView animateWithDuration:duration delay:0.0 options:(UIViewAnimationOptions)curve animations:^{
        
        self.inputField.frame = CGRectMake(self.inputField.frame.origin.x, frame.origin.y - 28 - 10, self.inputField.frame.size.width , self.inputField.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification* )notification
{
    CGFloat duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve curve = [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView animateWithDuration:duration delay:0.0 options:(UIViewAnimationOptions)curve animations:^{
        
        self.inputField.frame = CGRectMake(10,self.frame.size.height - 28 - 10 ,300,28);
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""])
    {
        [self log:textField.text];
        
        [self handleEnterText:textField.text];
        textField.text = @"";
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (void)log:(NSString *)format, ...
{
    va_list argList;
    va_start(argList,format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
    
    [self.logs addObject:[@">> " stringByAppendingString:message]];
    if ([self.logs count] > self.logMax)
    {
        [self.logs removeObjectAtIndex:0];
    }
    [self setConsoleText];
    
    va_end(argList);
    
}

- (void)handleEnterText:(NSString* )text
{
    //noop;
    if ([text isEqualToString:@"exit"]) {
        
        UIButton* btn = [UIButton new];
        btn.tag = 10;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.parentViewController performSelector:@selector(onBtnClikced:) withObject:btn];
#pragma clang diagnostic pop
        
    }
    else if([text isEqualToString:@"version"])
    {
        //[self log:[TBCityGlobal version]];
    }
    else if ([text isEqualToString:@"grid"])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.parentViewController performSelector:@selector(showGrid) withObject:nil];
#pragma clang diagnostic pop
        
    }
    else if ([text isEqualToString:@"border"])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.parentViewController performSelector:@selector(showBorder) withObject:nil];
#pragma clang diagnostic pop
    }
    else if ([text isEqualToString:@"crash"])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.parentViewController performSelector:@selector(showCrashLogs) withObject:nil];
#pragma clang diagnostic pop
    }
    else if ([text isEqualToString:@"heap"])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.parentViewController performSelector:@selector(showHeap) withObject:nil];
#pragma clang diagnostic pop
    }
    else if ([text isEqualToString:@"sandbox"])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.parentViewController performSelector:@selector(showSandBox) withObject:nil];
#pragma clang diagnostic pop
    }
    else if ([text isEqualToString:@"mw on"])
    {
        [self.parentViewController setValue:@(YES) forKey:@"performMemoryWarning"];
        
    }
    else if ([text isEqualToString:@"mw off"])
    {
        [self.parentViewController setValue:@(NO) forKeyPath:@"performMemoryWarning"];
    }
    
    else if ([text isEqualToString:@"network"])
    {
        [self.parentViewController performSelector:@selector(showNetwork) withObject:nil];
    }
    
    else if ([text isEqualToString:@"help"])
    {
        [self log:@"try:\n exit \n sandbox \n grid \n border \n crashes \n heap \n mw on \n mw off \n"];
        
    }
    else
    {
        [self log:@"try something else..."];
    }
}
@end
