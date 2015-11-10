//
//  O2OMethodTraceInputView.m
//  VZInspector
//
//  Created by lingwan on 10/29/15.
//  Copyright © 2015 VizLab. All rights reserved.
//

#import "O2OMethodTraceInputView.h"

#define kMethodTraceInputViewPadding 16

#define kCandidateFontSize 16
#define kCandidatePadding 12
#define kCandidateAreaHeight 32
#define kO2OMethodTraceScreenWidth [UIScreen mainScreen].bounds.size.width

@interface O2OMethodTraceInputView () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSDictionary *inputHint;
@end

@implementation O2OMethodTraceInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, 240, 102)];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(kMethodTraceInputViewPadding, kMethodTraceInputViewPadding, self.frame.size.width - kMethodTraceInputViewPadding * 2, 30)];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.delegate = self;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kO2OMethodTraceScreenWidth, kCandidateAreaHeight)];
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.contentSize = CGSizeMake(kO2OMethodTraceScreenWidth, kCandidateAreaHeight);
        _textField.inputAccessoryView = scrollView;
        [self addSubview:_textField];
        
        _inputHint = @{@"v" : @[@"ViewController", @"View"],
                       @"l" : @[@"ListViewController", @"ListModel", @"ListCell", @"ListItem", @"ListView"],
                       @"t" : @[@"TableViewController", @"TableView"],
                       @"m" : @[@"Model"],
                       @"c" : @[@"Controller", @"Cell"],
                       @"o" : @[@"O2O"]};
        
        CGFloat buttonWidth = (self.frame.size.width - kMethodTraceInputViewPadding * 3) / 2;
        
        UIButton *cancel = [self customButton];
        [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        cancel.frame = CGRectMake(kMethodTraceInputViewPadding, _textField.frame.origin.y + _textField.frame.size.height + kMethodTraceInputViewPadding, buttonWidth, 24);
        [cancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancel];
        
        UIButton *ok = [self customButton];
        [ok setTitle:@"OK" forState:UIControlStateNormal];
        ok.frame = CGRectMake(self.frame.size.width - kMethodTraceInputViewPadding - buttonWidth, _textField.frame.origin.y + _textField.frame.size.height + kMethodTraceInputViewPadding, buttonWidth, 24);
        [ok addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:ok];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if ([self.textField canBecomeFirstResponder]) {
        [self.textField becomeFirstResponder];
    }
}

- (UIButton *)customButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIColor *color = [UIColor colorWithWhite:1 alpha:0.7];
    [button setTitleColor:color forState:UIControlStateNormal];
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = 1.f;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    
    return button;
}

- (void)updateInputAccessoryView:(UIScrollView *)accessoryView candidates:(NSArray *)candidates {
    [accessoryView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            [obj removeFromSuperview];
        }
    }];
    
    CGFloat right = 0;
    UIButton *button;
    for (int i = 0; i < candidates.count; i++) {
        NSString *title = candidates[i];
        if (title.length) {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat titleWidth = [title boundingRectWithSize:CGSizeMake(300, kCandidateAreaHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCandidateFontSize]} context:nil].size.width;
            button.frame = CGRectMake(right, 0, titleWidth + kCandidatePadding * 2, kCandidateAreaHeight);
            [button setTitle:title forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:kCandidateFontSize];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(candidateSelected:) forControlEvents:UIControlEventTouchUpInside];
            [accessoryView addSubview:button];
            
            UIView *seperation = [[UIView alloc] initWithFrame:CGRectMake(button.frame.size.width - 0.5, 0, 0.5, button.frame.size.height)];
            seperation.backgroundColor = [UIColor lightGrayColor];
            seperation.alpha = 0.6;
            [button addSubview:seperation];
            
            right += button.frame.size.width;
        }
    }
    
    CGFloat contentWidth = button.frame.origin.x + button.frame.size.width;
    if (contentWidth < kO2OMethodTraceScreenWidth) {
        contentWidth = kO2OMethodTraceScreenWidth;
    }
    
    accessoryView.contentSize = CGSizeMake(contentWidth, kCandidateAreaHeight);
}

- (void)candidateSelected:(UIButton *)button {
    NSString *text = button.titleLabel.text;
    NSString *originText = self.textField.text;
    if (originText.length) {
        originText = [originText substringToIndex:originText.length - 1];
        originText = [originText stringByAppendingString:text];
        self.textField.text = originText;
    } else {
        self.textField.text = text;
    }
}

- (void)cancel {
    [self.textField resignFirstResponder];
    [self removeFromSuperview];
}

- (void)ok {
    NSString *className = self.textField.text;
    [self.textField resignFirstResponder];
    
    if (self.showTraceViewBlock) {
        self.showTraceViewBlock(className);
    }
    
    [self removeFromSuperview];
}

# pragma mark -  UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    string = [string lowercaseString];
    NSArray *candidates = [self.inputHint objectForKey:string];
    if (candidates.count) {
        UIScrollView *accessoryView = (UIScrollView *)textField.inputAccessoryView;
        [self updateInputAccessoryView:accessoryView candidates:candidates];
    }
    
    return YES;
}

@end
