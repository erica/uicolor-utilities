/*
 
 Thanks to Poltras, Millenomi, Eridius, Nownot, WhatAHam, jberry,
 and everyone else who helped out but whose name is inadvertantly omitted
 
 */

/*
 Current outstanding request list:
 
 - PolarBearFarm - color descriptions ([UIColor warmGrayWithHintOfBlueTouchOfRedAndSplashOfYellowColor])
 - Eridius - UIColor needs a method that takes 2 colors and gives a third complementary one
 - Consider UIMutableColor that can be adjusted (brighter, cooler, warmer, thicker-alpha, etc)
 */


#import <UIKit/UIKit.h>

@interface UIColor (UIColor_Expanded)

+ (NSString *) colorSpaceString: (CGColorSpaceModel) model;
@property (nonatomic, readonly) NSString *colorSpaceString;
@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;
@property (nonatomic, readonly) BOOL canProvideRGBComponents;
@property (nonatomic, readonly) BOOL usesMonochromeColorspace;
@property (nonatomic, readonly) BOOL usesRGBColorspace;

// Color conversion
+ (void) hue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)v toRed:(CGFloat *)pR green:(CGFloat *)pG blue:(CGFloat *)pB;
+ (void) red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b toHue:(CGFloat *)pH saturation:(CGFloat *)pS brightness:(CGFloat *)pV;
void RGB2YUV_f(CGFloat r, CGFloat g, CGFloat b, CGFloat *y, CGFloat *u, CGFloat *v);
void YUV2RGB_f(CGFloat y, CGFloat u, CGFloat v, CGFloat *r, CGFloat *g, CGFloat *b);

// Bulk access to RGB and HSB components of the color
// HSB components are converted from the RGB components
- (BOOL) red:(CGFloat *)r green:(CGFloat *)g blue:(CGFloat *)b alpha:(CGFloat *)a;
- (BOOL) hue:(CGFloat *)h saturation:(CGFloat *)s brightness:(CGFloat *)b alpha:(CGFloat *)a;

void RGB2YUV_f(CGFloat r,CGFloat g,CGFloat b,CGFloat *y,CGFloat *u,CGFloat *v);
void YUV2RGB_f(CGFloat y,CGFloat u,CGFloat v,CGFloat *r,CGFloat *g,CGFloat *b);

// Component Access
// With the exception of -alpha, these properties will function
// correctly only if this color is an RGB or white color.
// In these cases, canProvideRGBComponents returns YES.
@property (nonatomic, readonly) CGFloat red;
@property (nonatomic, readonly) CGFloat green;
@property (nonatomic, readonly) CGFloat blue;
@property (nonatomic, readonly) CGFloat white;
@property (nonatomic, readonly) CGFloat hue;
@property (nonatomic, readonly) CGFloat saturation;
@property (nonatomic, readonly) CGFloat brightness;
@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) CGFloat luminance;
@property (nonatomic, readonly) UInt32 rgbHex;
- (NSArray *)arrayFromRGBAComponents;

// Return a grey-scale representation of the color
- (UIColor *) colorByLuminanceMapping;

// Color Distance
- (CGFloat) luminanceDistanceFrom: (UIColor *) anotherColor;
- (CGFloat) distanceFrom: (UIColor *) anotherColor;

// Arithmetic operations on the color
- (UIColor *) colorByMultiplyingByRed: (CGFloat) red green: (CGFloat) green blue: (CGFloat) blue alpha: (CGFloat) alpha;
- (UIColor *)        colorByAddingRed: (CGFloat) red green: (CGFloat) green blue: (CGFloat) blue alpha: (CGFloat) alpha;
- (UIColor *)  colorByLighteningToRed: (CGFloat) red green: (CGFloat) green blue: (CGFloat) blue alpha: (CGFloat) alpha;
- (UIColor *)   colorByDarkeningToRed: (CGFloat) red green: (CGFloat) green blue: (CGFloat) blue alpha: (CGFloat) alpha;

- (UIColor *) colorByMultiplyingBy: (CGFloat) f;
- (UIColor *)        colorByAdding: (CGFloat) f;
- (UIColor *)  colorByLighteningTo: (CGFloat) f;
- (UIColor *)   colorByDarkeningTo: (CGFloat) f;

- (UIColor *) colorByMultiplyingByColor: (UIColor *) color;
- (UIColor *)        colorByAddingColor: (UIColor *) color;
- (UIColor *)  colorByLighteningToColor: (UIColor *) color;
- (UIColor *)   colorByDarkeningToColor: (UIColor *) color;

- (UIColor *)colorByInterpolatingToColor:(UIColor *)color byFraction:(CGFloat)fraction;

// Related colors
- (UIColor *) contrastingColor;			// A good contrasting color: will be either black or white
- (UIColor *) complementaryColor;		// A complementary color that should look good with this color
- (NSArray *)triadicColors;				// Two colors that should look good with this color
- (NSArray *)analogousColorsWithStepAngle: (CGFloat) stepAngle pairCount: (int)pairs;	// Multiple pairs of colors

// String support
@property (nonatomic, readonly) NSString *stringValue;
@property (nonatomic, readonly) NSString *hexStringValue;
+ (UIColor *) colorWithString: (NSString *) string;
+ (UIColor *) colorWithHexString: (NSString *)stringToConvert;
+ (UIColor *) colorWithRGBHex: (UInt32)hex;

// Random Color
+ (UIColor *) randomColor;
+ (UIColor *) randomDarkColor : (CGFloat) scaleFactor;
+ (UIColor *) randomLightColor : (CGFloat) scaleFactor;
@end

@interface UIColor (NamedColors)
+ (NSArray *) availableColorDictionaries;
+ (NSDictionary *) colorDictionaryNamed: (NSString *) dictionaryName;

+ (UIColor *) colorWithName: (NSString *) name inDictionary: (NSString *) dictionaryName;
+ (UIColor *) colorWithName: (NSString *) name;

- (NSString *) closestColorNameUsingDictionary: (NSString *) dictionaryName;

@property (nonatomic, readonly) NSString *closestColorName;
@property (nonatomic, readonly) NSString *closestCrayonName;
@property (nonatomic, readonly) NSString *closestWikipediaColorName;
@property (nonatomic, readonly) NSString *closestCSSName;
@property (nonatomic, readonly) NSString *closestBaseName;
@property (nonatomic, readonly) NSString *closestSystemColorName;

@property (nonatomic, readonly) UIColor *closestMensColor;

+ (UIColor *) crayonWithName: (NSString *) crayonName;
+ (UIColor *) baseColorWithName: (NSString *) name;
+ (UIColor *) cssColorWithName: (NSString *) name;
+ (UIColor *) systemColorWithName: (NSString *) name;
@end
