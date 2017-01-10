
//
//  VZColorDisplayView.m
//  APInspector
//
//  Created by pep on 2016/12/3.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "VZColorDisplayView.h"
#import "VZColorPickerDefine.h"

typedef NS_ENUM(NSInteger, VZColorAnchorImageStyle) {
    VZColorAnchorImageStyleWhite = 0, //默认的
    VZColorAnchorImageStyleBlack
};

@interface VZColorDisplayView()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *anchorImageView;
@property (nonatomic, assign) VZColorAnchorImageStyle anchorImageStyle;
@property (nonatomic, strong) UILabel *colorLabel;

@end

@implementation VZColorDisplayView

+ (instancetype)displayViewWithRadius:(CGFloat)r scale:(NSUInteger)scale {
    return [[self alloc] initWithRadius:r scale:scale];
}


- (id)initWithRadius:(CGFloat)r scale:(NSUInteger)scale {
    self = [self initWithFrame:CGRectMake(0, 0, r, r)];
    if (self) {
        CGFloat screenScale = [self screenScale];
        //四舍五入,确保是奇数个
        if ((NSInteger)floor(r * screenScale + 0.5) % 2 == 0 && screenScale != 0) {
            r += 1.0 / screenScale;
        }
        
        self.frame = CGRectMake(0, 0, r, r);
        
        _scale = scale >= 1 ? scale : 1;
        
        self.layer.borderWidth = 6;
        self.layer.cornerRadius = r * 0.5;
        self.clipsToBounds = YES;
        self.backgroundColor =[UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        imageView.image = [self anchorImage];
        self.anchorImageView = imageView;
        
        self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ceil(self.frame.size.height * 0.2), self.frame.size.width, ceil(self.frame.size.height * 0.25))];
        self.colorLabel.textAlignment = NSTextAlignmentCenter;
        self.colorLabel.font = [UIFont systemFontOfSize:ceil(self.frame.size.height * 0.06)];
        self.colorLabel.backgroundColor = [UIColor clearColor];
        self.colorLabel.textColor = [UIColor blackColor];
        [self addSubview:self.colorLabel];
        
    }
    return self;
}

- (void)update {
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    //整像素点
    CGRect rect = [keyWindow convertRect:self.frame fromWindow:self.window];
    CGFloat scale = [[UIScreen mainScreen] scale];
    //整像素点，四舍五入
    rect.origin.x = floor(rect.origin.x * scale + 0.5) / scale;
    rect.origin.y = floor(rect.origin.y * scale + 0.5) / scale;
#define IS_EVEN(value) ((NSInteger)floor(value + 0.5) % 2 == 0)
    //如果像素数是偶数减去一个像素
    rect.size.width = floor(0.5 + rect.size.width * scale - (IS_EVEN(rect.size.width * scale) ? 1 : 0)) / scale;
    rect.size.height = floor(0.5 + rect.size.height * scale - (IS_EVEN(rect.size.height * scale) ? 1 : 0)) / scale;
#undef IS_EVEN
    
    CGSize size = rect.size;
    UIGraphicsBeginImageContextWithOptions(size, keyWindow.opaque, scale);
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationNone);

#define PIXEL_ALIGN(value) (floor((value) * scale) / scale)

    //四舍五入
    CGRect drawRect = CGRectMake(-PIXEL_ALIGN(rect.origin.x * _scale + size.width * 0.5  * (_scale - 1)) , -PIXEL_ALIGN(rect.origin.y * _scale + size.height * 0.5  * (_scale - 1)), PIXEL_ALIGN(keyWindow.frame.size.width * _scale), PIXEL_ALIGN(keyWindow.frame.size.height * _scale));
                             
    [keyWindow drawViewHierarchyInRect:drawRect afterScreenUpdates:NO];
    
    
#undef PIXEL_ALIGN
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //没有取到就丢失
    if (img) {
        self.imageView.image = img;
    }
    
    UIColor *centerColor = [self centerColorOfimage:img];
    if (centerColor) {
        self.layer.borderColor = centerColor.CGColor;
        
        CGFloat red = 0;
        CGFloat green = 0;
        CGFloat blue = 0;
        CGFloat alpha = 0;
        [centerColor getRed:&red green:&green blue:&blue alpha:&alpha];
        self.colorLabel.text = [NSString stringWithFormat:@"r:%.2f g:%.2f b:%.2f a:%.2f",red, green, blue, alpha];
        
        
        VZColorAnchorImageStyle preStyle = self.anchorImageStyle;
        if (red + green + blue > 1.5) {
            self.anchorImageStyle = VZColorAnchorImageStyleBlack;
        } else {
            self.anchorImageStyle = VZColorAnchorImageStyleWhite;
        }
        
        if (preStyle != self.anchorImageStyle) {
            [self updateAnchorImage];
        }
        
        if ([self.delegate respondsToSelector:@selector(displayView:colorDidUpdate:)]) {
            [self.delegate displayView:self colorDidUpdate:centerColor];
        }
    }
}

- (void)setScale:(NSUInteger)scale {
    if (scale < kVZCPMinZoomValue) {
        scale = kVZCPMinZoomValue;
    }
    
    if (scale == _scale) {
        return;
    }
    
    _scale = scale;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateAnchorImage];
        [self update];
    });
    
    
}

- (NSString *)colorString:(UIColor *)color {
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return [NSString stringWithFormat:@"r:%.2f g:%.2f b:%.2f a:%.2f",red, green, blue, alpha];
}

- (CGFloat)screenScale {
    return [UIScreen mainScreen].scale;
}


- (void)updateAnchorImage {
    self.anchorImageView.image = [self anchorImage];
}

- (UIImage *)anchorImage {
//    CGFloat screenScale = [self screenScale];
//    
//    CGFloat length = 2 + _scale; //pixel
//    CGSize size = CGSizeMake(ceil(length / screenScale), ceil(length / screenScale)); //point
//    UIGraphicsBeginImageContextWithOptions(size, NO, screenScale);
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
//    
//    CGFloat lineWidth = 1.0 / screenScale; //point
//    CGContextSetLineWidth(context, lineWidth);
//    
//    
//    CGRect rect = CGRectMake(size.width * 0.5 - lineWidth - 0.5 * _scale / screenScale, size.height * 0.5 - lineWidth - 0.5 * _scale / screenScale, (_scale + lineWidth * 2) / screenScale, (_scale + lineWidth * 2) / screenScale);
//    
//    CGContextStrokeRect(context, rect);
//    
//
//    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    return img;
    
    
    CGFloat screenScale = [UIScreen mainScreen].scale;

    //以下单位都是point
    CGFloat lineWidth = 1.0 / screenScale;
    CGFloat length = 2 * lineWidth + _scale / screenScale; //pixel
    CGSize size = CGSizeMake(length, length);
    
    CGSize viewSize = self.frame.size;
    viewSize.width = floor(viewSize.width * screenScale + 0.5) / screenScale;
    viewSize.height = floor(viewSize.height * screenScale + 0.5) / screenScale;
    
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, screenScale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetAllowsAntialiasing(context,NO);
    
    //默认黑色
    CGColorRef lineColor = self.anchorImageStyle == VZColorAnchorImageStyleWhite ? [UIColor whiteColor].CGColor : [UIColor blackColor].CGColor;
    
    
    CGContextSetStrokeColorWithColor(context, lineColor);
    
    CGContextSetLineWidth(context, lineWidth);
    
    
    //四舍五入
#define PIXEL_ALIGN(value) (floor((value) * screenScale + 0.5) / screenScale)
    
    CGFloat x = viewSize.width * 0.5 - _scale * 0.5 / screenScale - lineWidth;
    x = PIXEL_ALIGN(x) + lineWidth * 0.5; //抗锯齿
    CGFloat y = viewSize.height * 0.5 - _scale * 0.5 / screenScale - lineWidth;
    y = PIXEL_ALIGN(y) + lineWidth * 0.5; //抗锯齿
    
    CGRect rect = CGRectMake(x, y, PIXEL_ALIGN(size.width - lineWidth), PIXEL_ALIGN(size.height - lineWidth));
    
    CGContextStrokeRectWithWidth(context, rect, lineWidth);
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
#undef PIXEL_ALIGN
    
    
    return [UIImage imageWithData:UIImagePNGRepresentation(img) scale:[self screenScale]];

}

- (UIColor *)centerColorOfimage:(UIImage *)image {
    if (!image) {
        return [UIColor clearColor];
    }
    
    
    NSUInteger width = image.size.width * image.scale;
    NSUInteger height = image.size.height * image.scale;
    
    //中间点，从0开始
    
    NSInteger pointX = floor(width * 0.5 * image.scale) / image.scale;
    NSInteger pointY = floor(height * 0.5 * image.scale) / image.scale;
    CGImageRef cgImage = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextScaleCTM(context, image.scale, image.scale);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, -pointY);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


@end
