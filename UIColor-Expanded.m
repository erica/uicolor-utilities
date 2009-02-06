#import "UIColor-Expanded.h"

/*
 
 Thanks to Poltras, Millenomi, Eridius, Nownot, WhatAHam, 
 and everyone else who helped out but whose name is inadvertantly omitted
 
*/

/*
 Current outstanding request list:
 
 - August Joki - CSS named color set 
 - PolarBearFarm - color descriptions ([UIColor warmGrayWithHintOfBlueTouchOfRedAndSplashOfYellowColor])
 - Crayola color set
 - T Hillerson - Random Colors ([UIColor pickSomethingNice])
 - Eridius - UIColor needs a method that takes 2 colors and gives a third complementary one
 - Monochromization (something like 0.45 red + 0.35 green + 0.2 blue, what's the best formula?)
 - Eridius - colorWithHex:(NSInteger)hex, e.g. [UIColor colorWithHex:0xaabbcc]
 - Consider UIMutableColor that can be adjusted (brighter, cooler, warmer, thicker-alpha, etc)
 - Eridius - colorByAddingColor: and/or -colorWithAlpha: <-- Color with Alpha already exists. colorWithAlphaComponent:
 */

/*
 FOR REFERENCE: Color Space Models: enum CGColorSpaceModel {
	kCGColorSpaceModelUnknown = -1,
	kCGColorSpaceModelMonochrome,
	kCGColorSpaceModelRGB,
	kCGColorSpaceModelCMYK,
	kCGColorSpaceModelLab,
	kCGColorSpaceModelDeviceN,
	kCGColorSpaceModelIndexed,
	kCGColorSpaceModelPattern
};
*/

// Undocumented UIColor calls
@interface UIColor (undocumented)
- (NSString *)styleString;
@end

// Color to return when constructor cannot create a proper color -- can be nil
#define DEFAULT_VOID_COLOR	[UIColor clearColor]

@implementation UIColor (UIColor_Expanded)

// Return a UIColor's color space model
- (CGColorSpaceModel) colorSpaceModel
{
	return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (NSString *) colorSpaceString
{
	switch (self.colorSpaceModel)
	{
		case kCGColorSpaceModelUnknown:
			return @"kCGColorSpaceModelUnknown";
		case kCGColorSpaceModelMonochrome:
			return @"kCGColorSpaceModelMonochrome";
		case kCGColorSpaceModelRGB:
			return @"kCGColorSpaceModelRGB";
		case kCGColorSpaceModelCMYK:
			return @"kCGColorSpaceModelCMYK";
		case kCGColorSpaceModelLab:
			return @"kCGColorSpaceModelLab";
		case kCGColorSpaceModelDeviceN:
			return @"kCGColorSpaceModelDeviceN";
		case kCGColorSpaceModelIndexed:
			return @"kCGColorSpaceModelIndexed";
		case kCGColorSpaceModelPattern:
			return @"kCGColorSpaceModelPattern";
		default:
			return @"Not a valid color space";
	}
}

- (BOOL) canProvideRGBComponents
{
	switch (self.colorSpaceModel) {
		case kCGColorSpaceModelRGB:
		case kCGColorSpaceModelMonochrome:
			return YES;
		default:
			return NO;
	}
}

// Return a UIColor's components
- (NSArray *) arrayFromRGBAComponents
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -arrayFromRGBAComponents");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	
	// RGB
	if (self.colorSpaceModel == kCGColorSpaceModelRGB)
		return [NSArray arrayWithObjects:
				[NSNumber numberWithFloat:c[0]],
				[NSNumber numberWithFloat:c[1]],
				[NSNumber numberWithFloat:c[2]],
				[NSNumber numberWithFloat:c[3]],
				nil];
	
	// Monochrome
	if (self.colorSpaceModel == kCGColorSpaceModelMonochrome)
		return [NSArray arrayWithObjects:
				[NSNumber numberWithFloat:c[0]],
				[NSNumber numberWithFloat:c[0]],
				[NSNumber numberWithFloat:c[0]],
				[NSNumber numberWithFloat:c[1]],
				nil];
	
	// No support at this time for other color spaces yet
	return nil;
}

#if SUPPORTS_UNDOCUMENTED_API

// Return the undocumented style string
- (NSString *) fetchStyleString
{
	return [self styleString];
}

// Convert a color into RGB Color space, courtesy of Poltras
// via http://ofcodeandmen.poltras.com/2009/01/22/convert-a-cgcolorref-to-another-cgcolorspaceref/
//
- (UIColor *) rgbColor
{
	// Call to undocumented method "styleString".
	NSString*style = [self styleString];
	
	// Remove the "rgb(" prefix and the ")" suffix.
	style = [[style substringToIndex:style.length - 1] substringFromIndex:4];
	
	// Split the components.
	NSArray* rgb = [style componentsSeparatedByString:@","]; 
	
	CGFloat red   = [[rgb objectAtIndex:0] floatValue] / 255.0f;
	CGFloat green = [[rgb objectAtIndex:1] floatValue] / 255.0f; 
	CGFloat blue  = [[rgb objectAtIndex:2] floatValue] / 255.0f;
	CGFloat alpha = CGColorGetAlpha(self.CGColor);
	
	return [UIColor colorWithRed:red 
						   green:green 
							blue:blue
						   alpha:alpha];
}

#endif

- (CGFloat) red
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -red");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

- (CGFloat) green
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -green");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
	return c[1];
}

- (CGFloat) blue
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
	return c[2];
}

- (CGFloat) alpha
{
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[CGColorGetNumberOfComponents(self.CGColor)-1];
}

/*
 *
 * String Utilities
 *
 */

- (NSString *) stringFromColor
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -stringFromColor");
	return [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}", self.red, self.green, self.blue, self.alpha];
}

- (NSString *) hexStringFromColor
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -hexStringFromColor");

	CGFloat r, g, b;
	r = self.red;
	g = self.green;
	b = self.blue;
	
	// Fix range if needed
	if (r < 0.0f) r = 0.0f;
	if (g < 0.0f) g = 0.0f;
	if (b < 0.0f) b = 0.0f;
	
	if (r > 1.0f) r = 1.0f;
	if (g > 1.0f) g = 1.0f;
	if (b > 1.0f) b = 1.0f;
	
	// Convert to hex string between 0x00 and 0xFF
	return [NSString stringWithFormat:@"%02X%02X%02X",
			 (int)(r * 255), (int)(g * 255), (int)(b * 255)];
}

+ (UIColor *) colorWithString: (NSString *) stringToConvert
{
	NSString *cString = [stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	// Proper color strings are denoted with braces
	if (![cString hasPrefix:@"{"]) return DEFAULT_VOID_COLOR;
	if (![cString hasSuffix:@"}"]) return DEFAULT_VOID_COLOR;
	
	// Remove braces	
	cString = [cString substringFromIndex:1];
	cString = [cString substringToIndex:([cString length] - 1)];
	CFShow(cString);
	
	// Separate into components by removing commas and spaces
	NSArray *components = [cString componentsSeparatedByString:@", "];
	if ([components count] != 4) return DEFAULT_VOID_COLOR;
	
	// Create the color
	return [UIColor colorWithRed:[[components objectAtIndex:0] floatValue]
						   green:[[components objectAtIndex:1] floatValue] 
							blue:[[components objectAtIndex:2] floatValue]
						   alpha:[[components objectAtIndex:3] floatValue]];
}

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
	NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	
	// String should be 6 or 8 characters
	if ([cString length] < 6) return DEFAULT_VOID_COLOR;
	
	// strip 0X if it appears
	if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
	
	if ([cString length] != 6) return DEFAULT_VOID_COLOR;

	// Separate into r, g, b substrings
	NSRange range;
	range.location = 0;
	range.length = 2;
	NSString *rString = [cString substringWithRange:range];
	
	range.location = 2;
	NSString *gString = [cString substringWithRange:range];
	
	range.location = 4;
	NSString *bString = [cString substringWithRange:range];
	
	// Scan values
	unsigned int r, g, b;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];
	
	return [UIColor colorWithRed:((float) r / 255.0f)
						   green:((float) g / 255.0f)
							blue:((float) b / 255.0f)
						   alpha:1.0f];
}
@end
