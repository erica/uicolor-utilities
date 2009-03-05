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

// UIColor_Undocumented
// Undocumented methods of UIColor
@interface UIColor (UIColor_Undocumented)
- (NSString *) styleString;
@end

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

	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a])
		return nil;
	
	return [NSArray arrayWithObjects:
			[NSNumber numberWithFloat:r],
			[NSNumber numberWithFloat:g],
			[NSNumber numberWithFloat:b],
			[NSNumber numberWithFloat:a],
			nil];
}

- (BOOL) red:(CGFloat*)red green:(CGFloat*)green blue:(CGFloat*)blue alpha:(CGFloat*)alpha;
{
	const CGFloat *components = CGColorGetComponents(self.CGColor);
	
	CGFloat r,g,b,a;
	
	switch (self.colorSpaceModel) {
		case kCGColorSpaceModelMonochrome:
			r = g = b = components[0];
			a = components[1];
			break;
		case kCGColorSpaceModelRGB:
			r = components[0];
			g = components[1];
			b = components[2];
			a = components[3];
			break;
		default:	// We don't know how to handle this model
			return NO;
	}
	
	if (red) *red = r;
	if (green) *green = g;
	if (blue) *blue = b;
	if (alpha) *alpha = a;
	
	return YES;
}

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

- (CGFloat) white
{
	NSAssert(self.colorSpaceModel == kCGColorSpaceModelMonochrome, @"Must be a Monochrome color to use -white");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

- (CGFloat) alpha
{
	return CGColorGetAlpha(self.CGColor);
}

- (UInt32) rgbHex
{
	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use rgbHex");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a])
		return 0;
	
	r = MIN(MAX(self.red, 0.0f), 1.0f);
	g = MIN(MAX(self.green, 0.0f), 1.0f);
	b = MIN(MAX(self.blue, 0.0f), 1.0f);
	
	return	(((int)roundf(r * 255)) << 16)
		|	(((int)roundf(g * 255)) << 8)
		|	(((int)roundf(b * 255)))
		;
}

/*
 * Arithmatic operations
 */
- (UIColor*)colorByLuminanceMapping
{
	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a])
		return nil;
	
	// http://en.wikipedia.org/wiki/Luma_(video):
	// Y = 0.2126 R + 0.7152 G + 0.0722 B
	return [UIColor colorWithWhite:r*0.2126 + g*0.7152 + b*0.0722
							 alpha:a];
	
}


- (UIColor*)colorByMultiplyingByRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");

	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a])
		return nil;
		
	return [UIColor colorWithRed:MAX(0.0, MIN(1.0, r * red))
						   green:MAX(0.0, MIN(1.0, g * green)) 
							blue:MAX(0.0, MIN(1.0, b * blue))
						   alpha:MAX(0.0, MIN(1.0, a * alpha))
		];
}


- (UIColor*)colorByAddingRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a])
		return nil;
	
	return [UIColor colorWithRed:MAX(0.0, MIN(1.0, r + red))
						   green:MAX(0.0, MIN(1.0, g + green)) 
							blue:MAX(0.0, MIN(1.0, b + blue))
						   alpha:MAX(0.0, MIN(1.0, a + alpha))
			];
}


- (UIColor*)colorByLighteningWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a])
		return nil;
		
	return [UIColor colorWithRed:MAX(r, red)
						   green:MAX(g, green)
							blue:MAX(b, blue)
						   alpha:MAX(a, alpha)
			];
}


- (UIColor*)colorByDarkeningWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a])
		return nil;
	
	return [UIColor colorWithRed:MIN(r, red)
						   green:MIN(g, green)
							blue:MIN(b, blue)
						   alpha:MIN(a, alpha)
			];
}


- (UIColor*)colorByMultiplyingBy:(CGFloat)f
{
	return [self colorByMultiplyingByRed:f green:f blue:f alpha:1.0f];
}


- (UIColor*)colorByAdding:(CGFloat)f
{
	return [self colorByMultiplyingByRed:f green:f blue:f alpha:0.0f];
}


- (UIColor*)colorByLighteningWith:(CGFloat)f
{
	return [self colorByLighteningWithRed:f green:f blue:f alpha:0.0f];
}


- (UIColor*)colorByDarkeningWith:(CGFloat)f
{
	return [self colorByDarkeningWithRed:f green:f blue:f alpha:1.0f];
}


- (UIColor*)colorByMultiplyingByColor:(UIColor*)color
{
	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a])
		return nil;
	
	return [self colorByMultiplyingByRed:r green:g blue:b alpha:1.0f];
}


- (UIColor*)colorByAddingColor:(UIColor*)color
{
	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a])
		return nil;
	
	return [self colorByMultiplyingByRed:r green:g blue:b alpha:0.0f];
}


- (UIColor*)colorByLighteningWithColor:(UIColor*)color
{
	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a])
		return nil;
		
	return [self colorByLighteningWithRed:r green:g blue:b alpha:0.0f];
}


- (UIColor*)colorByDarkeningWithColor:(UIColor*)color
{
	NSAssert (self.canProvideRGBComponents, @"Must be a RGB color to use arithmatic operations");
	
	CGFloat r,g,b,a;
	if (![self red:&r green:&g blue:&b alpha:&a])
		return nil;
	
	return [self colorByDarkeningWithRed:r green:g blue:b alpha:1.0f];
}



/*
 *
 * String Utilities
 *
 */

- (NSString *) stringFromColor
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -stringFromColor");
	NSString *result;
	switch (self.colorSpaceModel) {
		case kCGColorSpaceModelRGB:
			result = [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}", self.red, self.green, self.blue, self.alpha];
			break;
		case kCGColorSpaceModelMonochrome:
			result = [NSString stringWithFormat:@"{%0.3f, %0.3f}", self.white, self.alpha];
			break;
		default:
			result = nil;
	}
	return result;
}

- (NSString *) hexStringFromColor
{
	// Convert to hex string between 0x00 and 0xFF
	return [NSString stringWithFormat:@"%06X", self.rgbHex];
}

+ (UIColor *) colorWithString: (NSString *) stringToConvert
{
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	if (![scanner scanString:@"{" intoString:NULL]) return nil;
	const NSUInteger kMaxComponents = 4;
	CGFloat c[kMaxComponents];
	NSUInteger i = 0;
	if (![scanner scanFloat:&c[i++]]) return nil;
	while (1) {
		if ([scanner scanString:@"}" intoString:NULL]) break;
		if (i >= kMaxComponents) return nil;
		if ([scanner scanString:@"," intoString:NULL]) {
			if (![scanner scanFloat:&c[i++]]) return nil;
		} else {
			// either we're at the end of there's an unexpected character here
			// both cases are error conditions
			return nil;
		}
	}
	if (![scanner isAtEnd]) return nil;
	UIColor *color;
	switch (i) {
		case 2: // monochrome
			color = [UIColor colorWithWhite:c[0] alpha:c[1]];
			break;
		case 4: // RGB
			color = [UIColor colorWithRed:c[0] green:c[1] blue:c[2] alpha:c[3]];
			break;
		default:
			color = nil;
	}
	return color;
}

/*
 * Class methods
 */

+ (UIColor *) randomColor
{
	return [UIColor colorWithRed:(CGFloat)RAND_MAX / random()
						   green:(CGFloat)RAND_MAX / random()
							blue:(CGFloat)RAND_MAX / random()
						   alpha:1.0f];
}


+ (UIColor *) colorWithRGBHex: (UInt32) hex
{
	int r = (hex >> 16) & 0xFF;
	int g = (hex >> 8) & 0xFF;
	int b = (hex) & 0xFF;
	
	return [UIColor colorWithRed:r / 255.0f
						   green:g / 255.0f
							blue:b / 255.0f
						   alpha:1.0f];
}


+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	unsigned hexNum;
	if (![scanner scanHexInt:&hexNum]) return nil;
	return [UIColor colorWithRGBHex:hexNum];
}
@end

#if SUPPORTS_UNDOCUMENTED_API
@implementation UIColor (UIColor_Undocumented_Expanded)
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
	NSString *style = [self styleString];
	NSScanner *scanner = [NSScanner scannerWithString:style];
	CGFloat red, green, blue;
	if (![scanner scanString:@"rgb(" intoString:NULL]) return nil;
	if (![scanner scanFloat:&red]) return nil;
	if (![scanner scanString:@"," intoString:NULL]) return nil;
	if (![scanner scanFloat:&green]) return nil;
	if (![scanner scanString:@"," intoString:NULL]) return nil;
	if (![scanner scanFloat:&blue]) return nil;
	if (![scanner scanString:@")" intoString:NULL]) return nil;
	if (![scanner isAtEnd]) return nil;
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:self.alpha];
}
@end
#endif // SUPPORTS_UNDOCUMENTED_API
