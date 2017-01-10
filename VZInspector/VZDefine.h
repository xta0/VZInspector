//
//  VZDefine.h
//  VZInspector
//
//  Created by John Wong on 8/3/15.
//  Copyright (c) 2015 VizLab. All rights reserved.
//

#import <UIKit/UIKit.h>

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)
#define flessthan(a,b) (fabs(a) < fabs(b)+FLT_EPSILON)

/**
 * 用一个24位的整数生成UIColor
 * 这个方法实现如下，只会返回不透明的颜色
 return [UIColor colorWithRed:((rgb & 0xFF0000) >> 16) / 255.0f
 green:((rgb & 0xFF00) >> 8) / 255.0f
 blue:((rgb & 0xFF)) / 255.0f
 alpha:1.0f];
 * @param rgb 形如0xRRGGBB
 */
#define VZ_RGBA( rgb , a)  [UIColor colorWithRed:((rgb & 0xFF0000) >> 16 ) / 255.0f green:((rgb & 0xFF00) >> 8)/255.0f blue:((rgb & 0xFF)) / 255.0f alpha:a ]
#define VZ_RGB(rgb)  VZ_RGBA(rgb ,1.0f )

#define VZ_INSPECTOR_MAIN_COLOR VZ_RGB(0xfd8023)


#define screen_width [UIScreen mainScreen].bounds.size.width

#define VZ_TextSizeFrame(text , fontSize) [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]} context:nil].size

#define vz_IsStringValid(_str) (_str && [_str isKindOfClass:[NSString class]] && ([_str length] > 0))
#define vz_IsArrayValid(_array) (_array && [_array isKindOfClass:[NSArray class]] && ([_array count] > 0))
#define vz_IsDictionaryValid(__dic) (__dic && [__dic isKindOfClass:[NSDictionary class]] && ([__dic count] > 0))

#define kOnePix (1.0f/[UIScreen mainScreen].scale)

