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

 */

/*
 
 Warning: -getRed:green:blue:alpha: not valid for the NSColor NSNamedColorSpace System controlLightHighlightColor; need to first convert colorspace.
 May not work well with developer colors
 
 */

#import <Foundation/Foundation.h>
@interface NSView (OSXBGColorExtension)
@property (nonatomic, weak) NSColor *backgroundColor;
@end

// Web color
#define RGBCOLOR(_R_, _G_, _B_) [NSColor colorWithDeviceRed:(CGFloat)(_R_)/255.0f green: (CGFloat)(_G_)/255.0f blue: (CGFloat)(_B_)/255.0f alpha: 1.0f]

// Color Space
CGColorSpaceRef DeviceRGBSpace();
CGColorSpaceRef DeviceGraySpace();

@interface NSColor (OSXColorExtensions)

// Color Space
@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;
@property (nonatomic, readonly) BOOL canProvideRGBComponents;
@property (nonatomic, readonly) BOOL usesMonochromeColorspace;
@property (nonatomic, readonly) BOOL usesRGBColorspace;
@property (nonatomic, readonly) NSString *colorSpaceString;

+ (NSString *) colorSpaceString: (CGColorSpaceModel) model;

@property (nonatomic, readonly) CGFloat red;
@property (nonatomic, readonly) CGFloat green;
@property (nonatomic, readonly) CGFloat blue;

@property (nonatomic, readonly) CGFloat premultipliedRed;
@property (nonatomic, readonly) CGFloat premultipliedGreen;
@property (nonatomic, readonly) CGFloat premultipliedBlue;

@property (nonatomic, readonly) CGFloat white;
@property (nonatomic, readonly) CGFloat luminance;

@property (nonatomic, readonly) CGFloat hue;
@property (nonatomic, readonly) CGFloat saturation;
@property (nonatomic, readonly) CGFloat brightness;

@property (nonatomic, readonly) CGFloat alpha;

// Distance
- (CGFloat) luminanceDistanceFrom: (NSColor *) anotherColor;
- (CGFloat) distanceFrom: (NSColor *) anotherColor;
- (BOOL) isEqualToColor: (NSColor *) anotherColor;

// Related colors
@property (nonatomic, readonly) NSColor *contrastingColor;
@property (nonatomic, readonly) NSColor *complementaryColor;

// Strings
+ (NSColor *) colorWithRGBHex: (UInt32)hex;
+ (NSColor *) colorWithHexString: (NSString *)stringToConvert;
@property (nonatomic, readonly) NSString *hexStringValue;

+ (NSArray *) availableColorDictionaries;
+ (NSDictionary *) colorDictionaryNamed: (NSString *) dictionaryName;

+ (NSColor *) colorWithName: (NSString *) name inDictionary: (NSString *) dictionaryName;
+ (NSColor *) colorWithName: (NSString *) name;

- (NSString *) closestColorNameUsingDictionary: (NSString *) dictionaryName;
@property (nonatomic, readonly) NSString *closestColorName;

+ (NSArray *) closeColorNamesMatchingKeys: (NSArray *) keys;
+ (NSArray *) colorNames;
@end