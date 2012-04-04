//
//  UIColor-HSB.h
//
//  Created by Bill Shirley on 11/23/11.
//

#import <UIKit/UIKit.h>

@interface UIColor (HSB)

- (BOOL)canProvideHSBComponents;
- (BOOL)getHue:(CGFloat *)h saturation:(CGFloat *)s brightness:(CGFloat *)v alpha:(CGFloat *)a;
- (CGFloat)hue;
- (CGFloat)saturation;
- (CGFloat)brightness;

@end
