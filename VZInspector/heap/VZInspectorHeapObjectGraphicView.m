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

@end

@implementation VZInspectorHeapObjectGraphicView


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
    

    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect mainRect = (CGRect){w,h,w,h};
        UIImageView* mainImageV = [[UIImageView alloc]initWithFrame:mainRect];
        mainImageV.transform = CGAffineTransformMakeScale(0.7, 0.7);
        mainImageV.image = mainImage;
        [self addSubview:mainImageV];
        
         for (int i=0; i<referencedImages.count; i++)
         {
             UIImage* img = referencedImages[i];
             UIImageView* v = [UIImageView new];
             v.image = img;
             if (i < 3) {
                 
                 v.frame = CGRectMake(i*w, 0, w, h);
             }
             else if (i==3)
             {
                 
                 v.frame = CGRectMake(0, h, w, h);
             }
             else if (i ==4)
             {
                 v.frame = CGRectMake(2*w, h, w, h);
             }
             else
             {
                 v.frame = CGRectMake((i+1)%3 * w , 2*h, w, h);
             }
              v.transform = CGAffineTransformMakeScale(0.7, 0.7);
             [self addSubview:v];
         }
        
        //connect all images
        
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

@end


@implementation VZInspectorHeapGraphicObject

@end
