//
//  VZInspectorHeapObjectGraphicView.m
//  VZInspector
//
//  Created by moxin on 15/5/21.
//  Copyright (c) 2015年 VizLab. All rights reserved.
//

#import "VZInspectorHeapObjectGraphicView.h"
#import "VZInspectorUtility.h"


@interface VZInspectorHeapObjectGraphicView()

@property(nonatomic,strong)UIImageView* imageView;

@end

@implementation VZInspectorHeapObjectGraphicView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageView];
        
    }
    return self;

}


- (void)draw
{
    NSAssert(self.referencedObjects.count <= 8, @"Too many objects!");
    
    int w = CGRectGetWidth(self.bounds)/3;
    int h = CGRectGetHeight(self.bounds)/3;
    
    //draw main image:
    UIImage *mainImage = [self mainObjectImage:(CGSize){w,h}];

    NSMutableArray* referencedImages = [NSMutableArray arrayWithCapacity:self.referencedObjects.count];
    
    for (int i=0; i<self.referencedObjects.count; i++) {
        
        VZInspectorHeapGraphicObject* obj = self.referencedObjects[i];
        UIImage* referencedImage = [self otherObject:obj Image:(CGSize){w,h}];
        [referencedImages addObject:referencedImage];
    }
   

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //draw mainImage
    vz_drawImageInRect(context, mainImage, CGRectMake(w, h, w, h));
    
    CGRect imgFrm = CGRectZero;
    for (int i=0; i<referencedImages.count; i++)
    {
        UIImage* img = referencedImages[i];
        
        if (i < 3) {
            
            imgFrm = CGRectMake(i*w, 0, w, h);
            vz_drawImageInRect(context, img, imgFrm);
            vz_drawDashLine(context, (CGPoint){w/2 + i*w,h}, (CGPoint){1.5*w,1.5*h});
            
        }
        else if (i==3)
        {
            imgFrm = CGRectMake(0, h, w, h);
            vz_drawImageInRect(context, img, imgFrm);
            vz_drawDashLine(context, (CGPoint){w,1.5*h},(CGPoint){1.5*w,1.5*h});
        }
        else if (i ==4)
        {
            imgFrm = CGRectMake(2*w, h, w, h);
            vz_drawImageInRect(context, img, imgFrm);
            vz_drawDashLine(context, (CGPoint){2*w,1.5*h},(CGPoint){1.5*w,1.5*h});
        }
        else
        {
            imgFrm = CGRectMake((i+1)%3 * w , 2*h, w, h);
            vz_drawImageInRect(context, img, imgFrm);
            vz_drawDashLine(context, (CGPoint){w/2 + i*w, 2*h},(CGPoint){1.5*w,1.5*h});
        }
        
    }
    //get image
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.imageView.image = image;
    });
}

- (void)clear
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (UIImage* )mainObjectImage:(CGSize)sz
{
    UIColor* color = [VZInspectorUtility blueColor];
    
    UIGraphicsBeginImageContextWithOptions(sz, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int w = sz.width;
    int h = sz.height;
    
    //draw rect border
    vz_drawRectBorder(context, CGRectMake(0, 0, w, h), color, 2.0);

    //address
    NSString* address = self.mainObject.address;
    [color set];
    vz_drawStringInRect(address, CGRectMake(0, (h/3-14)/2, w, h/3), [UIFont systemFontOfSize:14.0f]);

    //draw line
    vz_drawSingleLine(context, (CGPoint){0,h/3}, (CGPoint){w,h/3},color, 1.0);
    
    //draw class name
    NSString*  class = self.mainObject.className;
    vz_drawStringInRect(class, CGRectMake(0, h/3+10, w, 2*h/3), [UIFont systemFontOfSize:16.0f]);
    
    //get image
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage* )otherObject:(VZInspectorHeapGraphicObject* )obj Image:(CGSize)sz
{
    UIColor* color = [VZInspectorUtility themeColor];
    
    UIGraphicsBeginImageContextWithOptions(sz, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int w = sz.width;
    int h = sz.height;
    
    //draw rect border
    vz_drawRectBorder(context, CGRectMake(0, 0, w, h), color, 2.0);
    
    //address
    NSString* address = obj.address;
    [color set];
    vz_drawStringInRect(address, CGRectMake(0, (h/3-14)/2, w, h/3), [UIFont systemFontOfSize:14.0f]);
    
    //draw line
    vz_drawSingleLine(context, (CGPoint){0,h/3}, (CGPoint){w,h/3}, color, 1.0);
    
    
    //draw class name
    NSString*  class = obj.className;
    vz_drawStringInRect(class, CGRectMake(0, h/3, w, h/3), [UIFont systemFontOfSize:14.0f]);
    
    //draw line
    vz_drawSingleLine(context, (CGPoint){0,2*h/3}, (CGPoint){w,2*h/3}, color, 1.0);
    
    
    //draw ivar
    NSString* ivarName = obj.ivarName;
    vz_drawStringInRect(ivarName, CGRectMake(0, 2*h/3, w, h/3), [UIFont systemFontOfSize:14.0f]);
    
    //get image
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

//draw rect border
void NS_INLINE vz_drawRectBorder(CGContextRef context ,CGRect rect, UIColor* strokeColor, CGFloat strokeLineWidth)
{
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineWidth(context, strokeLineWidth);
    CGContextStrokeRect(context, rect);
}

//draw a line
void NS_INLINE vz_drawSingleLine(CGContextRef context, CGPoint startPt, CGPoint endPt,UIColor* strokeColor, CGFloat strokeLineWidth)
{
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextSetLineWidth(context, strokeLineWidth);
    CGContextSetShouldAntialias(context, NO );
    CGContextMoveToPoint(context, startPt.x+0.5, startPt.y+0.5);
    CGContextAddLineToPoint(context, endPt.x+0.5, endPt.y+0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

void NS_INLINE vz_drawStringInRect(NSString* str, CGRect rect, UIFont* font)
{
    CGSize sz = [str sizeWithFont:font constrainedToSize:rect.size];
    
    [str drawInRect:rect withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
}

void NS_INLINE vz_drawImageInRect(CGContextRef context,UIImage* img,CGRect rect)
{

    //CGContextScaleCTM (context, 0.7, 0.7);
    [img drawInRect:CGRectInset(rect, 10, 10)];
    //CGContextScaleCTM(context, 1.0, 1.0);
}

void NS_INLINE vz_drawDashLine(CGContextRef context,CGPoint startPt, CGPoint endPt)
{
    CGContextSaveGState(context);
    CGContextMoveToPoint(context, startPt.x+0.5, startPt.y+0.5);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [VZInspectorUtility themeColor].CGColor);
    CGFloat f[] = {2,3};
    CGContextSetLineDash(context, 0, f, 2) ;
    CGContextAddLineToPoint(context, endPt.x+0.5, endPt.y+0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

@end


@implementation VZInspectorHeapGraphicObject

@end
