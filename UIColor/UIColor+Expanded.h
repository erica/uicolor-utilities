// Erica Sadun 

// Thanks to Poltras, Millenomi, Eridius, Nownot, WhatAHam, jberry,
// and everyone else who helped out but whose name is inadvertantly omitted

/*
 BSD License.
 
 This work 'as-is' I provide.
 No warranty express or implied.
 I've done my best,
 to debug and test.
 Liability for damages denied.
 
 Licensing is quite a chore.
 The paperwork's really a bore.
 The lawyers they laugh;
 Of profits, take half
 And leave me distraught to the core.
 */

/*
 Current outstanding request list: (NONE)
 
 Requests recently added:
 Layton at PolarBearFarm - color descriptions 
    e.g. ([UIColor warmGrayWithHintOfBlueTouchOfRedAndSplashOfYellowColor])
 Added: Auto color descriptions, especially using xkcd 
 
 Kevin / Eridius 
 UIColor needs a method that takes 2 colors and gives a third complementary one
 new kevinColorWithColor: method

 Adjustable colors: brighter, cooler, warmer, etc.
 Added: Various tweakers, warmth property, temperature stuff 
 */


#import <UIKit/UIKit.h>

@interface UIColor (UIColor_Expanded)

#pragma mark - Color Wheel
+ (UIImage *) colorWheelOfSize: (CGFloat) side border:(BOOL) yorn;

#pragma mark - Color Space
+ (NSString *) colorSpaceString: (CGColorSpaceModel) model;
@property (nonatomic, readonly) NSString *colorSpaceString;
@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;
@property (nonatomic, readonly) BOOL canProvideRGBComponents;
@property (nonatomic, readonly) BOOL usesMonochromeColorspace;
@property (nonatomic, readonly) BOOL usesRGBColorspace;

#pragma mark - Color Conversion
+ (void) hue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)v toRed:(CGFloat *)pR green:(CGFloat *)pG blue:(CGFloat *)pB;
+ (void) red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b toHue:(CGFloat *)pH saturation:(CGFloat *)pS brightness:(CGFloat *)pV;
void RGB2YUV_f(CGFloat r, CGFloat g, CGFloat b, CGFloat *y, CGFloat *u, CGFloat *v);
void YUV2RGB_f(CGFloat y, CGFloat u, CGFloat v, CGFloat *r, CGFloat *g, CGFloat *b);

//  public domain functions by Darel Rex Finley, 2006
void RGBtoHSP(CGFloat  R, CGFloat  G, CGFloat  B, CGFloat *H, CGFloat *S, CGFloat *P);
void HSPtoRGB(CGFloat  H, CGFloat  S, CGFloat  P, CGFloat *R, CGFloat *G, CGFloat *B);
@property (nonatomic, readonly) CGFloat perceivedBrightness;

#pragma mark - Color Components
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

#pragma mark - Alternative Expression
@property (nonatomic, readonly) CGFloat colorfulness;
@property (nonatomic, readonly) CGFloat warmth;

#pragma mark - Building
// Build colors by comparison
- (UIColor *) adjustWarmth: (CGFloat) delta;
- (UIColor *) adjustBrightness: (CGFloat) delta;
- (UIColor *) adjustSaturation: (CGFloat) delta;
- (UIColor *) adjustHue: (CGFloat) delta;

#pragma mark - Sorting
// Sorting -- Natural sorting choices
- (NSComparisonResult) compareWarmth: (UIColor *) anotherColor;
- (NSComparisonResult) compareColorfulness: (UIColor *) anotherColor;
- (NSComparisonResult) compareHue: (UIColor *) anotherColor;
- (NSComparisonResult) compareSaturation: (UIColor *) anotherColor;
- (NSComparisonResult) compareBrightness: (UIColor *) anotherColor;

#pragma mark - Distance
// Color Distance
- (CGFloat) luminanceDistanceFrom: (UIColor *) anotherColor;
- (CGFloat) distanceFrom: (UIColor *) anotherColor;
- (BOOL) isEqualToColor: (UIColor *) anotherColor;

#pragma mark - Math
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

- (UIColor *) kevinColorWithColor: (UIColor *) secondColor; // see Eridius request

#pragma mark - Strings
// String support
@property (nonatomic, readonly) NSString *stringValue;
@property (nonatomic, readonly) NSString *hexStringValue;
+ (UIColor *) colorWithString: (NSString *) string;
+ (UIColor *) colorWithHexString: (NSString *)stringToConvert;
+ (UIColor *) colorWithRGBHex: (UInt32)hex;

#pragma mark - Temperature
// Temperature support -- preliminary
+ (UIColor *) colorWithKelvin: (CGFloat) kelvin;
+ (NSDictionary *) kelvinDictionary;
@property (nonatomic, readonly) CGFloat colorTemperature;

#pragma mark - Random
// Random Color
+ (UIColor *) randomColor;
+ (UIColor *) randomDarkColor : (CGFloat) scaleFactor;
+ (UIColor *) randomLightColor : (CGFloat) scaleFactor;
@end

#pragma mark - Named Colors
@interface UIColor (NamedColors)
+ (NSArray *) availableColorDictionaries;
+ (NSDictionary *) colorDictionaryNamed: (NSString *) dictionaryName;

+ (UIColor *) colorWithName: (NSString *) name inDictionary: (NSString *) dictionaryName;
+ (UIColor *) colorWithName: (NSString *) name;

- (NSString *) closestColorNameUsingDictionary: (NSString *) dictionaryName;

- (NSDictionary *) closestColors;
@property (nonatomic, readonly) NSString *closestColorName;
@property (nonatomic, readonly) NSString *closestCrayonName;
@property (nonatomic, readonly) NSString *closestWikipediaColorName;
@property (nonatomic, readonly) NSString *closestCSSName;
@property (nonatomic, readonly) NSString *closestBaseName;
@property (nonatomic, readonly) NSString *closestSystemColorName;
@property (nonatomic, readonly) UIColor  *closestMensColor;
@end
