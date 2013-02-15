#import "UIColor-Expanded.h"

@implementation UIColor (UIColor_Expanded)

#pragma mark - Color Space

- (CGColorSpaceModel) colorSpaceModel
{
	return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

+ (NSString *) colorSpaceString: (CGColorSpaceModel) model
{
	switch (model)
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

- (NSString *) colorSpaceString
{
    return [UIColor colorSpaceString:self.colorSpaceModel];
}

- (BOOL) canProvideRGBComponents
{
	switch (self.colorSpaceModel)
    {
		case kCGColorSpaceModelRGB:
		case kCGColorSpaceModelMonochrome:
			return YES;
		default:
			return NO;
	}
}

- (BOOL) usesMonochromeColorspace
{
    return (self.colorSpaceModel == kCGColorSpaceModelMonochrome);
}

- (BOOL) usesRGBColorspace
{
    return (self.colorSpaceModel == kCGColorSpaceModelRGB);
}

#pragma mark - Color Space Conversion

+ (void) hue: (CGFloat) h
  saturation: (CGFloat) s
  brightness: (CGFloat) v
       toRed: (CGFloat *) pR
       green: (CGFloat *) pG
        blue: (CGFloat *) pB
{
    CGFloat r, g, b;
	
	// From Foley and Van Dam
	
	if (s == 0.0f)
    {
		// Achromatic color: there is no hue
		r = g = b = v;
	}
    else
    {
		// Chromatic color: there is a hue
		if (h == 360.0f) h = 0.0f;
		h /= 60.0f;										// h is now in [0, 6)
		
		int i = floorf(h);								// largest integer <= h
		CGFloat f = h - i;								// fractional part of h
		CGFloat p = v * (1 - s);
		CGFloat q = v * (1 - (s * f));
		CGFloat t = v * (1 - (s * (1 - f)));
		
		switch (i)
        {
			case 0:	r = v; g = t; b = p;	break;
			case 1:	r = q; g = v; b = p;	break;
			case 2:	r = p; g = v; b = t;	break;
			case 3:	r = p; g = q; b = v;	break;
			case 4:	r = t; g = p; b = v;	break;
			case 5:	r = v; g = p; b = q;	break;
		}
	}
	
	if (pR) *pR = r;
	if (pG) *pG = g;
	if (pB) *pB = b;
}

+ (void) red: (CGFloat) r
       green: (CGFloat) g
        blue: (CGFloat) b
       toHue: (CGFloat *) pH
  saturation: (CGFloat *) pS
  brightness: (CGFloat *) pV
{
	CGFloat h, s, v;
	
	// From Foley and Van Dam
	
	CGFloat max = MAX(r, MAX(g, b));
	CGFloat min = MIN(r, MIN(g, b));
	
	// Brightness
	v = max;
	
	// Saturation
	s = (max != 0.0f) ? ((max - min) / max) : 0.0f;
	
	if (s == 0.0f)
    {
		// No saturation, so undefined hue
		h = 0.0f;
	}
    else
    {
		// Determine hue
		CGFloat rc = (max - r) / (max - min);		// Distance of color from red
		CGFloat gc = (max - g) / (max - min);		// Distance of color from green
		CGFloat bc = (max - b) / (max - min);		// Distance of color from blue
		
		if (r == max) h = bc - gc;					// resulting color between yellow and magenta
		else if (g == max) h = 2 + rc - bc;			// resulting color between cyan and yellow
		else /* if (b == max) */ h = 4 + gc - rc;	// resulting color between magenta and cyan
		
		h *= 60.0f;									// Convert to degrees
		if (h < 0.0f) h += 360.0f;					// Make non-negative
	}
	
	if (pH) *pH = h;
	if (pS) *pS = s;
	if (pV) *pV = v;
}

void RGB2YUV_f(CGFloat r, CGFloat g, CGFloat b, CGFloat *y, CGFloat *u, CGFloat *v)
{
	if (y) *y = (0.299f * r + 0.587f * g + 0.114f * b);
	if (u && y) *u = ((b - *y) * 0.565f + 0.5);
	if (v && y) *v = ((r - *y) * 0.713f + 0.5);
    
	if (y) *y = MIN(1.0, MAX(0, *y));
	if (u) *u = MIN(1.0, MAX(0, *u));
	if (v) *v = MIN(1.0, MAX(0, *v));
}

void YUV2RGB_f(CGFloat y, CGFloat u, CGFloat v, CGFloat *r, CGFloat *g, CGFloat *b)
{
	CGFloat	Y = y;
	CGFloat	U = u - 0.5;
	CGFloat	V = v - 0.5;
    
	if (r) *r = ( Y + 1.403f * V);
	if (g) *g = ( Y - 0.344f * U - 0.714f * V);
	if (b) *b = ( Y + 1.770f * U);
    
	if (r) *r = MIN(1.0, MAX(0, *r));
	if (g) *g = MIN(1.0, MAX(0, *g));
	if (b) *b = MIN(1.0, MAX(0, *b));
}

#pragma mark - Components

- (BOOL) red: (CGFloat *) red
       green: (CGFloat *) green
        blue: (CGFloat *) blue
       alpha: (CGFloat *) alpha
{
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -red:green:blue:alpha:");

	const CGFloat *components = CGColorGetComponents(self.CGColor);
	CGFloat r, g, b, a;
	
	switch (self.colorSpaceModel)
    {
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

- (BOOL) hue: (CGFloat *) hue
  saturation: (CGFloat *) saturation
  brightness: (CGFloat *) brightness
       alpha: (CGFloat *) alpha
{
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -hue:saturation:brightness:alpha:");

	CGFloat r, g, b, a;
	if (![self red: &r green: &g blue: &b alpha: &a]) return NO;
	
	[UIColor red:r green:g blue:b toHue:hue saturation:saturation brightness:brightness];

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
	if (self.colorSpaceModel == kCGColorSpaceModelMonochrome)
        return c[0];
	return c[1];
}

- (CGFloat) blue
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if (self.colorSpaceModel == kCGColorSpaceModelMonochrome)
        return c[0];
	return c[2];
}

- (CGFloat) white
{
	NSAssert(self.usesMonochromeColorspace, @"Must be a Monochrome color to use -white");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}


- (CGFloat) hue
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -hue");
	CGFloat h = 0.0f;
	[self hue: &h saturation:nil brightness:nil alpha:nil];
	return h;
}

- (CGFloat) saturation
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -saturation");
	CGFloat s = 0.0f;
	[self hue:nil saturation: &s brightness:nil alpha:nil];
	return s;
}

- (CGFloat) brightness
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -brightness");
	CGFloat v = 0.0f;
	[self hue:nil saturation:nil brightness: &v alpha:nil];
	return v;
}

- (CGFloat) alpha
{
	return CGColorGetAlpha(self.CGColor);
}

- (CGFloat) luminance
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use -luminance");
    
	CGFloat r, g, b;
	if (![self red: &r green: &g blue: &b alpha:nil])
        return 0.0f;
	
	// http://en.wikipedia.org/wiki/Luma_(video)
	// Y = 0.2126 R + 0.7152 G + 0.0722 B	
	return r * 0.2126f + g * 0.7152f + b * 0.0722f;
}

- (UInt32)rgbHex
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use -rgbHex");
	
	CGFloat r, g, b, a;
	if (![self red: &r green: &g blue: &b alpha: &a])
        return 0.0f;
	
	r = MIN(MAX(r, 0.0f), 1.0f);
	g = MIN(MAX(g, 0.0f), 1.0f);
	b = MIN(MAX(b, 0.0f), 1.0f);
	
	return (((int)roundf(r * 255)) << 16) | (((int)roundf(g * 255)) << 8) | (((int)roundf(b * 255)));
}

- (NSArray *) arrayFromRGBAComponents
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -arrayFromRGBAComponents");
    
	CGFloat r, g, b, a;
	if (![self red: &r green: &g blue: &b alpha: &a]) return nil;
	
	return @[@(r), @(g), @(b), @(a)];
}

#pragma mark - Gray Scale representation
- (UIColor *) colorByLuminanceMapping
{
	return [UIColor colorWithWhite:self.luminance alpha:1.0f];
}

#pragma mark - Distance
- (CGFloat) luminanceDistanceFrom: (UIColor *) anotherColor
{
    CGFloat base = self.luminance - anotherColor.luminance;
    return sqrtf(base * base);
}

- (CGFloat) distanceFrom: (UIColor *) anotherColor
{
    CGFloat dR = self.red - anotherColor.red;
    CGFloat dG = self.green - anotherColor.green;
    CGFloat dB = self.blue - anotherColor.blue;
    
    return sqrtf(dR * dR + dG * dG + dB * dB);
}

#pragma mark Arithmetic operations


- (UIColor *) colorByMultiplyingByRed: (CGFloat) red
                                green: (CGFloat) green
                                 blue: (CGFloat) blue
                                alpha: (CGFloat) alpha
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
	CGFloat r, g, b, a;
	if (![self red: &r green: &g blue: &b alpha: &a]) return nil;
    
	return [UIColor colorWithRed:MAX(0.0, MIN(1.0, r * red))
						   green:MAX(0.0, MIN(1.0, g * green))
							blue:MAX(0.0, MIN(1.0, b * blue))
						   alpha:MAX(0.0, MIN(1.0, a * alpha))];
}

- (UIColor *) colorByAddingRed: (CGFloat) red
                         green: (CGFloat) green
                          blue: (CGFloat) blue
                         alpha: (CGFloat) alpha
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
	
	CGFloat r, g, b, a;
	if (![self red: &r green: &g blue: &b alpha: &a]) return nil;
	
	return [UIColor colorWithRed:MAX(0.0, MIN(1.0, r + red))
						   green:MAX(0.0, MIN(1.0, g + green))
							blue:MAX(0.0, MIN(1.0, b + blue))
						   alpha:MAX(0.0, MIN(1.0, a + alpha))];
}

- (UIColor *) colorByLighteningToRed: (CGFloat) red
                               green: (CGFloat) green
                                blue: (CGFloat) blue
                               alpha: (CGFloat) alpha
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
	
	CGFloat r, g, b, a;
	if (![self red: &r green: &g blue: &b alpha: &a]) return nil;
    
	return [UIColor colorWithRed:MAX(r, red)
						   green:MAX(g, green)
							blue:MAX(b, blue)
						   alpha:MAX(a, alpha)];
}

- (UIColor *) colorByDarkeningToRed: (CGFloat) red
                              green: (CGFloat) green
                               blue: (CGFloat) blue
                              alpha: (CGFloat) alpha
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
	
	CGFloat r, g, b, a;
	if (![self red: &r green: &g blue: &b alpha: &a]) return nil;
	
	return [UIColor colorWithRed:MIN(r, red)
						   green:MIN(g, green)
							blue:MIN(b, blue)
						   alpha:MIN(a, alpha)];
}

- (UIColor *) colorByMultiplyingBy: (CGFloat) f
{
	return [self colorByMultiplyingByRed:f green:f blue:f alpha:1.0f];
}

- (UIColor *) colorByAdding: (CGFloat) f
{
	return [self colorByMultiplyingByRed:f green:f blue:f alpha:0.0f];
}

- (UIColor *) colorByLighteningTo: (CGFloat) f
{
	return [self colorByLighteningToRed:f green:f blue:f alpha:0.0f];
}

- (UIColor *) colorByDarkeningTo: (CGFloat) f
{
	return [self colorByDarkeningToRed:f green:f blue:f alpha:1.0f];
}

- (UIColor *) colorByMultiplyingByColor: (UIColor *) color
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
	
	CGFloat r, g, b, a;
	if (![self red: &r green: &g blue: &b alpha: &a]) return nil;
	
	return [self colorByMultiplyingByRed:r green:g blue:b alpha:1.0f];
}

- (UIColor *) colorByAddingColor: (UIColor *) color
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
	
	CGFloat r, g, b, a;
	if (![self red: &r green: &g blue: &b alpha: &a]) return nil;
	
	return [self colorByAddingRed:r green:g blue:b alpha:0.0f];
}

- (UIColor *) colorByLighteningToColor: (UIColor *) color
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
	
	CGFloat r, g, b, a;
	if (![self red: &r green: &g blue: &b alpha: &a]) return nil;
    
	return [self colorByLighteningToRed:r green:g blue:b alpha:0.0f];
}

- (UIColor *) colorByDarkeningToColor: (UIColor *) color
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
	
	CGFloat r, g, b, a;
	if (![self red: &r green: &g blue: &b alpha: &a]) return nil;
	
	return [self colorByDarkeningToRed:r green:g blue:b alpha:1.0f];
}

// Andrew Wooster https://github.com/wooster
- (UIColor *)colorByInterpolatingToColor:(UIColor *)color byFraction:(CGFloat)fraction
{
	NSAssert(self.canProvideRGBComponents, @"Self must be a RGB color to use arithmatic operations");
	NSAssert(color.canProvideRGBComponents, @"Color must be a RGB color to use arithmatic operations");
    
	CGFloat r, g, b, a;
	if (![self red:&r green:&g blue:&b alpha:&a]) return nil;
    
	CGFloat r2,g2,b2,a2;
	if (![color red:&r2 green:&g2 blue:&b2 alpha:&a2]) return nil;
    
	CGFloat red = r + (fraction * (r2 - r));
	CGFloat green = g + (fraction * (g2 - g));
	CGFloat blue = b + (fraction * (b2 - b));
	CGFloat alpha = a + (fraction * (a2 - a));
    
	UIColor *new = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
	return new;
}

#pragma mark Complementary Colors, etc

// Pick a color that is likely to contrast well with this color
- (UIColor *) contrastingColor
{
	return (self.luminance > 0.5f) ? [UIColor blackColor] : [UIColor whiteColor];
}

// Pick the color that is 180 degrees away in hue
- (UIColor *) complementaryColor
{
	
	// Convert to HSB
	CGFloat h, s, v, a;
	if (![self hue: &h saturation: &s brightness: &v alpha: &a]) return nil;
    
	// Pick color 180 degrees away
	h += 180.0f;
	if (h > 360.f) h -= 360.0f;
	
	// Create a color in RGB
	return [UIColor colorWithHue:h saturation:s brightness:v alpha:a];
}

// Pick two colors more colors such that all three are equidistant on the color wheel
// (120 degrees and 240 degress difference in hue from self)
- (NSArray *) triadicColors
{
	return [self analogousColorsWithStepAngle:120.0f pairCount:1];
}

// Pick n pairs of colors, stepping in increasing steps away from this color around the wheel
- (NSArray *) analogousColorsWithStepAngle: (CGFloat) stepAngle pairCount: (int) pairs
{
	// Convert to HSB
	CGFloat h, s, v, a;
	if (![self hue: &h saturation: &s brightness: &v alpha: &a]) return nil;
	
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:pairs * 2];
	
	if (stepAngle < 0.0f)
		stepAngle *= -1.0f;
	
	for (int i = 1; i <= pairs; ++i)
    {
		CGFloat a = fmodf(stepAngle * i, 360.0f);
		
		CGFloat h1 = fmodf(h + a, 360.0f);
		CGFloat h2 = fmodf(h + 360.0f - a, 360.0f);
		
		[colors addObject:[UIColor colorWithHue:h1 saturation:s brightness:v alpha:a]];
		[colors addObject:[UIColor colorWithHue:h2 saturation:s brightness:v alpha:a]];
	}
	
	return [colors copy];
}

#pragma mark - String Support
- (NSString *) stringValue
{
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -stringValue");
    NSString *result;
    switch (self.colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
            result = [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}",
                      self.red, self.green, self.blue, self.alpha];
            break;
        case kCGColorSpaceModelMonochrome:
            result = [NSString stringWithFormat:@"{%0.3f, %0.3f}",
                      self.white, self.alpha];
            break;
        default:
            result = nil;
    }
    return result;
}

- (NSString *) hexStringValue
{
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -hexStringValue");
    NSString *result;
    switch (self.colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
            result = [NSString stringWithFormat:@"%02X%02X%02X",
                      (int) (self.red * 0xFF), (int) (self.green * 0xFF), (int) (self.blue * 0xFF)];
            break;
        case kCGColorSpaceModelMonochrome:
            result = [NSString stringWithFormat:@"%02X%02X%02X",
                      (int) (self.white * 0xFF), (int) (self.white * 0xFF), (int) (self.white * 0xFF)];
            break;
        default:
            result = nil;
    }
    return result;
}

+ (UIColor *) colorWithString: (NSString *)stringToConvert
{
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	if (![scanner scanString:@"{" intoString:NULL]) return nil;
    
	const NSUInteger kMaxComponents = 4;
	CGFloat c[kMaxComponents];
	NSUInteger i = 0;
    
	if (![scanner scanFloat: &c[i++]]) return nil;
    
	while (1)
    {
		if ([scanner scanString:@"}" intoString:NULL]) break;
		if (i >= kMaxComponents) return nil;
		if ([scanner scanString:@"," intoString:NULL])
        {
			if (![scanner scanFloat: &c[i++]]) return nil;
		}
        else
        {
			// either we're at the end of there's an unexpected character here
			// both cases are error conditions
			return nil;
		}
	}
	if (![scanner isAtEnd]) return nil;
	UIColor *color;
	switch (i)
    {
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

+ (UIColor *) colorWithRGBHex: (UInt32)hex
{
	int r = (hex >> 16) & 0xFF;
	int g = (hex >> 8) & 0xFF;
	int b = (hex) & 0xFF;
	
	return [UIColor colorWithRed:r / 255.0f
						   green:g / 255.0f
							blue:b / 255.0f
						   alpha:1.0f];
}

// Returns a UIColor by scanning the string for a hex number and passing that to +[UIColor colorWithRGBHex:]
// Skips any leading whitespace and ignores any trailing characters
+ (UIColor *) colorWithHexString: (NSString *)stringToConvert
{
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	unsigned hexNum;
	if (![scanner scanHexInt: &hexNum]) return nil;
	return [UIColor colorWithRGBHex:hexNum];
}

#pragma mark - Random
+ (UIColor *) randomColor
{
    static BOOL seeded = NO;
    if (!seeded)
    {
        seeded = YES;
        srandom(time(0));
    }
	return [UIColor colorWithRed:random() / (CGFloat) LONG_MAX
						   green:random() / (CGFloat) LONG_MAX
							blue:random() / (CGFloat) LONG_MAX
						   alpha:1.0f];
}

+ (UIColor *) randomDarkColor : (CGFloat) scaleFactor
{
    static BOOL seeded = NO;
    if (!seeded)
    {
        seeded = YES;
        srandom(time(0));
    }
	return [UIColor colorWithRed:scaleFactor * random() / (CGFloat) LONG_MAX
						   green:scaleFactor * random() / (CGFloat) LONG_MAX
							blue:scaleFactor * random() / (CGFloat) LONG_MAX
						   alpha:1.0f];
}

+ (UIColor *) randomLightColor: (CGFloat) scaleFactor
{
    static BOOL seeded = NO;
    if (!seeded)
    {
        seeded = YES;
        srandom(time(0));
    }
    CGFloat difference = 1.0f - scaleFactor;
	return [UIColor colorWithRed:difference + scaleFactor * random() / (CGFloat) LONG_MAX
						   green:difference + scaleFactor * random() / (CGFloat) LONG_MAX
							blue:difference + scaleFactor * random() / (CGFloat) LONG_MAX
						   alpha:1.0f];
}
@end

#pragma mark - Named Colors
@implementation UIColor (NamedColors)

static NSDictionary *colorNameDictionaries = nil;

+ (void) initializeColorDictionaries
{
    if (colorNameDictionaries)
        return;
  
    NSDictionary *crayonDictionary = @{@"Carnation Pink":@"FFA6C9", @"Almond":@"EED9C4", @"Burnt Orange":@"FF7034", @"Wisteria":@"C9A0DC", @"Sepia":@"9E5B40", @"Vivid Tangerine":@"FF9980", @"Neon Carrot":@"FF9933", @"Electric Lime":@"CCFF00", @"Sunset Orange":@"FE4C40", @"Jungle Green":@"29AB87", @"Robin's Egg Blue":@"00CCCC", @"Banana Mania":@"FBE7B2", @"Fuchsia":@"C154C1", @"Mango Tango":@"E77200", @"Cranberry":@"DB5079", @"Blue":@"0066FF", @"Raw Sienna":@"D27D46", @"Tickle Me Pink":@"FC80A5", @"Gray":@"8B8680", @"Mountain Meadow":@"1AB385", @"Hot Magenta":@"FF00CC", @"Black":@"000000", @"Pink Flamingo":@"FF66FF", @"Screamin' Green":@"66FF66", @"Mauvelous":@"F091A9", @"Orange":@"FF681F", @"Orchid":@"E29CD2", @"Aquamarine":@"71D9E2", @"Goldenrod":@"FCD667", @"Brick Red":@"C62D42", @"Apricot":@"FDD5B1", @"Razzmatazz":@"E30B5C", @"Mahogany":@"CA3435", @"Flesh":@"FFCBA4", @"Wild Strawberry":@"FF3399", @"Desert Sand":@"EDC9AF", @"Burnt Sienna":@"E97451", @"Midnight Blue":@"003366", @"Shocking Pink":@"FF6FFF", @"Laser Lemon":@"FFFF66", @"White":@"FFFFFF", @"Inch Worm":@"B0E313", @"Pig Pink":@"FDD7E4", @"Vivid Violet":@"803790", @"Antique Brass":@"C88A65", @"Bittersweet":@"FE6F5E", @"Violet (Purple)":@"8359A3", @"Magenta":@"F653A6", @"Eggplant":@"614051", @"Atomic Tangerine":@"FF9966", @"Lavender":@"FBAED2", @"Razzle Dazzle Rose":@"FF33CC", @"Blizzard Blue":@"A3E3ED", @"Salmon":@"FF91A4", @"Granny Smith Apple":@"9DE093", @"Silver":@"C9C0BB", @"Denim":@"1560BD", @"Jazzberry Jam":@"A50B5E", @"Outer Space":@"2D383A", @"Macaroni And Cheese":@"FFB97B", @"Copper":@"DA8A67", @"Tropical Rain Forest":@"00755E", @"Violet Red":@"F7468A", @"Fern":@"63B76C", @"Gold":@"E6BE8A", @"Pacific Blue":@"009DC4", @"Sunglow":@"FFCC33", @"Tumbleweed":@"DEA681", @"Cerise":@"DA3287", @"Chestnut":@"B94E48", @"Forest Green":@"5FA777", @"Indigo":@"4F69C6", @"Ultra Red":@"FD5B78", @"Timberwolf":@"D9D6CF", @"Navy Blue":@"0066CC", @"Royal Purple":@"6B3FA0", @"Yellow Orange":@"FFAE42", @"Beaver":@"926F5B", @"Wild Blue Yonder":@"7A89B8", @"Blue Green":@"0095B6", @"Cotton Candy":@"FFB7D5", @"Dandelion":@"FED85D", @"Green":@"01A368", @"Plum":@"843179", @"Sea Green":@"93DFB8", @"Yellow Green":@"C5E17A", @"Blue Bell":@"9999CC", @"Olive Green":@"B5B35C", @"Canary":@"FFFF99", @"Yellow":@"FBE870", @"Magic Mint":@"AAF0D1", @"Red":@"ED0A3F", @"Cerulean":@"02A4D3", @"Red Violet":@"BB3385", @"Sky Blue":@"76D7EA", @"Brink Pink":@"FB607F", @"Outrageous Orange":@"FF6037", @"Cornflower":@"93CCEA", @"Mulberry":@"C54B8C", @"Purple Mountain's Majesty":@"9678B6", @"Red Orange":@"FF3F34", @"Fuzzy Wuzzy Brown":@"C45655", @"Periwinkle":@"C3CDE6", @"Happy Ever After":@"6CDA37", @"Radical Red":@"FF355E", @"Maroon":@"C32148", @"Spring Green":@"ECEBBD", @"Turquoise Blue":@"6CDAE7", @"Purple Heart":@"652DC1", @"Shamrock":@"33CC99", @"Brown":@"AF593E", @"Blue Violet":@"6456B7", @"Scarlet":@"FD0E35", @"Green Yellow":@"F1E788", @"Melon":@"FEBAAD", @"Manatee":@"8D90A1", @"Tan":@"FA9D5A", @"Asparagus":@"7BA05B", @"Pine Green":@"01796F", @"Caribbean Green":@"00CC99", @"Cadet Blue":@"A9B2C3", @"Shadow":@"837050"};
    
    /*
     * Database of color names and hex rgb values, derived
     * from the css 3 color spec:
     *	http://www.w3.org/TR/css3-color/
     */
    NSDictionary *cssDictionary = @{@"lightseagreen":@"20b2aa", @"floralwhite":@"fffaf0", @"lightgray":@"d3d3d3", @"darkgoldenrod":@"b8860b", @"paleturquoise":@"afeeee", @"goldenrod":@"daa520", @"skyblue":@"87ceeb", @"indianred":@"cd5c5c", @"darkgray":@"a9a9a9", @"khaki":@"f0e68c", @"blue":@"0000ff", @"darkred":@"8b0000", @"lightyellow":@"ffffe0", @"midnightblue":@"191970", @"chartreuse":@"7fff00", @"lightsteelblue":@"b0c4de", @"slateblue":@"6a5acd", @"firebrick":@"b22222", @"moccasin":@"ffe4b5", @"salmon":@"fa8072", @"sienna":@"a0522d", @"slategray":@"708090", @"teal":@"008080", @"lightsalmon":@"ffa07a", @"pink":@"ffc0cb", @"burlywood":@"deb887", @"gold":@"ffd700", @"springgreen":@"00ff7f", @"lightcoral":@"f08080", @"black":@"000000", @"blueviolet":@"8a2be2", @"chocolate":@"d2691e", @"aqua":@"00ffff", @"darkviolet":@"9400d3", @"indigo":@"4b0082", @"darkcyan":@"008b8b", @"orange":@"ffa500", @"antiquewhite":@"faebd7", @"peru":@"cd853f", @"silver":@"c0c0c0", @"purple":@"800080", @"saddlebrown":@"8b4513", @"lawngreen":@"7cfc00", @"dodgerblue":@"1e90ff", @"lime":@"00ff00", @"linen":@"faf0e6", @"lightblue":@"add8e6", @"darkslategray":@"2f4f4f", @"lightskyblue":@"87cefa", @"mintcream":@"f5fffa", @"olive":@"808000", @"hotpink":@"ff69b4", @"papayawhip":@"ffefd5", @"mediumseagreen":@"3cb371", @"mediumspringgreen":@"00fa9a", @"cornflowerblue":@"6495ed", @"plum":@"dda0dd", @"seagreen":@"2e8b57", @"palevioletred":@"db7093", @"bisque":@"ffe4c4", @"beige":@"f5f5dc", @"darkorchid":@"9932cc", @"royalblue":@"4169e1", @"darkolivegreen":@"556b2f", @"darkmagenta":@"8b008b", @"orangered":@"ff4500", @"lavender":@"e6e6fa", @"fuchsia":@"ff00ff", @"darkseagreen":@"8fbc8f", @"lavenderblush":@"fff0f5", @"wheat":@"f5deb3", @"steelblue":@"4682b4", @"lightgoldenrodyellow":@"fafad2", @"lightcyan":@"e0ffff", @"mediumaquamarine":@"66cdaa", @"turquoise":@"40e0d0", @"darkblue":@"00008b", @"darkorange":@"ff8c00", @"brown":@"a52a2a", @"dimgray":@"696969", @"deeppink":@"ff1493", @"powderblue":@"b0e0e6", @"red":@"ff0000", @"darkgreen":@"006400", @"ghostwhite":@"f8f8ff", @"white":@"ffffff", @"navajowhite":@"ffdead", @"navy":@"000080", @"ivory":@"fffff0", @"palegreen":@"98fb98", @"whitesmoke":@"f5f5f5", @"gainsboro":@"dcdcdc", @"mediumslateblue":@"7b68ee", @"olivedrab":@"6b8e23", @"mediumpurple":@"9370db", @"darkslateblue":@"483d8b", @"blanchedalmond":@"ffebcd", @"darkkhaki":@"bdb76b", @"green":@"008000", @"limegreen":@"32cd32", @"snow":@"fffafa", @"tomato":@"ff6347", @"darkturquoise":@"00ced1", @"orchid":@"da70d6", @"yellow":@"ffff00", @"greenyellow":@"adff2f", @"azure":@"f0ffff", @"mistyrose":@"ffe4e1", @"cadetblue":@"5f9ea0", @"oldlace":@"fdf5e6", @"gray":@"808080", @"honeydew":@"f0fff0", @"peachpuff":@"ffdab9", @"tan":@"d2b48c", @"thistle":@"d8bfd8", @"palegoldenrod":@"eee8aa", @"mediumorchid":@"ba55d3", @"rosybrown":@"bc8f8f", @"mediumturquoise":@"48d1cc", @"lemonchiffon":@"fffacd", @"maroon":@"800000", @"mediumvioletred":@"c71585", @"violet":@"ee82ee", @"yellowgreen":@"9acd32", @"coral":@"ff7f50", @"lightgreen":@"90ee90", @"cornsilk":@"fff8dc", @"mediumblue":@"0000cd", @"aliceblue":@"f0f8ff", @"forestgreen":@"228b22", @"aquamarine":@"7fffd4", @"deepskyblue":@"00bfff", @"lightslategray":@"778899", @"darksalmon":@"e9967a", @"crimson":@"dc143c", @"sandybrown":@"f4a460", @"lightpink":@"ffb6c1", @"seashell":@"fff5ee"};
      
    NSDictionary *baseDictionary = @{@"Dodger Blue":@"1E90FF", @"Plum":@"DDA0DD", @"Maroon (X11)":@"B03060", @"Ghost White":@"F8F8FF", @"Moccasin":@"FFE4B5", @"Dark Khaki":@"BDB76B", @"Light Steel Blue":@"B0C4DE", @"Spring Green":@"00FF7F", @"Deep Sky Blue":@"00BFFF", @"Floral White":@"FFFAF0", @"Blue":@"0000FF", @"Dark Slate Blue":@"483D8B", @"Pale Violet Red":@"DB7093", @"Seashell":@"FFF5EE", @"Midnight Blue":@"191970", @"Indian Red":@"CD5C5C", @"Light Goldenrod":@"FAFAD2", @"Slate Gray":@"708090", @"Light Yellow":@"FFFFE0", @"Teal":@"008080", @"Sky Blue":@"87CEEB", @"Medium Aquamarine":@"66CDAA", @"Yellow Green":@"9ACD32", @"Coral":@"FF7F50", @"Dark Goldenrod":@"B8860B", @"Black":@"000000", @"Khaki":@"F0E68C", @"Linen":@"FAF0E6", @"Medium Orchid":@"BA55D3", @"Light Blue":@"ADD8E6", @"Medium Spring Green":@"00FA9A", @"Green Yellow":@"ADFF2F", @"Gray (X11)":@"BEBEBE", @"Deep Pink":@"FF1493", @"Medium Turquoise":@"48D1CC", @"Purple (W3C)":@"7F007F", @"Pale Green":@"98FB98", @"Pink":@"FFC0CB", @"Powder Blue":@"B0E0E6", @"Salmon":@"FA8072", @"Dark Blue":@"00008B", @"Dark Red":@"8B0000", @"Hot Pink":@"FF69B4", @"Sienna":@"A0522D", @"Turquoise":@"40E0D0", @"Bisque":@"FFE4C4", @"Peach Puff":@"FFDAB9", @"Aqua":@"00FFFF", @"Azure":@"F0FFFF", @"Beige":@"F5F5DC", @"Olive":@"808000", @"Chocolate":@"D2691E", @"Sandy Brown":@"F4A460", @"Dark Magenta":@"8B008B", @"Tomato":@"FF6347", @"Dark Orange":@"FF8C00", @"White":@"FFFFFF", @"Cornflower":@"6495ED", @"Cadet Blue":@"5F9EA0", @"Gainsboro":@"DCDCDC", @"Dark Orchid":@"9932CC", @"Dark Slate Gray":@"2F4F4F", @"Mint Cream":@"F5FFFA", @"Chartreuse":@"7FFF00", @"Green (X11)":@"00FF00", @"Light Sky Blue":@"87CEFA", @"Snow":@"FFFAFA", @"Slate Blue":@"6A5ACD", @"Saddle Brown":@"8B4513", @"Dark Violet":@"9400D3", @"Light Salmon":@"FFA07A", @"Violet":@"EE82EE", @"Yellow":@"FFFF00", @"Light Green":@"90EE90", @"Dark Sea Green":@"8FBC8F", @"Medium Sea Green":@"3CB371", @"Aquamarine":@"7FFFD4", @"Olive Drab":@"6B8E23", @"Peru":@"CD853F", @"Firebrick":@"B22222", @"Dim Gray":@"696969", @"Lemon Chiffon":@"FFFACD", @"Forest Green":@"228B22", @"Dark Cyan":@"008B8B", @"Dark Green":@"006400", @"Orange Red":@"FF4500", @"Fuchsia":@"FF00FF", @"Light Cyan":@"E0FFFF", @"Dark Salmon":@"E9967A", @"Honeydew":@"F0FFF0", @"Lawn Green":@"7CFC00", @"Dark Turquoise":@"00CED1", @"Goldenrod":@"DAA520", @"Light Coral":@"F08080", @"Misty Rose":@"FFE4E1", @"Navy":@"000080", @"Old Lace":@"FDF5E6", @"Orchid":@"DA70D6", @"Medium Purple":@"9370DB", @"Maroon (W3C)":@"7F0000", @"Thistle":@"D8BFD8", @"Ivory":@"FFFFF0", @"Green (W3C)":@"008000", @"Light Gray":@"D3D3D3", @"Royal Blue":@"4169E1", @"Purple (X11)":@"A020F0", @"Red":@"FF0000", @"Dark Gray":@"A9A9A9", @"Gray (W3C)":@"808080", @"Sea Green":@"2E8B57", @"Pale Turquoise":@"AFEEEE", @"Antique White":@"FAEBD7", @"Burlywood":@"DEB887", @"Gold":@"FFD700", @"Medium Violet Red":@"C71585", @"Alice Blue":@"F0F8FF", @"Crimson":@"DC143C", @"Lime Green":@"32CD32", @"Orange":@"FFA500", @"Steel Blue":@"4682B4", @"Dark Olive Green":@"556B2F", @"Blue Violet":@"8A2BE2", @"Rosy Brown":@"BC8F8F", @"White Smoke":@"F5F5F5", @"Light Pink":@"FFB6C1", @"Medium Slate Blue":@"7B68EE", @"Tan":@"D2B48C", @"Wheat":@"F5DEB3", @"Lavender":@"E6E6FA", @"Lavender Blush":@"FFF0F5", @"Pale Goldenrod":@"EEE8AA", @"Medium Blue":@"0000CD", @"Navajo White":@"FFDEAD", @"Indigo":@"4B0082", @"Brown":@"A52A2A", @"Papaya Whip":@"FFEFD5", @"Silver (W3C)":@"C0C0C0", @"Light Slate Gray":@"778899", @"Light Sea Green":@"20B2AA", @"Blanched Almond":@"FFEBCD", @"Cornsilk":@"FFF8DC"};
    
    NSDictionary *systemColorDictionary = @{@"Black":@"000000", @"Dark Gray":@"555555", @"Light Gray":@"AAAAAA", @"White":@"FFFFFF", @"Gray":@"7F7F7F", @"Red":@"FF0000", @"Green":@"00FF00", @"Blue":@"0000FF", @"Cyan":@"00FFFF", @"Yellow":@"FFFF00", @"Magenta":@"FF00FF", @"Orange":@"FF7F00", @"Purple":@"7F007F", @"Brown":@"996633"};
    
    // See: http://en.wikipedia.org/wiki/List_of_colors:_A-M
    // and: http://en.wikipedia.org/wiki/List_of_colors:_N-Z
    NSDictionary *wikipediaColorDictionary = @{@"Aero" : @"7CB9E8", @"Aero blue" : @"C9FFE5", @"African violet" : @"B284BE", @"Air Force blue (RAF)" : @"5D8AA8", @"Air Force blue (USAF)" : @"00308F", @"Air superiority blue" : @"72A0C1", @"Alabama Crimson" : @"A32638", @"Alice blue" : @"F0F8FF", @"Alizarin crimson" : @"E32636", @"Alloy orange" : @"C46210", @"Almond" : @"EFDECD", @"Amaranth" : @"E52B50", @"Amazon" : @"3B7A57", @"Amber" : @"FFBF00", @"SAE/ECE Amber (color)" : @"FF7E00", @"American rose" : @"FF033E", @"Amethyst" : @"9966CC", @"Android green" : @"A4C639", @"Anti-flash white" : @"F2F3F4", @"Antique brass" : @"CD9575", @"Antique bronze" : @"665D1E", @"Antique fuchsia" : @"915C83", @"Antique ruby" : @"841B2D", @"Antique white" : @"FAEBD7", @"Ao (English)" : @"008000", @"Apple green" : @"8DB600", @"Apricot" : @"FBCEB1", @"Aqua" : @"00FFFF", @"Aquamarine" : @"7FFFD4", @"Army green" : @"4B5320", @"Arsenic" : @"3B444B", @"Arylide yellow" : @"E9D66B", @"Ash grey" : @"B2BEB5", @"Asparagus" : @"87A96B", @"Atomic tangerine" : @"FF9966", @"Auburn" : @"A52A2A", @"Aureolin" : @"FDEE00", @"AuroMetalSaurus" : @"6E7F80", @"Avocado" : @"568203", @"Azure" : @"007FFF", @"Azure mist/web" : @"F0FFFF", @"Baby blue" : @"89CFF0", @"Baby blue eyes" : @"A1CAF1", @"Baby pink" : @"F4C2C2", @"Baby powder" : @"FEFEFA", @"Baker-Miller pink" : @"FF91AF", @"Ball blue" : @"21ABCD", @"Banana Mania" : @"FAE7B5", @"Banana yellow" : @"FFE135", @"Barbie pink" : @"E0218A", @"Barn red" : @"7C0A02", @"Battleship grey" : @"848482", @"Bazaar" : @"98777B", @"Beau blue" : @"BCD4E6", @"Beaver" : @"9F8170", @"Beige" : @"F5F5DC", @"B'dazzled Blue" : @"2E5894", @"Big dip o’ruby" : @"9C2542", @"Bisque" : @"FFE4C4", @"Bistre" : @"3D2B1F", @"Bistre brown" : @"967117", @"Bitter lemon" : @"CAE00D", @"Bitter lime" : @"BFFF00", @"Bittersweet" : @"FE6F5E", @"Bittersweet shimmer" : @"BF4F51", @"Black" : @"000000", @"Black bean" : @"3D0C02", @"Black leather jacket" : @"253529", @"Black olive" : @"3B3C36", @"Blanched almond" : @"FFEBCD", @"Blast-off bronze" : @"A57164", @"Bleu de France" : @"318CE7", @"Blizzard Blue" : @"ACE5EE", @"Blond" : @"FAF0BE", @"Blue" : @"0000FF", @"Blue (Crayola)" : @"1F75FE", @"Blue (Munsell)" : @"0093AF", @"Blue (NCS)" : @"0087BD", @"Blue (pigment)" : @"333399", @"Blue (RYB)" : @"0247FE", @"Blue Bell" : @"A2A2D0", @"Blue-gray" : @"6699CC", @"Blue-green" : @"0D98BA", @"Blue sapphire" : @"126180", @"Blue-violet" : @"8A2BE2", @"Blueberry" : @"4F86F7", @"Bluebonnet" : @"1C1CF0", @"Blush" : @"DE5D83", @"Bole" : @"79443B", @"Bondi blue" : @"0095B6", @"Bone" : @"E3DAC9", @"Boston University Red" : @"CC0000", @"Bottle green" : @"006A4E", @"Boysenberry" : @"873260", @"Brandeis blue" : @"0070FF", @"Brass" : @"B5A642", @"Brick red" : @"CB4154", @"Bright cerulean" : @"1DACD6", @"Bright green" : @"66FF00", @"Bright lavender" : @"BF94E4", @"Bright maroon" : @"C32148", @"Bright pink" : @"FF007F", @"Bright turquoise" : @"08E8DE", @"Bright ube" : @"D19FE8", @"Brilliant lavender" : @"F4BBFF", @"Brilliant rose" : @"FF55A3", @"Brink pink" : @"FB607F", @"British racing green" : @"004225", @"Bronze" : @"CD7F32", @"Bronze Yellow" : @"737000", @"Brown (traditional)" : @"964B00", @"Brown (web)" : @"A52A2A", @"Brown-nose" : @"6B4423", @"Brunswick green" : @"1B4D3E", @"Bubble gum" : @"FFC1CC", @"Bubbles" : @"E7FEFF", @"Buff" : @"F0DC82", @"Bulgarian rose" : @"480607", @"Burgundy" : @"800020", @"Burlywood" : @"DEB887", @"Burnt orange" : @"CC5500", @"Burnt sienna" : @"E97451", @"Burnt umber" : @"8A3324", @"Byzantine" : @"BD33A4", @"Byzantium" : @"702963", @"Cadet" : @"536872", @"Cadet blue" : @"5F9EA0", @"Cadet grey" : @"91A3B0", @"Cadmium green" : @"006B3C", @"Cadmium orange" : @"ED872D", @"Cadmium red" : @"E30022", @"Cadmium yellow" : @"FFF600", @"Café au lait" : @"A67B5B", @"Café noir" : @"4B3621", @"Cal Poly green" : @"1E4D2B", @"Cambridge Blue" : @"A3C1AD", @"Camel" : @"C19A6B", @"Cameo pink" : @"EFBBCC", @"Camouflage green" : @"78866B", @"Canary yellow" : @"FFEF00", @"Candy apple red" : @"FF0800", @"Candy pink" : @"E4717A", @"Capri" : @"00BFFF", @"Caput mortuum" : @"592720", @"Cardinal" : @"C41E3A", @"Caribbean green" : @"00CC99", @"Carmine" : @"960018", @"Carmine (M&P)" : @"D70040", @"Carmine pink" : @"EB4C42", @"Carmine red" : @"FF0038", @"Carnation pink" : @"FFA6C9", @"Carnelian" : @"B31B1B", @"Carolina blue" : @"99BADD", @"Carrot orange" : @"ED9121", @"Castleton green" : @"00563F", @"Catalina blue" : @"062A78", @"Catawba" : @"703642", @"Cedar Chest" : @"C95A49", @"Ceil" : @"92A1CF", @"Celadon" : @"ACE1AF", @"Celadon blue" : @"007BA7", @"Celadon green" : @"2F847C", @"Celeste (colour)" : @"B2FFFF", @"Celestial blue" : @"4997D0", @"Cerise" : @"DE3163", @"Cerise pink" : @"EC3B83", @"Cerulean" : @"007BA7", @"Cerulean blue" : @"2A52BE", @"Cerulean frost" : @"6D9BC3", @"CG Blue" : @"007AA5", @"CG Red" : @"E03C31", @"Chamoisee" : @"A0785A", @"Champagne" : @"F7E7CE", @"Charcoal" : @"36454F", @"Charleston green" : @"232B2B", @"Charm pink" : @"E68FAC", @"Chartreuse (traditional)" : @"DFFF00", @"Chartreuse (web)" : @"7FFF00", @"Cherry" : @"DE3163", @"Cherry blossom pink" : @"FFB7C5", @"Chestnut" : @"954535", @"China pink" : @"DE6FA1", @"China rose" : @"A8516E", @"Chinese red" : @"AA381E", @"Chinese violet" : @"856088", @"Chocolate (traditional)" : @"7B3F00", @"Chocolate (web)" : @"D2691E", @"Chrome yellow" : @"FFA700", @"Cinereous" : @"98817B", @"Cinnabar" : @"E34234", @"Cinnamon" : @"D2691E", @"Citrine" : @"E4D00A", @"Citron" : @"9FA91F", @"Claret" : @"7F1734", @"Classic rose" : @"FBCCE7", @"Cobalt" : @"0047AB", @"Cocoa brown" : @"D2691E", @"Coconut" : @"965A3E", @"Coffee" : @"6F4E37", @"Columbia blue" : @"9BDDFF", @"Congo pink" : @"F88379", @"Cool black" : @"002E63", @"Cool grey" : @"8C92AC", @"Copper" : @"B87333", @"Copper (Crayola)" : @"DA8A67", @"Copper penny" : @"AD6F69", @"Copper red" : @"CB6D51", @"Copper rose" : @"996666", @"Coquelicot" : @"FF3800", @"Coral" : @"FF7F50", @"Coral pink" : @"F88379", @"Coral red" : @"FF4040", @"Cordovan" : @"893F45", @"Corn" : @"FBEC5D", @"Cornell Red" : @"B31B1B", @"Cornflower blue" : @"6495ED", @"Cornsilk" : @"FFF8DC", @"Cosmic latte" : @"FFF8E7", @"Cotton candy" : @"FFBCD9", @"Cream" : @"FFFDD0", @"Crimson" : @"DC143C", @"Crimson glory" : @"BE0032", @"Cyan" : @"00FFFF", @"Cyan (process)" : @"00B7EB", @"Cyber grape" : @"58427C", @"Daffodil" : @"FFFF31", @"Dandelion" : @"F0E130", @"Dark blue" : @"00008B", @"Dark blue-gray" : @"666699", @"Dark brown" : @"654321", @"Dark byzantium" : @"5D3954", @"Dark candy apple red" : @"A40000", @"Dark cerulean" : @"08457E", @"Dark chestnut" : @"986960", @"Dark coral" : @"CD5B45", @"Dark cyan" : @"008B8B", @"Dark electric blue" : @"536878", @"Dark goldenrod" : @"B8860B", @"Dark gray" : @"A9A9A9", @"Dark green" : @"013220", @"Dark imperial blue" : @"00416A", @"Dark jungle green" : @"1A2421", @"Dark khaki" : @"BDB76B", @"Dark lava" : @"483C32", @"Dark lavender" : @"734F96", @"Dark magenta" : @"8B008B", @"Dark midnight blue" : @"003366", @"Dark moss green" : @"4A5D23", @"Dark olive green" : @"556B2F", @"Dark orange" : @"FF8C00", @"Dark orchid" : @"9932CC", @"Dark pastel blue" : @"779ECB", @"Dark pastel green" : @"03C03C", @"Dark pastel purple" : @"966FD6", @"Dark pastel red" : @"C23B22", @"Dark pink" : @"E75480", @"Dark powder blue" : @"003399", @"Dark raspberry" : @"872657", @"Dark red" : @"8B0000", @"Dark salmon" : @"E9967A", @"Dark scarlet" : @"560319", @"Dark sea green" : @"8FBC8F", @"Dark sienna" : @"3C1414", @"Dark sky blue" : @"8CBED6", @"Dark slate blue" : @"483D8B", @"Dark slate gray" : @"2F4F4F", @"Dark spring green" : @"177245", @"Dark tan" : @"918151", @"Dark tangerine" : @"FFA812", @"Dark taupe" : @"483C32", @"Dark terra cotta" : @"CC4E5C", @"Dark turquoise" : @"00CED1", @"Dark vanilla" : @"D1BEA8", @"Dark violet" : @"9400D3", @"Dark yellow" : @"9B870C", @"Dartmouth green" : @"00703C", @"Davy's grey" : @"555555", @"Debian red" : @"D70A53", @"Deep carmine" : @"A9203E", @"Deep carmine pink" : @"EF3038", @"Deep carrot orange" : @"E9692C", @"Deep cerise" : @"DA3287", @"Deep champagne" : @"FAD6A5", @"Deep chestnut" : @"B94E48", @"Deep coffee" : @"704241", @"Deep fuchsia" : @"C154C1", @"Deep jungle green" : @"004B49", @"Deep lemon" : @"F5C71A", @"Deep lilac" : @"9955BB", @"Deep magenta" : @"CC00CC", @"Deep mauve" : @"D473D4", @"Deep moss green" : @"355E3B", @"Deep peach" : @"FFCBA4", @"Deep pink" : @"FF1493", @"Deep ruby" : @"843F5B", @"Deep saffron" : @"FF9933", @"Deep sky blue" : @"00BFFF", @"Deep Space Sparkle" : @"4A646C", @"Deep Taupe" : @"7E5E60", @"Deep Tuscan red" : @"66424D", @"Deer" : @"BA8759", @"Denim" : @"1560BD", @"Desert" : @"C19A6B", @"Desert sand" : @"EDC9AF", @"Diamond" : @"B9F2FF", @"Dim gray" : @"696969", @"Dirt" : @"9B7653", @"Dodger blue" : @"1E90FF", @"Dogwood rose" : @"D71868", @"Dollar bill" : @"85BB65", @"Drab" : @"967117", @"Duke blue" : @"00009C", @"Dust storm" : @"E5CCC9", @"Earth yellow" : @"E1A95F", @"Ebony" : @"555D50", @"Ecru" : @"C2B280", @"Eggplant" : @"614051", @"Eggshell" : @"F0EAD6", @"Egyptian blue" : @"1034A6", @"Electric blue" : @"7DF9FF", @"Electric crimson" : @"FF003F", @"Electric cyan" : @"00FFFF", @"Electric green" : @"00FF00", @"Electric indigo" : @"6F00FF", @"Electric lavender" : @"F4BBFF", @"Electric lime" : @"CCFF00", @"Electric purple" : @"BF00FF", @"Electric ultramarine" : @"3F00FF", @"Electric violet" : @"8F00FF", @"Electric yellow" : @"FFFF33", @"Emerald" : @"50C878", @"English green" : @"1B4D3E", @"English lavender" : @"B48395", @"English red" : @"AB4B52", @"English violet" : @"563C5C", @"Eton blue" : @"96C8A2", @"Eucalyptus" : @"44D7A8", @"Fallow" : @"C19A6B", @"Falu red" : @"801818", @"Fandango" : @"B53389", @"Fandango pink" : @"DE5285", @"Fashion fuchsia" : @"F400A1", @"Fawn" : @"E5AA70", @"Feldgrau" : @"4D5D53", @"Feldspar" : @"FDD5B1", @"Fern green" : @"4F7942", @"Ferrari Red" : @"FF2800", @"Field drab" : @"6C541E", @"Firebrick" : @"B22222", @"Fire engine red" : @"CE2029", @"Flame" : @"E25822", @"Flamingo pink" : @"FC8EAC", @"Flattery" : @"6B4423", @"Flavescent" : @"F7E98E", @"Flax" : @"EEDC82", @"Floral white" : @"FFFAF0", @"Fluorescent orange" : @"FFBF00", @"Fluorescent pink" : @"FF1493", @"Fluorescent yellow" : @"CCFF00", @"Folly" : @"FF004F", @"Forest green (traditional)" : @"014421", @"Forest green (web)" : @"228B22", @"French beige" : @"A67B5B", @"French bistre" : @"856D4D", @"French blue" : @"0072BB", @"French lilac" : @"86608E", @"French lime" : @"9EFD38", @"French mauve" : @"D473D4", @"French raspberry" : @"C72C48", @"French rose" : @"F64A8A", @"French sky blue" : @"77B5FE", @"French wine" : @"AC1E44", @"Fresh Air" : @"A6E7FF", @"Fuchsia" : @"FF00FF", @"Fuchsia (Crayola)" : @"C154C1", @"Fuchsia pink" : @"FF77FF", @"Fuchsia rose" : @"C74375", @"Fulvous" : @"E48400", @"Fuzzy Wuzzy" : @"CC6666", @"Gainsboro" : @"DCDCDC", @"Gamboge" : @"E49B0F", @"Ghost white" : @"F8F8FF", @"Giants orange" : @"FE5A1D", @"Ginger" : @"B06500", @"Glaucous" : @"6082B6", @"Glitter" : @"E6E8FA", @"GO green" : @"00AB66", @"Gold (metallic)" : @"D4AF37", @"Gold (web) (Golden)" : @"FFD700", @"Gold Fusion" : @"85754E", @"Golden brown" : @"996515", @"Golden poppy" : @"FCC200", @"Golden yellow" : @"FFDF00", @"Goldenrod" : @"DAA520", @"Granny Smith Apple" : @"A8E4A0", @"Grape" : @"6F2DA8", @"Gray" : @"808080", @"Gray (HTML/CSS gray)" : @"808080", @"Gray (X11 gray)" : @"BEBEBE", @"Gray-asparagus" : @"465945", @"Gray-blue" : @"8C92AC", @"Green (color wheel) (X11 green)" : @"00FF00", @"Green (Crayola)" : @"1CAC78", @"Green (HTML/CSS color)" : @"008000", @"Green (Munsell)" : @"00A877", @"Green (NCS)" : @"009F6B", @"Green (pigment)" : @"00A550", @"Green (RYB)" : @"66B032", @"Green-yellow" : @"ADFF2F", @"Grullo" : @"A99A86", @"Guppie green" : @"00FF7F", @"Halayà úbe" : @"663854", @"Han blue" : @"446CCF", @"Han purple" : @"5218FA", @"Hansa yellow" : @"E9D66B", @"Harlequin" : @"3FFF00", @"Harvard crimson" : @"C90016", @"Harvest gold" : @"DA9100", @"Heart Gold" : @"808000", @"Heliotrope" : @"DF73FF", @"Hollywood cerise" : @"F400A1", @"Honeydew" : @"F0FFF0", @"Honolulu blue" : @"006DB0", @"Hooker's green" : @"49796B", @"Hot magenta" : @"FF1DCE", @"Hot pink" : @"FF69B4", @"Hunter green" : @"355E3B", @"Iceberg" : @"71A6D2", @"Icterine" : @"FCF75E", @"Illuminating Emerald" : @"319177", @"Imperial" : @"602F6B", @"Imperial blue" : @"002395", @"Imperial purple" : @"66023C", @"Imperial red" : @"ED2939", @"Inchworm" : @"B2EC5D", @"India green" : @"138808", @"Indian red" : @"CD5C5C", @"Indian yellow" : @"E3A857", @"Indigo" : @"6F00FF", @"Indigo (dye)" : @"00416A", @"Indigo (web)" : @"4B0082", @"International Klein Blue" : @"002FA7", @"International orange (aerospace)" : @"FF4F00", @"International orange (engineering)" : @"BA160C", @"International orange (Golden Gate Bridge)" : @"C0362C", @"Iris" : @"5A4FCF", @"Irresistible" : @"B3446C", @"Isabelline" : @"F4F0EC", @"Islamic green" : @"009000", @"Italian sky blue" : @"B2FFFF", @"Ivory" : @"FFFFF0", @"Jade" : @"00A86B", @"Japanese indigo" : @"264348", @"Japanese violet" : @"5B3256", @"Jasmine" : @"F8DE7E", @"Jasper" : @"D73B3E", @"Jazzberry jam" : @"A50B5E", @"Jelly Bean" : @"DA614E", @"Jet" : @"343434", @"Jonquil" : @"F4CA16", @"June bud" : @"BDDA57", @"Jungle green" : @"29AB87", @"Kelly green" : @"4CBB17", @"Kenyan copper" : @"7C1C05", @"Keppel" : @"3AB09E", @"Khaki (HTML/CSS) (Khaki)" : @"C3B091", @"Khaki (X11) (Light khaki)" : @"F0E68C", @"Kobe" : @"882D17", @"Kobi" : @"E79FC4", @"KU Crimson" : @"E8000D", @"La Salle Green" : @"087830", @"Languid lavender" : @"D6CADD", @"Lapis lazuli" : @"26619C", @"Laser Lemon" : @"FFFF66", @"Laurel green" : @"A9BA9D", @"Lava" : @"CF1020", @"Lavender (floral)" : @"B57EDC", @"Lavender (web)" : @"E6E6FA", @"Lavender blue" : @"CCCCFF", @"Lavender blush" : @"FFF0F5", @"Lavender gray" : @"C4C3D0", @"Lavender indigo" : @"9457EB", @"Lavender magenta" : @"EE82EE", @"Lavender mist" : @"E6E6FA", @"Lavender pink" : @"FBAED2", @"Lavender purple" : @"967BB6", @"Lavender rose" : @"FBA0E3", @"Lawn green" : @"7CFC00", @"Lemon" : @"FFF700", @"Lemon chiffon" : @"FFFACD", @"Lemon curry" : @"CCA01D", @"Lemon glacier" : @"FDFF00", @"Lemon lime" : @"E3FF00", @"Lemon meringue" : @"F6EABE", @"Lemon yellow" : @"FFF44F", @"Licorice" : @"1A1110", @"Light apricot" : @"FDD5B1", @"Light blue" : @"ADD8E6", @"Light brown" : @"B5651D", @"Light carmine pink" : @"E66771", @"Light coral" : @"F08080", @"Light cornflower blue" : @"93CCEA", @"Light crimson" : @"F56991", @"Light cyan" : @"E0FFFF", @"Light fuchsia pink" : @"F984EF", @"Light goldenrod yellow" : @"FAFAD2", @"Light gray" : @"D3D3D3", @"Light green" : @"90EE90", @"Light khaki" : @"F0E68C", @"Light medium orchid" : @"D39BCB", @"Light moss green" : @"ADDFAD", @"Light orchid" : @"E6A8D7", @"Light pastel purple" : @"B19CD9", @"Light pink" : @"FFB6C1", @"Light red ochre" : @"E97451", @"Light salmon" : @"FFA07A", @"Light salmon pink" : @"FF9999", @"Light sea green" : @"20B2AA", @"Light sky blue" : @"87CEFA", @"Light slate gray" : @"778899", @"Light steel blue" : @"B0C4DE", @"Light taupe" : @"B38B6D", @"Light Thulian pink" : @"E68FAC", @"Light yellow" : @"FFFFE0", @"Lilac" : @"C8A2C8", @"Lime (color wheel)" : @"BFFF00", @"Lime (web) (X11 green)" : @"00FF00", @"Lime green" : @"32CD32", @"Limerick" : @"9DC209", @"Lincoln green" : @"195905", @"Linen" : @"FAF0E6", @"Lion" : @"C19A6B", @"Little boy blue" : @"6CA0DC", @"Liver" : @"534B4F", @"Lumber" : @"FFE4CD", @"Lust" : @"E62020", @"Magenta" : @"FF00FF", @"Magenta (Crayola)" : @"FF55A3", @"Magenta (dye)" : @"CA1F7B", @"Magenta (Pantone)" : @"D0417E", @"Magenta (process)" : @"FF0090", @"Magic mint" : @"AAF0D1", @"Magnolia" : @"F8F4FF", @"Mahogany" : @"C04000", @"Maize" : @"FBEC5D", @"Majorelle Blue" : @"6050DC", @"Malachite" : @"0BDA51", @"Manatee" : @"979AAA", @"Mango Tango" : @"FF8243", @"Mantis" : @"74C365", @"Mardi Gras" : @"880085", @"Maroon (Crayola)" : @"C32148", @"Maroon (HTML/CSS)" : @"800000", @"Maroon (X11)" : @"B03060", @"Mauve" : @"E0B0FF", @"Mauve taupe" : @"915F6D", @"Mauvelous" : @"EF98AA", @"Maya blue" : @"73C2FB", @"Meat brown" : @"E5B73B", @"Medium aquamarine" : @"66DDAA", @"Medium blue" : @"0000CD", @"Medium candy apple red" : @"E2062C", @"Medium carmine" : @"AF4035", @"Medium champagne" : @"F3E5AB", @"Medium electric blue" : @"035096", @"Medium jungle green" : @"1C352D", @"Medium lavender magenta" : @"DDA0DD", @"Medium orchid" : @"BA55D3", @"Medium Persian blue" : @"0067A5", @"Medium purple" : @"9370DB", @"Medium red-violet" : @"BB3385", @"Medium ruby" : @"AA4069", @"Medium sea green" : @"3CB371", @"Medium sky blue" : @"80DAEB", @"Medium slate blue" : @"7B68EE", @"Medium spring bud" : @"C9DC87", @"Medium spring green" : @"00FA9A", @"Medium taupe" : @"674C47", @"Medium turquoise" : @"48D1CC", @"Medium Tuscan red" : @"79443B", @"Medium vermilion" : @"D9603B", @"Medium violet-red" : @"C71585", @"Mellow apricot" : @"F8B878", @"Mellow yellow" : @"F8DE7E", @"Melon" : @"FDBCB4", @"Metallic Seaweed" : @"0A7E8C", @"Metallic Sunburst" : @"9C7C38", @"Mexican pink" : @"E4007C", @"Midnight blue" : @"191970", @"Midnight green (eagle green)" : @"004953", @"Midori" : @"E3F988", @"Mikado yellow" : @"FFC40C", @"Mint" : @"3EB489", @"Mint cream" : @"F5FFFA", @"Mint green" : @"98FF98", @"Misty rose" : @"FFE4E1", @"Moccasin" : @"FAEBD7", @"Mode beige" : @"967117", @"Moonstone blue" : @"73A9C2", @"Mordant red 19" : @"AE0C00", @"Moss green" : @"8A9A5B", @"Mountain Meadow" : @"30BA8F", @"Mountbatten pink" : @"997A8D", @"MSU Green" : @"18453B", @"Mughal green" : @"306030", @"Mulberry" : @"C54B8C", @"Mustard" : @"FFDB58", @"Myrtle green" : @"317873", @"Nadeshiko pink" : @"F6ADC6", @"Napier green" : @"2A8000", @"Naples yellow" : @"FADA5E", @"Navajo white" : @"FFDEAD", @"Navy blue" : @"000080", @"Navy purple" : @"9457EB", @"Neon Carrot" : @"FFA343", @"Neon fuchsia" : @"FE4164", @"Neon green" : @"39FF14", @"New Car" : @"214FC6", @"New York pink" : @"D7837F", @"Non-photo blue" : @"A4DDED", @"North Texas Green" : @"059033", @"Nyanza" : @"E9FFDB", @"Ocean Boat Blue" : @"0077BE", @"Ochre" : @"CC7722", @"Office green" : @"008000", @"Old burgundy" : @"43302E", @"Old gold" : @"CFB53B", @"Old lace" : @"FDF5E6", @"Old lavender" : @"796878", @"Old mauve" : @"673147", @"Old moss green" : @"867E36", @"Old rose" : @"C08081", @"Old silver" : @"848482", @"Olive" : @"808000", @"Olive Drab (web) (Olive Drab #3)" : @"6B8E23", @"Olive Drab #7" : @"3C341F", @"Olivine" : @"9AB973", @"Onyx" : @"353839", @"Opera mauve" : @"B784A7", @"Orange (color wheel)" : @"FF7F00", @"Orange (Crayola)" : @"FF7538", @"Orange (Pantone)" : @"FF5800", @"Orange (RYB)" : @"FB9902", @"Orange (web color)" : @"FFA500", @"Orange peel" : @"FF9F00", @"Orange-red" : @"FF4500", @"Orchid" : @"DA70D6", @"Orchid pink" : @"F28DCD", @"Orioles orange" : @"FB4F14", @"Otter brown" : @"654321", @"Outer Space" : @"414A4C", @"Outrageous Orange" : @"FF6E4A", @"Oxford Blue" : @"002147", @"OU Crimson Red" : @"990000", @"Pakistan green" : @"006600", @"Palatinate blue" : @"273BE2", @"Palatinate purple" : @"682860", @"Pale aqua" : @"BCD4E6", @"Pale blue" : @"AFEEEE", @"Pale brown" : @"987654", @"Pale carmine" : @"AF4035", @"Pale cerulean" : @"9BC4E2", @"Pale chestnut" : @"DDADAF", @"Pale copper" : @"DA8A67", @"Pale cornflower blue" : @"ABCDEF", @"Pale gold" : @"E6BE8A", @"Pale goldenrod" : @"EEE8AA", @"Pale green" : @"98FB98", @"Pale lavender" : @"DCD0FF", @"Pale magenta" : @"F984E5", @"Pale pink" : @"FADADD", @"Pale plum" : @"DDA0DD", @"Pale red-violet" : @"DB7093", @"Pale robin egg blue" : @"96DED1", @"Pale silver" : @"C9C0BB", @"Pale spring bud" : @"ECEBBD", @"Pale taupe" : @"BC987E", @"Pale turquoise" : @"AFEEEE", @"Pale violet-red" : @"DB7093", @"Pansy purple" : @"78184A", @"Papaya whip" : @"FFEFD5", @"Paris Green" : @"50C878", @"Pastel blue" : @"AEC6CF", @"Pastel brown" : @"836953", @"Pastel gray" : @"CFCFC4", @"Pastel green" : @"77DD77", @"Pastel magenta" : @"F49AC2", @"Pastel orange" : @"FFB347", @"Pastel pink" : @"DEA5A4", @"Pastel purple" : @"B39EB5", @"Pastel red" : @"FF6961", @"Pastel violet" : @"CB99C9", @"Pastel yellow" : @"FDFD96", @"Patriarch" : @"800080", @"Payne's grey" : @"536878", @"Peach" : @"FFE5B4", @"Peach (Crayola)" : @"FFCBA4", @"Peach-orange" : @"FFCC99", @"Peach puff" : @"FFDAB9", @"Peach-yellow" : @"FADFAD", @"Pear" : @"D1E231", @"Pearl" : @"EAE0C8", @"Pearl Aqua" : @"88D8C0", @"Pearly purple" : @"B768A2", @"Peridot" : @"E6E200", @"Periwinkle" : @"CCCCFF", @"Persian blue" : @"1C39BB", @"Persian green" : @"00A693", @"Persian indigo" : @"32127A", @"Persian orange" : @"D99058", @"Persian pink" : @"F77FBE", @"Persian plum" : @"701C1C", @"Persian red" : @"CC3333", @"Persian rose" : @"FE28A2", @"Persimmon" : @"EC5800", @"Peru" : @"CD853F", @"Phlox" : @"DF00FF", @"Phthalo blue" : @"000F89", @"Phthalo green" : @"123524", @"Pictorial carmine" : @"C30B4E", @"Piggy pink" : @"FDDDE6", @"Pine green" : @"01796F", @"Pink" : @"FFC0CB", @"Pink lace" : @"FFDDF4", @"Pink-orange" : @"FF9966", @"Pink pearl" : @"E7ACCF", @"Pink Sherbet" : @"F78FA7", @"Pistachio" : @"93C572", @"Platinum" : @"E5E4E2", @"Plum (traditional)" : @"8E4585", @"Plum (web)" : @"DDA0DD", @"Pomp and Power" : @"86608E", @"Portland Orange" : @"FF5A36", @"Powder blue (web)" : @"B0E0E6", @"Princeton orange" : @"FF8F00", @"Prune" : @"701C1C", @"Prussian blue" : @"003153", @"Psychedelic purple" : @"DF00FF", @"Puce" : @"CC8899", @"Pumpkin" : @"FF7518", @"Purple (HTML/CSS)" : @"800080", @"Purple (Munsell)" : @"9F00C5", @"Purple (X11)" : @"A020F0", @"Purple Heart" : @"69359C", @"Purple mountain majesty" : @"9678B6", @"Purple pizzazz" : @"FE4EDA", @"Purple taupe" : @"50404D", @"Quartz" : @"51484F", @"Queen blue" : @"436B95", @"Queen pink" : @"E8CCD7", @"Rackley" : @"5D8AA8", @"Radical Red" : @"FF355E", @"Rajah" : @"FBAB60", @"Raspberry" : @"E30B5D", @"Raspberry glace" : @"915F6D", @"Raspberry pink" : @"E25098", @"Raspberry rose" : @"B3446C", @"Raw umber" : @"826644", @"Razzle dazzle rose" : @"FF33CC", @"Razzmatazz" : @"E3256B", @"Razzmic Berry" : @"8D4E85", @"Red" : @"FF0000", @"Red (Crayola)" : @"EE204D", @"Red (Munsell)" : @"F2003C", @"Red (NCS)" : @"C40233", @"Red (Pantone)" : @"ED2939", @"Red (pigment)" : @"ED1C24", @"Red (RYB)" : @"FE2712", @"Red-brown" : @"A52A2A", @"Red devil" : @"860111", @"Red-orange" : @"FF5349", @"Red-violet" : @"C71585", @"Redwood" : @"A45A52", @"Regalia" : @"522D80", @"Resolution blue" : @"002387", @"Rhythm" : @"777696", @"Rich black" : @"004040", @"Rich brilliant lavender" : @"F1A7FE", @"Rich carmine" : @"D70040", @"Rich electric blue" : @"0892D0", @"Rich lavender" : @"A76BCF", @"Rich lilac" : @"B666D2", @"Rich maroon" : @"B03060", @"Rifle green" : @"444C38", @"Robin egg blue" : @"00CCCC", @"Rocket metallic" : @"8A7F80", @"Roman silver" : @"838996", @"Rose" : @"FF007F", @"Rose bonbon" : @"F9429E", @"Rose ebony" : @"674846", @"Rose gold" : @"B76E79", @"Rose madder" : @"E32636", @"Rose pink" : @"FF66CC", @"Rose quartz" : @"AA98A9", @"Rose red" : @"C21E56", @"Rose taupe" : @"905D5D", @"Rose vale" : @"AB4E52", @"Rosewood" : @"65000B", @"Rosso corsa" : @"D40000", @"Rosy brown" : @"BC8F8F", @"Royal azure" : @"0038A8", @"Royal blue (traditional)" : @"002366", @"Royal blue (web)" : @"4169E1", @"Royal fuchsia" : @"CA2C92", @"Royal purple" : @"7851A9", @"Royal yellow" : @"FADA5E", @"Ruber" : @"CE4676", @"Rubine red" : @"D10056", @"Ruby" : @"E0115F", @"Ruby red" : @"9B111E", @"Ruddy" : @"FF0028", @"Ruddy brown" : @"BB6528", @"Ruddy pink" : @"E18E96", @"Rufous" : @"A81C07", @"Russet" : @"80461B", @"Russian green" : @"679267", @"Russian violet" : @"32174D", @"Rust" : @"B7410E", @"Rusty red" : @"DA2C43", @"Sacramento State green" : @"00563F", @"Saddle brown" : @"8B4513", @"Safety orange (blaze orange)" : @"FF6700", @"Safety yellow" : @"EED202", @"Saffron" : @"F4C430", @"St. Patrick's blue" : @"23297A", @"Salmon" : @"FF8C69", @"Salmon pink" : @"FF91A4", @"Sand" : @"C2B280", @"Sand dune" : @"967117", @"Sandstorm" : @"ECD540", @"Sandy brown" : @"F4A460", @"Sandy taupe" : @"967117", @"Sangria" : @"92000A", @"Sap green" : @"507D2A", @"Sapphire" : @"0F52BA", @"Sapphire blue" : @"0067A5", @"Satin sheen gold" : @"CBA135", @"Scarlet" : @"FF2400", @"Scarlet (Crayola)" : @"FD0E35", @"Schauss pink" : @"FF91AF", @"School bus yellow" : @"FFD800", @"Screamin' Green" : @"76FF7A", @"Sea blue" : @"006994", @"Sea green" : @"2E8B57", @"Seal brown" : @"321414", @"Seashell" : @"FFF5EE", @"Selective yellow" : @"FFBA00", @"Sepia" : @"704214", @"Shadow" : @"8A795D", @"Shampoo" : @"FFCFF1", @"Shamrock green" : @"009E60", @"Sheen Green" : @"8FD400", @"Shimmering Blush" : @"D98695", @"Shocking pink" : @"FC0FC0", @"Shocking pink (Crayola)" : @"FF6FFF", @"Sienna" : @"882D17", @"Silver" : @"C0C0C0", @"Silver chalice" : @"ACACAC", @"Silver Lake blue" : @"5D89BA", @"Silver pink" : @"C4AEAD", @"Silver sand" : @"BFC1C2", @"Sinopia" : @"CB410B", @"Skobeloff" : @"007474", @"Sky blue" : @"87CEEB", @"Sky magenta" : @"CF71AF", @"Slate blue" : @"6A5ACD", @"Slate gray" : @"708090", @"Smalt (Dark powder blue)" : @"003399", @"Smitten" : @"C84186", @"Smoke" : @"738276", @"Smokey topaz" : @"933D41", @"Smoky black" : @"100C08", @"Snow" : @"FFFAFA", @"Soap" : @"CEC8EF", @"Sonic silver" : @"757575", @"Spartan Crimson" : @"9E1316", @"Space cadet" : @"1D2951", @"Spanish bistre" : @"80755A", @"Spanish carmine" : @"D10047", @"Spanish crimson" : @"E51A4C", @"Spanish orange" : @"E86100", @"Spanish sky blue" : @"00AAE4", @"Spiro Disco Ball" : @"0FC0FC", @"Spring bud" : @"A7FC00", @"Spring green" : @"00FF7F", @"Star command blue" : @"007BB8", @"Steel blue" : @"4682B4", @"Steel pink" : @"CC3366", @"Stil de grain yellow" : @"FADA5E", @"Stizza" : @"990000", @"Stormcloud" : @"4F666A", @"Straw" : @"E4D96F", @"Strawberry" : @"FC5A8D", @"Sunglow" : @"FFCC33", @"Sunray" : @"E3AB57", @"Sunset" : @"FAD6A5", @"Sunset orange" : @"FD5E53", @"Super pink" : @"CF6BA9", @"Tan" : @"D2B48C", @"Tangelo" : @"F94D00", @"Tangerine" : @"F28500", @"Tangerine yellow" : @"FFCC00", @"Tango pink" : @"E4717A", @"Taupe" : @"483C32", @"Taupe gray" : @"8B8589", @"Tea green" : @"D0F0C0", @"Tea rose (orange)" : @"F88379", @"Tea rose (rose)" : @"F4C2C2", @"Teal" : @"008080", @"Teal blue" : @"367588", @"Teal deer" : @"99E6B3", @"Teal green" : @"00827F", @"Telemagenta" : @"CF3476", @"Tenné (Tawny)" : @"CD5700", @"Terra cotta" : @"E2725B", @"Thistle" : @"D8BFD8", @"Thulian pink" : @"DE6FA1", @"Tickle Me Pink" : @"FC89AC", @"Tiffany Blue" : @"0ABAB5", @"Tiger's eye" : @"E08D3C", @"Timberwolf" : @"DBD7D2", @"Titanium yellow" : @"EEE600", @"Tomato" : @"FF6347", @"Toolbox" : @"746CC0", @"Topaz" : @"FFC87C", @"Tractor red" : @"FD0E35", @"Trolley Grey" : @"808080", @"Tropical rain forest" : @"00755E", @"True Blue" : @"0073CF", @"Tufts Blue" : @"417DC1", @"Tulip" : @"FF878D", @"Tumbleweed" : @"DEAA88", @"Turkish rose" : @"B57281", @"Turquoise" : @"30D5C8", @"Turquoise blue" : @"00FFEF", @"Turquoise green" : @"A0D6B4", @"Tuscan" : @"FAD6A5", @"Tuscan brown" : @"6F4E37", @"Tuscan red" : @"7C4848", @"Tuscan tan" : @"A67B5B", @"Tuscany" : @"C09999", @"Twilight lavender" : @"8A496B", @"Tyrian purple" : @"66023C", @"UA blue" : @"0033AA", @"UA red" : @"D9004C", @"Ube" : @"8878C3", @"UCLA Blue" : @"536895", @"UCLA Gold" : @"FFB300", @"UFO Green" : @"3CD070", @"Ultramarine" : @"120A8F", @"Ultramarine blue" : @"4166F5", @"Ultra pink" : @"FF6FFF", @"Umber" : @"635147", @"Unbleached silk" : @"FFDDCA", @"United Nations blue" : @"5B92E5", @"University of California Gold" : @"B78727", @"Unmellow yellow" : @"FFFF66", @"UP Forest green" : @"014421", @"UP Maroon" : @"7B1113", @"Upsdell red" : @"AE2029", @"Urobilin" : @"E1AD21", @"USAFA blue" : @"004F98", @"USC Cardinal" : @"990000", @"USC Gold" : @"FFCC00", @"University of Tennessee Orange" : @"F77F00", @"Utah Crimson" : @"D3003F", @"Vanilla" : @"F3E5AB", @"Vanilla ice" : @"F3D9DF", @"Vegas gold" : @"C5B358", @"Venetian red" : @"C80815", @"Verdigris" : @"43B3AE", @"Vermilion (cinnabar)" : @"E34234", @"Vermilion (Plochere)" : @"D9603B", @"Veronica" : @"A020F0", @"Violet" : @"8F00FF", @"Violet (color wheel)" : @"7F00FF", @"Violet (RYB)" : @"8601AF", @"Violet (web)" : @"EE82EE", @"Violet-blue" : @"324AB2", @"Violet-red" : @"F75394", @"Viridian" : @"40826D", @"Vivid auburn" : @"922724", @"Vivid burgundy" : @"9F1D35", @"Vivid cerise" : @"DA1D81", @"Vivid orchid" : @"CC00FF", @"Vivid sky blue" : @"00CCFF", @"Vivid tangerine" : @"FFA089", @"Vivid violet" : @"9F00FF", @"Warm black" : @"004242", @"Waterspout" : @"A4F4F9", @"Wenge" : @"645452", @"Wheat" : @"F5DEB3", @"White" : @"FFFFFF", @"White smoke" : @"F5F5F5", @"Wild blue yonder" : @"A2ADD0", @"Wild orchid" : @"D77A02", @"Wild Strawberry" : @"FF43A4", @"Wild Watermelon" : @"FC6C85", @"Windsor tan" : @"AE6838", @"Wine" : @"722F37", @"Wine dregs" : @"673147", @"Wisteria" : @"C9A0DC", @"Wood brown" : @"C19A6B", @"Xanadu" : @"738678", @"Yale Blue" : @"0F4D92", @"Yankees blue" : @"1C2841", @"Yellow" : @"FFFF00", @"Yellow (Munsell)" : @"EFCC00", @"Yellow (NCS)" : @"FFD300", @"Yellow (process)" : @"FFEF00", @"Yellow (RYB)" : @"FEFE33", @"Yellow-green" : @"9ACD32", @"Yellow Orange" : @"FFAE42", @"Yellow rose" : @"FFF000", @"Zaffre" : @"0014A8", @"Zinnwaldite brown" : @"2C1608", @"Zomp" : @"39A78E"};
    
    colorNameDictionaries = @{
                              @"Base" : baseDictionary,
                              @"Crayon" : crayonDictionary,
                              @"CSS" : cssDictionary,
                              @"System" : systemColorDictionary,
                              @"Wikipedia" : wikipediaColorDictionary,
                              };
    
}

+ (NSArray *) availableColorDictionaries
{
    [self initializeColorDictionaries];
    return colorNameDictionaries.allKeys;
}

+ (NSDictionary *) colorDictionaryNamed: (NSString *) dictionaryName
{
    [self initializeColorDictionaries];
    if (!dictionaryName)
    {
        NSLog(@"Error: invalid dictionary name");
        return nil;
    }
    return colorNameDictionaries[dictionaryName];
}

+ (UIColor *) colorWithName: (NSString *) name inDictionary: (NSString *) dictionaryName
{
    [self initializeColorDictionaries];

    if (!dictionaryName || !name)
    {
        NSLog(@"Error: invalid color or dictionary name");
        return nil;
    }

    NSDictionary *colorDictionary = colorNameDictionaries[dictionaryName];
    if (!colorDictionary)
    {
        NSLog(@"Error: invalid dictionary name");
        return nil;
    }
    
    NSString *hexkey = colorDictionary[name];
    if (!hexkey)
        return nil;
    
    return [UIColor colorWithHexString:hexkey];
}

+ (UIColor *) colorWithName: (NSString *) name
{
    [self initializeColorDictionaries];

    if (!name)
    {
        NSLog(@"Error: invalid color name");
        return nil;
    }
    
    for (NSString *dictionary in colorNameDictionaries.allKeys)
    {
        UIColor *color = [self colorWithName:name inDictionary:dictionary];
        if (color)
            return color;
    }
    
    return nil;
}

- (NSString *) closestColorNameUsingDictionary: (NSString *) dictionaryName
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use closestColorName");
    
    [UIColor initializeColorDictionaries];
    
    if (!dictionaryName)
    {
        NSLog(@"Error: Must suply dictionary name to look up color");
        return nil;
    }
    
    [UIColor initializeColorDictionaries];
    if (!colorNameDictionaries[dictionaryName])
    {
        NSLog(@"Error: invalid dictionary name");
        return nil;
    }
    
    NSDictionary *colorDictionary = colorNameDictionaries[dictionaryName];
	
	int targetHex = self.rgbHex;
	int rInt = (targetHex >> 16) & 0x0ff;
	int gInt = (targetHex >> 8) & 0x0ff;
	int bInt = (targetHex >> 0) & 0x0ff;
	
	float bestScore = MAXFLOAT;
    NSString *bestKey = nil;
    
    for (NSString *colorName in colorDictionary.allKeys)
    {
        NSString *colorHex = colorDictionary[colorName];
        
		int r, g, b;
		if (sscanf(colorHex.UTF8String, "%2x%2x%2x", &r, &g, &b) == 3)
        {
            int dR = rInt - r;
			int dG = gInt - g;
			int dB = bInt - b;
            float score = sqrtf(dR * dR + dG * dG + dB * dB);
            
            if (score < bestScore)
            {
                bestScore = score;
                bestKey = colorName;
            }
        }
    }
	
	return bestKey;
}

- (NSString *) closestColorName
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use closestColorName");
    
    float bestScore = MAXFLOAT;
    NSString *bestKey = nil;
    
    for (NSString *dictionaryName in [UIColor availableColorDictionaries])
    {
        NSString *colorString = [self closestColorNameUsingDictionary:dictionaryName];
        if (!colorString)
            continue;
        
        UIColor *color = [UIColor colorWithName:colorString inDictionary:dictionaryName];
        CGFloat distance = [self distanceFrom:color];
        
        if (distance < bestScore)
        {
            bestScore = distance;
            bestKey = colorString;
        }
    }
    
    return bestKey;
}

- (NSString *) closestCrayonName
{
    return [self closestColorNameUsingDictionary:@"Crayon"];
}

- (NSString *) closestCSSName
{
    return [self closestColorNameUsingDictionary:@"CSS"];
}

- (NSString *) closestBaseName
{
    return [self closestColorNameUsingDictionary:@"Base"];
}

- (NSString *) closestSystemColorName
{
    return [self closestColorNameUsingDictionary:@"System"];
}

- (NSString *) closestWikipediaColorName
{
    return [self closestColorNameUsingDictionary:@"Wikipedia"];
}

- (UIColor *) closestMensColor
{
    NSString *colorName = [self closestColorNameUsingDictionary:@"System"];
    return [UIColor systemColorWithName:colorName];
}


+ (UIColor *) crayonWithName: (NSString *) name
{
    [self initializeColorDictionaries];
    if (!name)
        return nil;
    
    return [self colorWithName:name inDictionary:@"Crayon"];
}

+ (UIColor *) baseColorWithName: (NSString *) name
{
    [self initializeColorDictionaries];
    if (!name)
        return nil;
    
    return [self colorWithName:name inDictionary:@"Base"];
}

+ (UIColor *) cssColorWithName: (NSString *) name
{
    [self initializeColorDictionaries];
    if (!name)
        return nil;
    return [self colorWithName:name inDictionary:@"CSS"];
}

+ (UIColor *) systemColorWithName: (NSString *) name
{
    [self initializeColorDictionaries];
    if (!name)
        return nil;
    return [self colorWithName:name inDictionary:@"System"];
}
@end