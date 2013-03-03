#import "UIColor-Expanded.h"

@implementation UIColor (UIColor_Expanded)

// Generate a color wheel. You supply the size, e.g.
// UIImage *image = [UIColor colorWheelOfSize:500];
// [UIImagePNGRepresentation(image) writeToFile:DOCS_PATH(@"foo.png") atomically:YES];

+ (UIImage *) colorWheelOfSize: (CGFloat) side border: (BOOL) useBorder
{
    UIBezierPath *path;
    CGSize size = CGSizeMake(side, side);
    CGPoint center = CGPointMake(side / 2, side / 2);

    UIGraphicsBeginImageContext(size);
    
    for (int i = 0; i < 6; i++)
    {
        CGFloat width = side / 14;
        CGFloat radius = width * (i + 1.0f);
        CGFloat saturation = (i + 1.0f) / 6.0f;
        
        for (CGFloat theta = 0; theta < M_PI * 2; theta += (M_PI / 6))
        {
            CGFloat hue = theta / (2 * M_PI);
            UIColor *c = [UIColor colorWithHue:hue saturation:saturation brightness:1 alpha:1.0f];

            CGFloat angle = (theta - M_PI_2);
            if (angle < 0)
                angle += 2 * M_PI;
            
            path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:angle endAngle:(angle + M_PI / 6) clockwise:YES];
            path.lineWidth = width;
            
            [c set];
            [path stroke];
        }
    }
    
    if (useBorder)
    {
        [[UIColor blackColor] set];
        path = [UIBezierPath bezierPathWithArcCenter:center radius:(side / 2) - (side / 28) startAngle:0 endAngle:2 * M_PI clockwise:YES];
        path.lineWidth = 2;
        [path stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Color Space

// Report model
- (CGColorSpaceModel) colorSpaceModel
{
	return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

// Represent model as string
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

// Report color space as string
- (NSString *) colorSpaceString
{
    return [UIColor colorSpaceString:self.colorSpaceModel];
}

// Supports either RGB or W
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

// Convenience: Test for Monochrome
- (BOOL) usesMonochromeColorspace
{
    return (self.colorSpaceModel == kCGColorSpaceModelMonochrome);
}

// Convenience: Test for RGB
- (BOOL) usesRGBColorspace
{
    return (self.colorSpaceModel == kCGColorSpaceModelRGB);
}

#pragma mark - Color Conversion

// I know. This could probably be just as easily done by
// creating a color and pulling out the components.
// Live, learn.

+ (void) hue: (CGFloat) h
  saturation: (CGFloat) s
  brightness: (CGFloat) v
       toRed: (CGFloat *) pR
       green: (CGFloat *) pG
        blue: (CGFloat *) pB
{
    CGFloat r = 0, g = 0, b = 0;
	
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

#pragma mark - Component Properties

- (CGFloat) red
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -red");
    CGFloat r = 0.0f;
    
    switch (self.colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
            [self getRed:&r green:NULL blue:NULL alpha:NULL];
            break;
        case kCGColorSpaceModelMonochrome:
            [self getWhite:&r alpha:NULL];
        default:
            break;
    }

    return r;
}

- (CGFloat) green
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -green");
    CGFloat g = 0.0f;
    
    switch (self.colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
            [self getRed:NULL green:&g blue:NULL alpha:NULL];
            break;
        case kCGColorSpaceModelMonochrome:
            [self getWhite:&g alpha:NULL];
        default:
            break;
    }

    return g;
}

- (CGFloat) blue
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -blue");
    CGFloat b = 0.0f;

    switch (self.colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
            [self getRed:NULL green:NULL blue:&b alpha:NULL];
            break;
        case kCGColorSpaceModelMonochrome:
            [self getWhite:&b alpha:NULL];
        default:
            break;
    }

    return b;
}

- (CGFloat) alpha
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -alpha");
    CGFloat a = 0.0f;
    
    switch (self.colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
            [self getRed:NULL green:NULL blue:NULL alpha:&a];
            break;
        case kCGColorSpaceModelMonochrome:
            [self getWhite:NULL alpha:&a];
        default:
            break;
    }
    
    return a;
}

- (CGFloat) white
{
	NSAssert(self.usesMonochromeColorspace, @"Must be a Monochrome color to use -white");
    
    CGFloat w;
    [self getWhite:&w alpha:NULL];
    return w;
}


- (CGFloat) hue
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -hue");
	CGFloat h = 0.0f;
    
    switch (self.colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
            [self getHue: &h saturation:NULL brightness:NULL alpha:NULL];
            break;
        case kCGColorSpaceModelMonochrome:
            [self getWhite:&h alpha:NULL];
        default:
            break;
    }

	return h;
}

- (CGFloat) saturation
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -saturation");
	CGFloat s = 0.0f;
    
    switch (self.colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
            [self getHue:NULL saturation: &s brightness:NULL alpha:NULL];
            break;
        case kCGColorSpaceModelMonochrome:
            [self getWhite:&s alpha:NULL];
        default:
            break;
    }

	return s;
}

- (CGFloat) brightness
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -brightness");
	CGFloat v = 0.0f;
    
    switch (self.colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
            [self getHue:NULL saturation:NULL brightness: &v alpha:NULL];
            break;
        case kCGColorSpaceModelMonochrome:
            [self getWhite:&v alpha:NULL];
        default:
            break;
    }    

	return v;
}


- (CGFloat) luminance
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use -luminance");
    
	CGFloat r, g, b;
	if (![self getRed: &r green: &g blue: &b alpha:NULL])
        return 0.0f;
	
	// http://en.wikipedia.org/wiki/Luma_(video)
	// Y = 0.2126 R + 0.7152 G + 0.0722 B	
	return r * 0.2126f + g * 0.7152f + b * 0.0722f;
}

- (NSArray *) arrayFromRGBAComponents
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -arrayFromRGBAComponents");
    
	CGFloat r, g, b, a;
	if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
	
	return @[@(r), @(g), @(b), @(a)];
}

#pragma mark - Gray Scale representation

- (UIColor *) colorByLuminanceMapping
{
	return [UIColor colorWithWhite:self.luminance alpha:self.alpha];
}

#pragma mark - Alternative Expression

// Grays return 0. Fully saturated return 1
- (CGFloat) colorfulness
{
    CGFloat d1 = fabsf(self.red - self.green);
    CGFloat d2 = fabsf(self.green - self.blue);
    CGFloat d3 = fabsf(self.blue - self.red);
    CGFloat sum = d1 + d2 + d3;
    
    sum /= 2.0f; // Max for fully saturated colors like green, red, cyan, magenta

    return sum;
}

#define WARMTH_OFFSET   (2.0f / 12.0f)

// Ranges from 0..1, cold (BLUE) to hot (YELLOW)
// Obviously, this isn't a standard "heat" map. I picked blue as my coldest
// color and adjusted the warmth value around that. Yellow is 180 degrees off
// from blue. If you want red as hot, use a zero offset but "cold" goes to aqua.
// You can do a lot more math (exercise left for reader) and squeeze
// blue to red and expand orange to whatever that blue color is between
// aqua and blue.
- (CGFloat) warmth
{
    CGFloat adjustment = WARMTH_OFFSET;
    CGFloat hue = self.hue - adjustment;
    if (hue > 0.5f)
        hue -= 1.0f;
    
    CGFloat distance = fabs(hue);
    return (0.5f - distance) * 2.0f;
}

// Return warmer version
- (UIColor *) adjustWarmth: (CGFloat) delta
{
    CGFloat hue = self.hue - WARMTH_OFFSET;
    if (hue < 0) hue += 1;

    if (hue < 0.5f)
        hue += delta;
    else
        hue -= delta;
    
    hue = MAX(0.0, hue);
    if (hue < 0.5f)
        hue = MIN(0.5f, hue);
    else
        hue = MAX(0.5f, hue);
    
    hue += WARMTH_OFFSET;
    if (hue > 1.0f)
        hue -= 1.0f;
    
    return [UIColor colorWithHue:hue saturation:self.saturation brightness:self.brightness alpha:self.alpha];
}

// Return brighter version (if possible)
- (UIColor *) adjustBrightness: (CGFloat) delta
{
    CGFloat b = self.brightness;
    b += delta;
    b = MIN(1.0f, b);
    b = MAX(0.0f, b);
    
    return [UIColor colorWithHue:self.hue saturation:self.saturation brightness:b alpha:self.alpha];
}

// Return more saturated
- (UIColor *) adjustSaturation: (CGFloat) delta
{
    CGFloat s = self.saturation;
    s += delta;
    s = MIN(1.0f, s);
    s = MAX(0.0f, s);
    
    return [UIColor colorWithHue:self.hue saturation:s brightness:self.brightness alpha:self.alpha];
}

- (UIColor *) adjustHue: (CGFloat) delta
{
    CGFloat h = self.hue;
    h += delta;
    if (h < 0.0f)
        h += 1.0f;
    if (h > 1.0f)
        h -= 1.0f;
    
    return [UIColor colorWithHue:h saturation:self.saturation brightness:self.brightness alpha:self.alpha];
}

#pragma mark - Sorting
- (NSComparisonResult) compareWarmth: (UIColor *) anotherColor
{
    return [@(self.warmth) compare:@(anotherColor.warmth)];
}

- (NSComparisonResult) compareColorfulness: (UIColor *) anotherColor
{
    return [@(self.colorfulness) compare:@(anotherColor.colorfulness)];
}

- (NSComparisonResult) compareHue: (UIColor *) anotherColor
{
    return [@(anotherColor.hue) compare:@(self.hue)];
}

- (NSComparisonResult) compareSaturation: (UIColor *) anotherColor
{
    return [@(anotherColor.saturation) compare:@(self.saturation)];
}

- (NSComparisonResult) compareBrightness:(UIColor *)anotherColor
{
    return [@(self.brightness) compare:@(anotherColor.brightness)];
}

#pragma mark - Distance
- (CGFloat) luminanceDistanceFrom: (UIColor *) anotherColor
{
    CGFloat base = self.luminance - anotherColor.luminance;
    return sqrtf(base * base);
}

- (CGFloat) hueDistanceFrom: (UIColor *) anotherColor
{
    CGFloat dH = self.hue - anotherColor.hue;
    
    return fabsf(dH);
}

- (CGFloat) hsDistanceFrom: (UIColor *) anotherColor
{
    CGFloat dH = self.hue - anotherColor.hue;
    CGFloat dS = self.saturation - anotherColor.saturation;
    
    return sqrtf(dH * dH + dS * dS);
}

- (CGFloat) distanceFrom: (UIColor *) anotherColor
{
    CGFloat dR = self.red - anotherColor.red;
    CGFloat dG = self.green - anotherColor.green;
    CGFloat dB = self.blue - anotherColor.blue;
    
    return sqrtf(dR * dR + dG * dG + dB * dB);
}

- (BOOL) isEqualToColor: (UIColor *) anotherColor
{
    CGFloat distance = [self distanceFrom:anotherColor];
    return (distance < FLT_EPSILON);
}

#pragma mark Arithmetic operations


- (UIColor *) colorByMultiplyingByRed: (CGFloat) red
                                green: (CGFloat) green
                                 blue: (CGFloat) blue
                                alpha: (CGFloat) alpha
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
	CGFloat r, g, b, a;
	if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
    
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
	if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
	
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
	if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
    
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
	if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
	
	return [UIColor colorWithRed:MIN(r, red)
						   green:MIN(g, green)
							blue:MIN(b, blue)
						   alpha:MIN(a, alpha)];
}

- (UIColor *) colorByMultiplyingBy: (CGFloat) f
{
    // Multiply by 1 alpha
	return [self colorByMultiplyingByRed:f green:f blue:f alpha:1.0f];
}

- (UIColor *) colorByAdding: (CGFloat) f
{
    // Add 0 alpha
	return [self colorByMultiplyingByRed:f green:f blue:f alpha:0.0f];
}

- (UIColor *) colorByLighteningTo: (CGFloat) f
{
    // Alpha is ignored
	return [self colorByLighteningToRed:f green:f blue:f alpha:0.0f];
}

- (UIColor *) colorByDarkeningTo: (CGFloat) f
{
    // Alpha is ignored
	return [self colorByDarkeningToRed:f green:f blue:f alpha:0.0f];
}

- (UIColor *) colorByMultiplyingByColor: (UIColor *) color
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
	
	CGFloat r, g, b, a;
	if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
	
	return [self colorByMultiplyingByRed:r green:g blue:b alpha:1.0f];
}

- (UIColor *) colorByAddingColor: (UIColor *) color
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
	
	CGFloat r, g, b, a;
	if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
	
	return [self colorByAddingRed:r green:g blue:b alpha:0.0f];
}

- (UIColor *) colorByLighteningToColor: (UIColor *) color
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
	
	CGFloat r, g, b, a;
	if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
    
	return [self colorByLighteningToRed:r green:g blue:b alpha:0.0f];
}

- (UIColor *) colorByDarkeningToColor: (UIColor *) color
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
	
	CGFloat r, g, b, a;
	if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
	
	return [self colorByDarkeningToRed:r green:g blue:b alpha:1.0f];
}

// Andrew Wooster https://github.com/wooster
- (UIColor *)colorByInterpolatingToColor:(UIColor *)color byFraction:(CGFloat)fraction
{
	NSAssert(self.canProvideRGBComponents, @"Self must be a RGB color to use arithmatic operations");
	NSAssert(color.canProvideRGBComponents, @"Color must be a RGB color to use arithmatic operations");
    
	CGFloat r, g, b, a;
	if (![self getRed:&r green:&g blue:&b alpha:&a]) return nil;
    
	CGFloat r2,g2,b2,a2;
	if (![color getRed:&r2 green:&g2 blue:&b2 alpha:&a2]) return nil;
    
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
    CGFloat h = self.hue * 360.0f;
    CGFloat s = self.saturation;
    CGFloat v = self.brightness;
    CGFloat a = self.alpha;
    
	// Pick color 180 degrees away
	h += 180.0f;
	if (h > 360.f) h -= 360.0f;
    h /= 360.0f;
	
	// Create a color in RGB
    if (a == 0.0f)
        a = 1.0f;
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
	CGFloat h = self.hue * 360.0f;
    CGFloat s = self.saturation;
    CGFloat v = self.brightness;
	
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:pairs * 2];
	
	if (stepAngle < 0.0f)
		stepAngle *= -1.0f;
	
	for (int i = 1; i <= pairs; ++i)
    {
		CGFloat a = fmodf(stepAngle * i, 360.0f);
		
		CGFloat h1 = fmodf(h + a, 360.0f);
		CGFloat h2 = fmodf(h + 360.0f - a, 360.0f);
		
		[colors addObject:[UIColor colorWithHue:h1 / 360.0f saturation:s brightness:v alpha:a]];
		[colors addObject:[UIColor colorWithHue:h2 / 360.0f saturation:s brightness:v alpha:a]];
	}
	
	return [colors copy];
}

//  - Eridius - UIColor needs a method that takes 2 colors and gives a third complementary one
- (UIColor *)kevinColorWithColor:(UIColor *)secondColor
{
    CGFloat startingHue = MIN(self.hue, secondColor.hue);
    CGFloat distance = fabs(self.hue - secondColor.hue);
    if (distance > 0.5)
    {
        distance = 1 - distance;
        startingHue = MAX(self.hue, secondColor.hue);
    }
    
    CGFloat target = startingHue + distance / 2;
    if (distance < 0.5)
        target += 0.5;
    
    while (target > 1)
        target -= 1;
    
    CGFloat sat = (self.saturation + secondColor.saturation) / 2;
    CGFloat bri = (self.brightness + secondColor.brightness) / 2;
    CGFloat alpha = (self.alpha + secondColor.alpha) / 2.0f;
    if (alpha < 0.005f)
        alpha = 1.0f;
    
    return [UIColor colorWithHue:target saturation:sat brightness:bri alpha:alpha];
}

#pragma mark - Perceived Color
#define  Pr  .299
#define  Pg  .587
#define  Pb  .114

//  public domain function by Darel Rex Finley, 2006
//
//  This function expects the passed-in values to be on a scale
//  of 0 to 1, and uses that same scale for the return values.
//
//  See description/examples at alienryderflex.com/hsp.html

void RGBtoHSP(
              CGFloat  R, CGFloat  G, CGFloat  B,
              CGFloat *H, CGFloat *S, CGFloat *P)
{
    
    //  Calculate the Perceived brightness.
    *P=sqrt(R*R*Pr+G*G*Pg+B*B*Pb);
    
    //  Calculate the Hue and Saturation.  (This part works
    //  the same way as in the HSV/B and HSL systems???.)
    if      (R==G && R==B) {
        *H=0.; *S=0.; return; }
    if      (R>=G && R>=B) {   //  R is largest
        if    (B>=G) {
            *H=6./6.-1./6.*(B-G)/(R-G); *S=1.-G/R; }
        else         {
            *H=0./6.+1./6.*(G-B)/(R-B); *S=1.-B/R; }}
    else if (G>=R && G>=B) {   //  G is largest
        if    (R>=B) {
            *H=2./6.-1./6.*(R-B)/(G-B); *S=1.-B/G; }
        else         {
            *H=2./6.+1./6.*(B-R)/(G-R); *S=1.-R/G; }}
    else                   {   //  B is largest
        if    (G>=R) {
            *H=4./6.-1./6.*(G-R)/(B-R); *S=1.-R/B; }
        else         {
            *H=4./6.+1./6.*(R-G)/(B-G); *S=1.-G/B; }}}



//  public domain function by Darel Rex Finley, 2006
//  see: http://alienryderflex.com/hsp.html
//
//  CGFloated by me. All errors are mine, all good stuff his
//
//  This function expects the passed-in values to be on a scale
//  of 0 to 1, and uses that same scale for the return values.
//
//  Note that some combinations of HSP, even if in the scale
//  0-1, may return RGB values that exceed a value of 1.  For
//  example, if you pass in the HSP color 0,1,1, the result
//  will be the RGB color 2.037,0,0.
//
//  See description/examples at alienryderflex.com/hsp.html

void HSPtoRGB(
              CGFloat  H, CGFloat  S, CGFloat  P,
              CGFloat *R, CGFloat *G, CGFloat *B) {
    
    CGFloat  part, minOverMax=1.-S ;
    
    if (minOverMax>0.) {
        if      ( H<1./6.) {   //  R>G>B
            H= 6.*( H-0./6.); part=1.+H*(1./minOverMax-1.);
            *B=P/sqrt(Pr/minOverMax/minOverMax+Pg*part*part+Pb);
            *R=(*B)/minOverMax; *G=(*B)+H*((*R)-(*B)); }
        else if ( H<2./6.) {   //  G>R>B
            H= 6.*(-H+2./6.); part=1.+H*(1./minOverMax-1.);
            *B=P/sqrt(Pg/minOverMax/minOverMax+Pr*part*part+Pb);
            *G=(*B)/minOverMax; *R=(*B)+H*((*G)-(*B)); }
        else if ( H<3./6.) {   //  G>B>R
            H= 6.*( H-2./6.); part=1.+H*(1./minOverMax-1.);
            *R=P/sqrt(Pg/minOverMax/minOverMax+Pb*part*part+Pr);
            *G=(*R)/minOverMax; *B=(*R)+H*((*G)-(*R)); }
        else if ( H<4./6.) {   //  B>G>R
            H= 6.*(-H+4./6.); part=1.+H*(1./minOverMax-1.);
            *R=P/sqrt(Pb/minOverMax/minOverMax+Pg*part*part+Pr);
            *B=(*R)/minOverMax; *G=(*R)+H*((*B)-(*R)); }
        else if ( H<5./6.) {   //  B>R>G
            H= 6.*( H-4./6.); part=1.+H*(1./minOverMax-1.);
            *G=P/sqrt(Pb/minOverMax/minOverMax+Pr*part*part+Pg);
            *B=(*G)/minOverMax; *R=(*G)+H*((*B)-(*G)); }
        else               {   //  R>B>G
            H= 6.*(-H+6./6.); part=1.+H*(1./minOverMax-1.);
            *G=P/sqrt(Pr/minOverMax/minOverMax+Pb*part*part+Pg);
            *R=(*G)/minOverMax; *B=(*G)+H*((*R)-(*G)); }}
    else {
        if      ( H<1./6.) {   //  R>G>B
            H= 6.*( H-0./6.); *R=sqrt(P*P/(Pr+Pg*H*H)); *G=(*R)*H; *B=0.; }
        else if ( H<2./6.) {   //  G>R>B
            H= 6.*(-H+2./6.); *G=sqrt(P*P/(Pg+Pr*H*H)); *R=(*G)*H; *B=0.; }
        else if ( H<3./6.) {   //  G>B>R
            H= 6.*( H-2./6.); *G=sqrt(P*P/(Pg+Pb*H*H)); *B=(*G)*H; *R=0.; }
        else if ( H<4./6.) {   //  B>G>R
            H= 6.*(-H+4./6.); *B=sqrt(P*P/(Pb+Pg*H*H)); *G=(*B)*H; *R=0.; }
        else if ( H<5./6.) {   //  B>R>G
            H= 6.*( H-4./6.); *B=sqrt(P*P/(Pb+Pr*H*H)); *R=(*B)*H; *G=0.; }
        else               {   //  R>B>G
            H= 6.*(-H+6./6.); *R=sqrt(P*P/(Pr+Pb*H*H)); *B=(*R)*H; *G=0.; }}}

// For Ahti333
- (CGFloat) perceivedBrightness
{
    CGFloat p;
    CGFloat r = self.red;
    CGFloat g = self.green;
    CGFloat b = self.blue;
    RGBtoHSP(r, g, b, NULL, NULL, &p);

    return p;
}

#pragma mark - String Support
- (UInt32)rgbHex
{
	NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use -rgbHex");
	
	CGFloat r, g, b, a;
	if (![self getRed: &r green: &g blue: &b alpha: &a])
        return 0.0f;
	
	r = MIN(MAX(r, 0.0f), 1.0f);
	g = MIN(MAX(g, 0.0f), 1.0f);
	b = MIN(MAX(b, 0.0f), 1.0f);
	
	return (((int)roundf(r * 255)) << 16) | (((int)roundf(g * 255)) << 8) | (((int)roundf(b * 255)));
}

- (NSString *) stringValue
{
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -stringValue");
    NSString *result;
    switch (self.colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
            result = [NSString stringWithFormat:@"{%0.4f, %0.4f, %0.4f, %0.4f}",
                      self.red, self.green, self.blue, self.alpha];
            break;
        case kCGColorSpaceModelMonochrome:
            result = [NSString stringWithFormat:@"{%0.4f, %0.4f}",
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

// Return UIColor from Kelvin
// Via http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/

+ (UIColor *) colorWithKelvin:(CGFloat)kelvin
{
    if ((kelvin < 1000) || (kelvin > 40000))
        NSLog(@"Warning: temperature should range between 1000 and 40000");
    
    CGFloat temperature = kelvin / 100;
    
    CGFloat red, green, blue;

    if (temperature <= 66)
    {
        red = 255;
        green = temperature;
        green = 99.4708025861 * log(green) - 161.1195681661;
    }
    else
    {
        red = temperature - 60;
        red = 329.698727446 * pow(red, -0.1332047592);
        green = temperature - 60;
        green = 288.1221695283 * pow(green, -0.0755148492);
    }
    
    if (temperature >= 66)
        blue = 255;
    else if (temperature <= 19)
        blue = 0;
    else
    {
        blue = temperature - 10;
        blue = 138.5177312231 * log(blue) - 305.0447927307;
    }
    
    
    red = MAX(red, 0);
    red = MIN(red, 255);
    green = MAX(green, 0);
    green = MIN(green, 255);
    blue = MAX(blue, 0);
    blue = MIN(blue, 255);
    
    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:1.0f];
}

/*
 Photographers and lighting designers speak of color temperatures in "degrees kelvin." For example, 3200K represents a typical indoor color temperature and 5500K represents typical daylight color temperature. In the context of lighting, a specific kelvin temperature expresses the color temperature (dull red, bright red, white, blue) corresponding to the physical temperature (warm, hot, extremely hot) of an object.
 
 Complete adaptation seems to be confined to the range 5000  K to 5500  K. For most people, D65 has a little hint of blue. Tungsten illumination, at about 3200  K, always appears somewhat yellow.
 */

NSDictionary *kelvin = nil;
+ (NSDictionary *) kelvinDictionary
{
    if (kelvin)
        return kelvin;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (int i = 1000; i <= 40000; i += 100)
    {
        UIColor *color = [UIColor colorWithKelvin:i];
        NSString *hex = color.hexStringValue;
        if (!dict[hex])
            dict[hex] = @(i);
    }
    
    kelvin = [dict copy];
    
    return kelvin;
}

- (CGFloat) colorTemperature
{
    CGFloat bestDistance = MAXFLOAT;
    NSString *bestMatch = nil;
    
    NSDictionary *kelvinDictionary = [UIColor kelvinDictionary];
    for (NSString *hexKey in kelvinDictionary.allKeys)
    {
        UIColor *color = [UIColor colorWithHexString:hexKey];
        CGFloat distance = [self distanceFrom:color];
        
        if (distance < bestDistance)
        {
            bestDistance = distance;
            bestMatch = hexKey;
        }
    }
    
    NSNumber *temp = kelvinDictionary[bestMatch];
    return temp.floatValue;
}

// Returns a UIColor by scanning the string for a hex number and passing that to +[UIColor colorWithRGBHex:]
// Skips any leading whitespace and ignores any trailing characters
// Added "#" consumer -- via Arnaud Coomans
+ (UIColor *) colorWithHexString: (NSString *)stringToConvert
{
    NSString *string = stringToConvert;
    if ([string hasPrefix:@"#"])
        string = [string substringFromIndex:1];
    
	NSScanner *scanner = [NSScanner scannerWithString:string];
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
  
    /*
     Popular crayon colors
     */
    NSDictionary *crayonDictionary = @{@"Carnation Pink":@"FFA6C9", @"Almond":@"EED9C4", @"Burnt Orange":@"FF7034", @"Wisteria":@"C9A0DC", @"Sepia":@"9E5B40", @"Vivid Tangerine":@"FF9980", @"Neon Carrot":@"FF9933", @"Electric Lime":@"CCFF00", @"Sunset Orange":@"FE4C40", @"Jungle Green":@"29AB87", @"Robin's Egg Blue":@"00CCCC", @"Banana Mania":@"FBE7B2", @"Fuchsia":@"C154C1", @"Mango Tango":@"E77200", @"Cranberry":@"DB5079", @"Blue":@"0066FF", @"Raw Sienna":@"D27D46", @"Tickle Me Pink":@"FC80A5", @"Gray":@"8B8680", @"Mountain Meadow":@"1AB385", @"Hot Magenta":@"FF00CC", @"Black":@"000000", @"Pink Flamingo":@"FF66FF", @"Screamin' Green":@"66FF66", @"Mauvelous":@"F091A9", @"Orange":@"FF681F", @"Orchid":@"E29CD2", @"Aquamarine":@"71D9E2", @"Goldenrod":@"FCD667", @"Brick Red":@"C62D42", @"Apricot":@"FDD5B1", @"Razzmatazz":@"E30B5C", @"Mahogany":@"CA3435", @"Flesh":@"FFCBA4", @"Wild Strawberry":@"FF3399", @"Desert Sand":@"EDC9AF", @"Burnt Sienna":@"E97451", @"Midnight Blue":@"003366", @"Shocking Pink":@"FF6FFF", @"Laser Lemon":@"FFFF66", @"White":@"FFFFFF", @"Inch Worm":@"B0E313", @"Pig Pink":@"FDD7E4", @"Vivid Violet":@"803790", @"Antique Brass":@"C88A65", @"Bittersweet":@"FE6F5E", @"Violet (Purple)":@"8359A3", @"Magenta":@"F653A6", @"Eggplant":@"614051", @"Atomic Tangerine":@"FF9966", @"Lavender":@"FBAED2", @"Razzle Dazzle Rose":@"FF33CC", @"Blizzard Blue":@"A3E3ED", @"Salmon":@"FF91A4", @"Granny Smith Apple":@"9DE093", @"Silver":@"C9C0BB", @"Denim":@"1560BD", @"Jazzberry Jam":@"A50B5E", @"Outer Space":@"2D383A", @"Macaroni And Cheese":@"FFB97B", @"Copper":@"DA8A67", @"Tropical Rain Forest":@"00755E", @"Violet Red":@"F7468A", @"Fern":@"63B76C", @"Gold":@"E6BE8A", @"Pacific Blue":@"009DC4", @"Sunglow":@"FFCC33", @"Tumbleweed":@"DEA681", @"Cerise":@"DA3287", @"Chestnut":@"B94E48", @"Forest Green":@"5FA777", @"Indigo":@"4F69C6", @"Ultra Red":@"FD5B78", @"Timberwolf":@"D9D6CF", @"Navy Blue":@"0066CC", @"Royal Purple":@"6B3FA0", @"Yellow Orange":@"FFAE42", @"Beaver":@"926F5B", @"Wild Blue Yonder":@"7A89B8", @"Blue Green":@"0095B6", @"Cotton Candy":@"FFB7D5", @"Dandelion":@"FED85D", @"Green":@"01A368", @"Plum":@"843179", @"Sea Green":@"93DFB8", @"Yellow Green":@"C5E17A", @"Blue Bell":@"9999CC", @"Olive Green":@"B5B35C", @"Canary":@"FFFF99", @"Yellow":@"FBE870", @"Magic Mint":@"AAF0D1", @"Red":@"ED0A3F", @"Cerulean":@"02A4D3", @"Red Violet":@"BB3385", @"Sky Blue":@"76D7EA", @"Brink Pink":@"FB607F", @"Outrageous Orange":@"FF6037", @"Cornflower":@"93CCEA", @"Mulberry":@"C54B8C", @"Purple Mountain's Majesty":@"9678B6", @"Red Orange":@"FF3F34", @"Fuzzy Wuzzy Brown":@"C45655", @"Periwinkle":@"C3CDE6", @"Happy Ever After":@"6CDA37", @"Radical Red":@"FF355E", @"Maroon":@"C32148", @"Spring Green":@"ECEBBD", @"Turquoise Blue":@"6CDAE7", @"Purple Heart":@"652DC1", @"Shamrock":@"33CC99", @"Brown":@"AF593E", @"Blue Violet":@"6456B7", @"Scarlet":@"FD0E35", @"Green Yellow":@"F1E788", @"Melon":@"FEBAAD", @"Manatee":@"8D90A1", @"Tan":@"FA9D5A", @"Asparagus":@"7BA05B", @"Pine Green":@"01796F", @"Caribbean Green":@"00CC99", @"Cadet Blue":@"A9B2C3", @"Shadow":@"837050"};
    
    /*
     Database of color names and hex rgb values, derived
     from the css 3 color spec:
     http://www.w3.org/TR/css3-color/
     */
    NSDictionary *cssDictionary = @{@"lightseagreen":@"20b2aa", @"floralwhite":@"fffaf0", @"lightgray":@"d3d3d3", @"darkgoldenrod":@"b8860b", @"paleturquoise":@"afeeee", @"goldenrod":@"daa520", @"skyblue":@"87ceeb", @"indianred":@"cd5c5c", @"darkgray":@"a9a9a9", @"khaki":@"f0e68c", @"blue":@"0000ff", @"darkred":@"8b0000", @"lightyellow":@"ffffe0", @"midnightblue":@"191970", @"chartreuse":@"7fff00", @"lightsteelblue":@"b0c4de", @"slateblue":@"6a5acd", @"firebrick":@"b22222", @"moccasin":@"ffe4b5", @"salmon":@"fa8072", @"sienna":@"a0522d", @"slategray":@"708090", @"teal":@"008080", @"lightsalmon":@"ffa07a", @"pink":@"ffc0cb", @"burlywood":@"deb887", @"gold":@"ffd700", @"springgreen":@"00ff7f", @"lightcoral":@"f08080", @"black":@"000000", @"blueviolet":@"8a2be2", @"chocolate":@"d2691e", @"aqua":@"00ffff", @"darkviolet":@"9400d3", @"indigo":@"4b0082", @"darkcyan":@"008b8b", @"orange":@"ffa500", @"antiquewhite":@"faebd7", @"peru":@"cd853f", @"silver":@"c0c0c0", @"purple":@"800080", @"saddlebrown":@"8b4513", @"lawngreen":@"7cfc00", @"dodgerblue":@"1e90ff", @"lime":@"00ff00", @"linen":@"faf0e6", @"lightblue":@"add8e6", @"darkslategray":@"2f4f4f", @"lightskyblue":@"87cefa", @"mintcream":@"f5fffa", @"olive":@"808000", @"hotpink":@"ff69b4", @"papayawhip":@"ffefd5", @"mediumseagreen":@"3cb371", @"mediumspringgreen":@"00fa9a", @"cornflowerblue":@"6495ed", @"plum":@"dda0dd", @"seagreen":@"2e8b57", @"palevioletred":@"db7093", @"bisque":@"ffe4c4", @"beige":@"f5f5dc", @"darkorchid":@"9932cc", @"royalblue":@"4169e1", @"darkolivegreen":@"556b2f", @"darkmagenta":@"8b008b", @"orange red":@"ff4500", @"lavender":@"e6e6fa", @"fuchsia":@"ff00ff", @"darkseagreen":@"8fbc8f", @"lavenderblush":@"fff0f5", @"wheat":@"f5deb3", @"steelblue":@"4682b4", @"lightgoldenrodyellow":@"fafad2", @"lightcyan":@"e0ffff", @"mediumaquamarine":@"66cdaa", @"turquoise":@"40e0d0", @"dark blue":@"00008b", @"darkorange":@"ff8c00", @"brown":@"a52a2a", @"dimgray":@"696969", @"deeppink":@"ff1493", @"powderblue":@"b0e0e6", @"red":@"ff0000", @"darkgreen":@"006400", @"ghostwhite":@"f8f8ff", @"white":@"ffffff", @"navajowhite":@"ffdead", @"navy":@"000080", @"ivory":@"fffff0", @"palegreen":@"98fb98", @"whitesmoke":@"f5f5f5", @"gainsboro":@"dcdcdc", @"mediumslateblue":@"7b68ee", @"olivedrab":@"6b8e23", @"mediumpurple":@"9370db", @"darkslateblue":@"483d8b", @"blanchedalmond":@"ffebcd", @"darkkhaki":@"bdb76b", @"green":@"008000", @"limegreen":@"32cd32", @"snow":@"fffafa", @"tomato":@"ff6347", @"darkturquoise":@"00ced1", @"orchid":@"da70d6", @"yellow":@"ffff00", @"green yellow":@"adff2f", @"azure":@"f0ffff", @"mistyrose":@"ffe4e1", @"cadetblue":@"5f9ea0", @"oldlace":@"fdf5e6", @"gray":@"808080", @"honeydew":@"f0fff0", @"peachpuff":@"ffdab9", @"tan":@"d2b48c", @"thistle":@"d8bfd8", @"palegoldenrod":@"eee8aa", @"mediumorchid":@"ba55d3", @"rosybrown":@"bc8f8f", @"mediumturquoise":@"48d1cc", @"lemonchiffon":@"fffacd", @"maroon":@"800000", @"mediumvioletred":@"c71585", @"violet":@"ee82ee", @"yellow green":@"9acd32", @"coral":@"ff7f50", @"lightgreen":@"90ee90", @"cornsilk":@"fff8dc", @"mediumblue":@"0000cd", @"aliceblue":@"f0f8ff", @"forestgreen":@"228b22", @"aquamarine":@"7fffd4", @"deepskyblue":@"00bfff", @"lightslategray":@"778899", @"darksalmon":@"e9967a", @"crimson":@"dc143c", @"sandybrown":@"f4a460", @"lightpink":@"ffb6c1", @"seashell":@"fff5ee"};
    
    /*
     Similar to CSS but more readable
     */
    NSDictionary *baseDictionary = @{@"Dodger Blue":@"1E90FF", @"Plum":@"DDA0DD", @"Maroon (X11)":@"B03060", @"Ghost White":@"F8F8FF", @"Moccasin":@"FFE4B5", @"Dark Khaki":@"BDB76B", @"Light Steel Blue":@"B0C4DE", @"Spring Green":@"00FF7F", @"Deep Sky Blue":@"00BFFF", @"Floral White":@"FFFAF0", @"Blue":@"0000FF", @"Dark Slate Blue":@"483D8B", @"Pale Violet Red":@"DB7093", @"Seashell":@"FFF5EE", @"Midnight Blue":@"191970", @"Indian Red":@"CD5C5C", @"Light Goldenrod":@"FAFAD2", @"Slate Gray":@"708090", @"Light Yellow":@"FFFFE0", @"Teal":@"008080", @"Sky Blue":@"87CEEB", @"Medium Aquamarine":@"66CDAA", @"Yellow Green":@"9ACD32", @"Coral":@"FF7F50", @"Dark Goldenrod":@"B8860B", @"Black":@"000000", @"Khaki":@"F0E68C", @"Linen":@"FAF0E6", @"Medium Orchid":@"BA55D3", @"Light Blue":@"ADD8E6", @"Medium Spring Green":@"00FA9A", @"Green Yellow":@"ADFF2F", @"Gray (X11)":@"BEBEBE", @"Deep Pink":@"FF1493", @"Medium Turquoise":@"48D1CC", @"Purple (W3C)":@"7F007F", @"Pale Green":@"98FB98", @"Pink":@"FFC0CB", @"Powder Blue":@"B0E0E6", @"Salmon":@"FA8072", @"Dark Blue":@"00008B", @"Dark Red":@"8B0000", @"Hot Pink":@"FF69B4", @"Sienna":@"A0522D", @"Turquoise":@"40E0D0", @"Bisque":@"FFE4C4", @"Peach Puff":@"FFDAB9", @"Aqua":@"00FFFF", @"Azure":@"F0FFFF", @"Beige":@"F5F5DC", @"Olive":@"808000", @"Chocolate":@"D2691E", @"Sandy Brown":@"F4A460", @"Dark Magenta":@"8B008B", @"Tomato":@"FF6347", @"Dark Orange":@"FF8C00", @"White":@"FFFFFF", @"Cornflower":@"6495ED", @"Cadet Blue":@"5F9EA0", @"Gainsboro":@"DCDCDC", @"Dark Orchid":@"9932CC", @"Dark Slate Gray":@"2F4F4F", @"Mint Cream":@"F5FFFA", @"Chartreuse":@"7FFF00", @"Green (X11)":@"00FF00", @"Light Sky Blue":@"87CEFA", @"Snow":@"FFFAFA", @"Slate Blue":@"6A5ACD", @"Saddle Brown":@"8B4513", @"Dark Violet":@"9400D3", @"Light Salmon":@"FFA07A", @"Violet":@"EE82EE", @"Yellow":@"FFFF00", @"Light Green":@"90EE90", @"Dark Sea Green":@"8FBC8F", @"Medium Sea Green":@"3CB371", @"Aquamarine":@"7FFFD4", @"Olive Drab":@"6B8E23", @"Peru":@"CD853F", @"Firebrick":@"B22222", @"Dim Gray":@"696969", @"Lemon Chiffon":@"FFFACD", @"Forest Green":@"228B22", @"Dark Cyan":@"008B8B", @"Dark Green":@"006400", @"Orange Red":@"FF4500", @"Fuchsia":@"FF00FF", @"Light Cyan":@"E0FFFF", @"Dark Salmon":@"E9967A", @"Honeydew":@"F0FFF0", @"Lawn Green":@"7CFC00", @"Dark Turquoise":@"00CED1", @"Goldenrod":@"DAA520", @"Light Coral":@"F08080", @"Misty Rose":@"FFE4E1", @"Navy":@"000080", @"Old Lace":@"FDF5E6", @"Orchid":@"DA70D6", @"Medium Purple":@"9370DB", @"Maroon (W3C)":@"7F0000", @"Thistle":@"D8BFD8", @"Ivory":@"FFFFF0", @"Green (W3C)":@"008000", @"Light Gray":@"D3D3D3", @"Royal Blue":@"4169E1", @"Purple (X11)":@"A020F0", @"Red":@"FF0000", @"Dark Gray":@"A9A9A9", @"Gray (W3C)":@"808080", @"Sea Green":@"2E8B57", @"Pale Turquoise":@"AFEEEE", @"Antique White":@"FAEBD7", @"Burlywood":@"DEB887", @"Gold":@"FFD700", @"Medium Violet Red":@"C71585", @"Alice Blue":@"F0F8FF", @"Crimson":@"DC143C", @"Lime Green":@"32CD32", @"Orange":@"FFA500", @"Steel Blue":@"4682B4", @"Dark Olive Green":@"556B2F", @"Blue Violet":@"8A2BE2", @"Rosy Brown":@"BC8F8F", @"White Smoke":@"F5F5F5", @"Light Pink":@"FFB6C1", @"Medium Slate Blue":@"7B68EE", @"Tan":@"D2B48C", @"Wheat":@"F5DEB3", @"Lavender":@"E6E6FA", @"Lavender Blush":@"FFF0F5", @"Pale Goldenrod":@"EEE8AA", @"Medium Blue":@"0000CD", @"Navajo White":@"FFDEAD", @"Indigo":@"4B0082", @"Brown":@"A52A2A", @"Papaya Whip":@"FFEFD5", @"Silver (W3C)":@"C0C0C0", @"Light Slate Gray":@"778899", @"Light Sea Green":@"20B2AA", @"Blanched Almond":@"FFEBCD", @"Cornsilk":@"FFF8DC"};
    
    NSDictionary *systemColorDictionary = @{@"Black":@"000000", @"Dark Gray":@"555555", @"Light Gray":@"AAAAAA", @"White":@"FFFFFF", @"Gray":@"7F7F7F", @"Red":@"FF0000", @"Green":@"00FF00", @"Blue":@"0000FF", @"Cyan":@"00FFFF", @"Yellow":@"FFFF00", @"Magenta":@"FF00FF", @"Orange":@"FF7F00", @"Purple":@"7F007F", @"Brown":@"996633"};
    
    // See: http://en.wikipedia.org/wiki/List_of_colors:_A-M
    // and: http://en.wikipedia.org/wiki/List_of_colors:_N-Z
    NSDictionary *wikipediaColorDictionary = @{@"Aero" : @"7CB9E8", @"Aero blue" : @"C9FFE5", @"African violet" : @"B284BE", @"Air Force blue (RAF)" : @"5D8AA8", @"Air Force blue (USAF)" : @"00308F", @"Air superiority blue" : @"72A0C1", @"Alabama Crimson" : @"A32638", @"Alice blue" : @"F0F8FF", @"Alizarin crimson" : @"E32636", @"Alloy orange" : @"C46210", @"Almond" : @"EFDECD", @"Amaranth" : @"E52B50", @"Amazon" : @"3B7A57", @"Amber" : @"FFBF00", @"SAE/ECE Amber (color)" : @"FF7E00", @"American rose" : @"FF033E", @"Amethyst" : @"9966CC", @"Android green" : @"A4C639", @"Anti-flash white" : @"F2F3F4", @"Antique brass" : @"CD9575", @"Antique bronze" : @"665D1E", @"Antique fuchsia" : @"915C83", @"Antique ruby" : @"841B2D", @"Antique white" : @"FAEBD7", @"Ao (English)" : @"008000", @"Apple green" : @"8DB600", @"Apricot" : @"FBCEB1", @"Aqua" : @"00FFFF", @"Aquamarine" : @"7FFFD4", @"Army green" : @"4B5320", @"Arsenic" : @"3B444B", @"Arylide yellow" : @"E9D66B", @"Ash gray" : @"B2BEB5", @"Asparagus" : @"87A96B", @"Atomic tangerine" : @"FF9966", @"Auburn" : @"A52A2A", @"Aureolin" : @"FDEE00", @"AuroMetalSaurus" : @"6E7F80", @"Avocado" : @"568203", @"Azure" : @"007FFF", @"Azure mist/web" : @"F0FFFF", @"Baby blue" : @"89CFF0", @"Baby blue eyes" : @"A1CAF1", @"Baby pink" : @"F4C2C2", @"Baby powder" : @"FEFEFA", @"Baker-Miller pink" : @"FF91AF", @"Ball blue" : @"21ABCD", @"Banana Mania" : @"FAE7B5", @"Banana yellow" : @"FFE135", @"Barbie pink" : @"E0218A", @"Barn red" : @"7C0A02", @"Battleship gray" : @"848482", @"Bazaar" : @"98777B", @"Beau blue" : @"BCD4E6", @"Beaver" : @"9F8170", @"Beige" : @"F5F5DC", @"B'dazzled Blue" : @"2E5894", @"Big dip o’ruby" : @"9C2542", @"Bisque" : @"FFE4C4", @"Bistre" : @"3D2B1F", @"Bistre brown" : @"967117", @"Bitter lemon" : @"CAE00D", @"Bitter lime" : @"BFFF00", @"Bittersweet" : @"FE6F5E", @"Bittersweet shimmer" : @"BF4F51", @"Black" : @"000000", @"Black bean" : @"3D0C02", @"Black leather jacket" : @"253529", @"Black olive" : @"3B3C36", @"Blanched almond" : @"FFEBCD", @"Blast-off bronze" : @"A57164", @"Bleu de France" : @"318CE7", @"Blizzard Blue" : @"ACE5EE", @"Blond" : @"FAF0BE", @"Blue" : @"0000FF", @"Blue (Crayola)" : @"1F75FE", @"Blue (Munsell)" : @"0093AF", @"Blue (NCS)" : @"0087BD", @"Blue (pigment)" : @"333399", @"Blue (RYB)" : @"0247FE", @"Blue Bell" : @"A2A2D0", @"Blue-gray" : @"6699CC", @"Blue-green" : @"0D98BA", @"Blue sapphire" : @"126180", @"Blue-violet" : @"8A2BE2", @"Blueberry" : @"4F86F7", @"Bluebonnet" : @"1C1CF0", @"Blush" : @"DE5D83", @"Bole" : @"79443B", @"Bondi blue" : @"0095B6", @"Bone" : @"E3DAC9", @"Boston University Red" : @"CC0000", @"Bottle green" : @"006A4E", @"Boysenberry" : @"873260", @"Brandeis blue" : @"0070FF", @"Brass" : @"B5A642", @"Brick red" : @"CB4154", @"Bright cerulean" : @"1DACD6", @"Bright green" : @"66FF00", @"Bright lavender" : @"BF94E4", @"Bright maroon" : @"C32148", @"Bright pink" : @"FF007F", @"Bright turquoise" : @"08E8DE", @"Bright ube" : @"D19FE8", @"Brilliant lavender" : @"F4BBFF", @"Brilliant rose" : @"FF55A3", @"Brink pink" : @"FB607F", @"British racing green" : @"004225", @"Bronze" : @"CD7F32", @"Bronze Yellow" : @"737000", @"Brown (traditional)" : @"964B00", @"Brown (web)" : @"A52A2A", @"Brown-nose" : @"6B4423", @"Brunswick green" : @"1B4D3E", @"Bubble gum" : @"FFC1CC", @"Bubbles" : @"E7FEFF", @"Buff" : @"F0DC82", @"Bulgarian rose" : @"480607", @"Burgundy" : @"800020", @"Burlywood" : @"DEB887", @"Burnt orange" : @"CC5500", @"Burnt sienna" : @"E97451", @"Burnt umber" : @"8A3324", @"Byzantine" : @"BD33A4", @"Byzantium" : @"702963", @"Cadet" : @"536872", @"Cadet blue" : @"5F9EA0", @"Cadet gray" : @"91A3B0", @"Cadmium green" : @"006B3C", @"Cadmium orange" : @"ED872D", @"Cadmium red" : @"E30022", @"Cadmium yellow" : @"FFF600", @"Café au lait" : @"A67B5B", @"Café noir" : @"4B3621", @"Cal Poly green" : @"1E4D2B", @"Cambridge Blue" : @"A3C1AD", @"Camel" : @"C19A6B", @"Cameo pink" : @"EFBBCC", @"Camouflage green" : @"78866B", @"Canary yellow" : @"FFEF00", @"Candy apple red" : @"FF0800", @"Candy pink" : @"E4717A", @"Capri" : @"00BFFF", @"Caput mortuum" : @"592720", @"Cardinal" : @"C41E3A", @"Caribbean green" : @"00CC99", @"Carmine" : @"960018", @"Carmine (M&P)" : @"D70040", @"Carmine pink" : @"EB4C42", @"Carmine red" : @"FF0038", @"Carnation pink" : @"FFA6C9", @"Carnelian" : @"B31B1B", @"Carolina blue" : @"99BADD", @"Carrot orange" : @"ED9121", @"Castleton green" : @"00563F", @"Catalina blue" : @"062A78", @"Catawba" : @"703642", @"Cedar Chest" : @"C95A49", @"Ceil" : @"92A1CF", @"Celadon" : @"ACE1AF", @"Celadon blue" : @"007BA7", @"Celadon green" : @"2F847C", @"Celeste (colour)" : @"B2FFFF", @"Celestial blue" : @"4997D0", @"Cerise" : @"DE3163", @"Cerise pink" : @"EC3B83", @"Cerulean" : @"007BA7", @"Cerulean blue" : @"2A52BE", @"Cerulean frost" : @"6D9BC3", @"CG Blue" : @"007AA5", @"CG Red" : @"E03C31", @"Chamoisee" : @"A0785A", @"Champagne" : @"F7E7CE", @"Charcoal" : @"36454F", @"Charleston green" : @"232B2B", @"Charm pink" : @"E68FAC", @"Chartreuse (traditional)" : @"DFFF00", @"Chartreuse (web)" : @"7FFF00", @"Cherry" : @"DE3163", @"Cherry blossom pink" : @"FFB7C5", @"Chestnut" : @"954535", @"China pink" : @"DE6FA1", @"China rose" : @"A8516E", @"Chinese red" : @"AA381E", @"Chinese violet" : @"856088", @"Chocolate (traditional)" : @"7B3F00", @"Chocolate (web)" : @"D2691E", @"Chrome yellow" : @"FFA700", @"Cinereous" : @"98817B", @"Cinnabar" : @"E34234", @"Cinnamon" : @"D2691E", @"Citrine" : @"E4D00A", @"Citron" : @"9FA91F", @"Claret" : @"7F1734", @"Classic rose" : @"FBCCE7", @"Cobalt" : @"0047AB", @"Cocoa brown" : @"D2691E", @"Coconut" : @"965A3E", @"Coffee" : @"6F4E37", @"Columbia blue" : @"9BDDFF", @"Congo pink" : @"F88379", @"Cool black" : @"002E63", @"Cool gray" : @"8C92AC", @"Copper" : @"B87333", @"Copper (Crayola)" : @"DA8A67", @"Copper penny" : @"AD6F69", @"Copper red" : @"CB6D51", @"Copper rose" : @"996666", @"Coquelicot" : @"FF3800", @"Coral" : @"FF7F50", @"Coral pink" : @"F88379", @"Coral red" : @"FF4040", @"Cordovan" : @"893F45", @"Corn" : @"FBEC5D", @"Cornell Red" : @"B31B1B", @"Cornflower blue" : @"6495ED", @"Cornsilk" : @"FFF8DC", @"Cosmic latte" : @"FFF8E7", @"Cotton candy" : @"FFBCD9", @"Cream" : @"FFFDD0", @"Crimson" : @"DC143C", @"Crimson glory" : @"BE0032", @"Cyan" : @"00FFFF", @"Cyan (process)" : @"00B7EB", @"Cyber grape" : @"58427C", @"Daffodil" : @"FFFF31", @"Dandelion" : @"F0E130", @"Dark blue" : @"00008B", @"Dark blue-gray" : @"666699", @"Dark brown" : @"654321", @"Dark byzantium" : @"5D3954", @"Dark candy apple red" : @"A40000", @"Dark cerulean" : @"08457E", @"Dark chestnut" : @"986960", @"Dark coral" : @"CD5B45", @"Dark cyan" : @"008B8B", @"Dark electric blue" : @"536878", @"Dark goldenrod" : @"B8860B", @"Dark gray" : @"A9A9A9", @"Dark green" : @"013220", @"Dark imperial blue" : @"00416A", @"Dark jungle green" : @"1A2421", @"Dark khaki" : @"BDB76B", @"Dark lava" : @"483C32", @"Dark lavender" : @"734F96", @"Dark magenta" : @"8B008B", @"Dark midnight blue" : @"003366", @"Dark moss green" : @"4A5D23", @"Dark olive green" : @"556B2F", @"Dark orange" : @"FF8C00", @"Dark orchid" : @"9932CC", @"Dark pastel blue" : @"779ECB", @"Dark pastel green" : @"03C03C", @"Dark pastel purple" : @"966FD6", @"Dark pastel red" : @"C23B22", @"Dark pink" : @"E75480", @"Dark powder blue" : @"003399", @"Dark raspberry" : @"872657", @"Dark red" : @"8B0000", @"Dark salmon" : @"E9967A", @"Dark scarlet" : @"560319", @"Dark sea green" : @"8FBC8F", @"Dark sienna" : @"3C1414", @"Dark sky blue" : @"8CBED6", @"Dark slate blue" : @"483D8B", @"Dark slate gray" : @"2F4F4F", @"Dark spring green" : @"177245", @"Dark tan" : @"918151", @"Dark tangerine" : @"FFA812", @"Dark taupe" : @"483C32", @"Dark terra cotta" : @"CC4E5C", @"Dark turquoise" : @"00CED1", @"Dark vanilla" : @"D1BEA8", @"Dark violet" : @"9400D3", @"Dark yellow" : @"9B870C", @"Dartmouth green" : @"00703C", @"Davy's gray" : @"555555", @"Debian red" : @"D70A53", @"Deep carmine" : @"A9203E", @"Deep carmine pink" : @"EF3038", @"Deep carrot orange" : @"E9692C", @"Deep cerise" : @"DA3287", @"Deep champagne" : @"FAD6A5", @"Deep chestnut" : @"B94E48", @"Deep coffee" : @"704241", @"Deep fuchsia" : @"C154C1", @"Deep jungle green" : @"004B49", @"Deep lemon" : @"F5C71A", @"Deep lilac" : @"9955BB", @"Deep magenta" : @"CC00CC", @"Deep mauve" : @"D473D4", @"Deep moss green" : @"355E3B", @"Deep peach" : @"FFCBA4", @"Deep pink" : @"FF1493", @"Deep ruby" : @"843F5B", @"Deep saffron" : @"FF9933", @"Deep sky blue" : @"00BFFF", @"Deep Space Sparkle" : @"4A646C", @"Deep Taupe" : @"7E5E60", @"Deep Tuscan red" : @"66424D", @"Deer" : @"BA8759", @"Denim" : @"1560BD", @"Desert" : @"C19A6B", @"Desert sand" : @"EDC9AF", @"Diamond" : @"B9F2FF", @"Dim gray" : @"696969", @"Dirt" : @"9B7653", @"Dodger blue" : @"1E90FF", @"Dogwood rose" : @"D71868", @"Dollar bill" : @"85BB65", @"Drab" : @"967117", @"Duke blue" : @"00009C", @"Dust storm" : @"E5CCC9", @"Earth yellow" : @"E1A95F", @"Ebony" : @"555D50", @"Ecru" : @"C2B280", @"Eggplant" : @"614051", @"Eggshell" : @"F0EAD6", @"Egyptian blue" : @"1034A6", @"Electric blue" : @"7DF9FF", @"Electric crimson" : @"FF003F", @"Electric cyan" : @"00FFFF", @"Electric green" : @"00FF00", @"Electric indigo" : @"6F00FF", @"Electric lavender" : @"F4BBFF", @"Electric lime" : @"CCFF00", @"Electric purple" : @"BF00FF", @"Electric ultramarine" : @"3F00FF", @"Electric violet" : @"8F00FF", @"Electric yellow" : @"FFFF33", @"Emerald" : @"50C878", @"English green" : @"1B4D3E", @"English lavender" : @"B48395", @"English red" : @"AB4B52", @"English violet" : @"563C5C", @"Eton blue" : @"96C8A2", @"Eucalyptus" : @"44D7A8", @"Fallow" : @"C19A6B", @"Falu red" : @"801818", @"Fandango" : @"B53389", @"Fandango pink" : @"DE5285", @"Fashion fuchsia" : @"F400A1", @"Fawn" : @"E5AA70", @"Feldgrau" : @"4D5D53", @"Feldspar" : @"FDD5B1", @"Fern green" : @"4F7942", @"Ferrari Red" : @"FF2800", @"Field drab" : @"6C541E", @"Firebrick" : @"B22222", @"Fire engine red" : @"CE2029", @"Flame" : @"E25822", @"Flamingo pink" : @"FC8EAC", @"Flattery" : @"6B4423", @"Flavescent" : @"F7E98E", @"Flax" : @"EEDC82", @"Floral white" : @"FFFAF0", @"Fluorescent orange" : @"FFBF00", @"Fluorescent pink" : @"FF1493", @"Fluorescent yellow" : @"CCFF00", @"Folly" : @"FF004F", @"Forest green (traditional)" : @"014421", @"Forest green (web)" : @"228B22", @"French beige" : @"A67B5B", @"French bistre" : @"856D4D", @"French blue" : @"0072BB", @"French lilac" : @"86608E", @"French lime" : @"9EFD38", @"French mauve" : @"D473D4", @"French raspberry" : @"C72C48", @"French rose" : @"F64A8A", @"French sky blue" : @"77B5FE", @"French wine" : @"AC1E44", @"Fresh Air" : @"A6E7FF", @"Fuchsia" : @"FF00FF", @"Fuchsia (Crayola)" : @"C154C1", @"Fuchsia pink" : @"FF77FF", @"Fuchsia rose" : @"C74375", @"Fulvous" : @"E48400", @"Fuzzy Wuzzy" : @"CC6666", @"Gainsboro" : @"DCDCDC", @"Gamboge" : @"E49B0F", @"Ghost white" : @"F8F8FF", @"Giants orange" : @"FE5A1D", @"Ginger" : @"B06500", @"Glaucous" : @"6082B6", @"Glitter" : @"E6E8FA", @"GO green" : @"00AB66", @"Gold (metallic)" : @"D4AF37", @"Gold (web) (Golden)" : @"FFD700", @"Gold Fusion" : @"85754E", @"Golden brown" : @"996515", @"Golden poppy" : @"FCC200", @"Golden yellow" : @"FFDF00", @"Goldenrod" : @"DAA520", @"Granny Smith Apple" : @"A8E4A0", @"Grape" : @"6F2DA8", @"Gray" : @"808080", @"Gray (HTML/CSS gray)" : @"808080", @"Gray (X11 gray)" : @"BEBEBE", @"Gray-asparagus" : @"465945", @"Gray-blue" : @"8C92AC", @"Green (color wheel) (X11 green)" : @"00FF00", @"Green (Crayola)" : @"1CAC78", @"Green (HTML/CSS color)" : @"008000", @"Green (Munsell)" : @"00A877", @"Green (NCS)" : @"009F6B", @"Green (pigment)" : @"00A550", @"Green (RYB)" : @"66B032", @"Green-yellow" : @"ADFF2F", @"Grullo" : @"A99A86", @"Guppie green" : @"00FF7F", @"Halayà úbe" : @"663854", @"Han blue" : @"446CCF", @"Han purple" : @"5218FA", @"Hansa yellow" : @"E9D66B", @"Harlequin" : @"3FFF00", @"Harvard crimson" : @"C90016", @"Harvest gold" : @"DA9100", @"Heart Gold" : @"808000", @"Heliotrope" : @"DF73FF", @"Hollywood cerise" : @"F400A1", @"Honeydew" : @"F0FFF0", @"Honolulu blue" : @"006DB0", @"Hooker's green" : @"49796B", @"Hot magenta" : @"FF1DCE", @"Hot pink" : @"FF69B4", @"Hunter green" : @"355E3B", @"Iceberg" : @"71A6D2", @"Icterine" : @"FCF75E", @"Illuminating Emerald" : @"319177", @"Imperial" : @"602F6B", @"Imperial blue" : @"002395", @"Imperial purple" : @"66023C", @"Imperial red" : @"ED2939", @"Inchworm" : @"B2EC5D", @"India green" : @"138808", @"Indian red" : @"CD5C5C", @"Indian yellow" : @"E3A857", @"Indigo" : @"6F00FF", @"Indigo (dye)" : @"00416A", @"Indigo (web)" : @"4B0082", @"International Klein Blue" : @"002FA7", @"International orange (aerospace)" : @"FF4F00", @"International orange (engineering)" : @"BA160C", @"International orange (Golden Gate Bridge)" : @"C0362C", @"Iris" : @"5A4FCF", @"Irresistible" : @"B3446C", @"Isabelline" : @"F4F0EC", @"Islamic green" : @"009000", @"Italian sky blue" : @"B2FFFF", @"Ivory" : @"FFFFF0", @"Jade" : @"00A86B", @"Japanese indigo" : @"264348", @"Japanese violet" : @"5B3256", @"Jasmine" : @"F8DE7E", @"Jasper" : @"D73B3E", @"Jazzberry jam" : @"A50B5E", @"Jelly Bean" : @"DA614E", @"Jet" : @"343434", @"Jonquil" : @"F4CA16", @"June bud" : @"BDDA57", @"Jungle green" : @"29AB87", @"Kelly green" : @"4CBB17", @"Kenyan copper" : @"7C1C05", @"Keppel" : @"3AB09E", @"Khaki (HTML/CSS) (Khaki)" : @"C3B091", @"Khaki (X11) (Light khaki)" : @"F0E68C", @"Kobe" : @"882D17", @"Kobi" : @"E79FC4", @"KU Crimson" : @"E8000D", @"La Salle Green" : @"087830", @"Languid lavender" : @"D6CADD", @"Lapis lazuli" : @"26619C", @"Laser Lemon" : @"FFFF66", @"Laurel green" : @"A9BA9D", @"Lava" : @"CF1020", @"Lavender (floral)" : @"B57EDC", @"Lavender (web)" : @"E6E6FA", @"Lavender blue" : @"CCCCFF", @"Lavender blush" : @"FFF0F5", @"Lavender gray" : @"C4C3D0", @"Lavender indigo" : @"9457EB", @"Lavender magenta" : @"EE82EE", @"Lavender mist" : @"E6E6FA", @"Lavender pink" : @"FBAED2", @"Lavender purple" : @"967BB6", @"Lavender rose" : @"FBA0E3", @"Lawn green" : @"7CFC00", @"Lemon" : @"FFF700", @"Lemon chiffon" : @"FFFACD", @"Lemon curry" : @"CCA01D", @"Lemon glacier" : @"FDFF00", @"Lemon lime" : @"E3FF00", @"Lemon meringue" : @"F6EABE", @"Lemon yellow" : @"FFF44F", @"Licorice" : @"1A1110", @"Light apricot" : @"FDD5B1", @"Light blue" : @"ADD8E6", @"Light brown" : @"B5651D", @"Light carmine pink" : @"E66771", @"Light coral" : @"F08080", @"Light cornflower blue" : @"93CCEA", @"Light crimson" : @"F56991", @"Light cyan" : @"E0FFFF", @"Light fuchsia pink" : @"F984EF", @"Light goldenrod yellow" : @"FAFAD2", @"Light gray" : @"D3D3D3", @"Light green" : @"90EE90", @"Light khaki" : @"F0E68C", @"Light medium orchid" : @"D39BCB", @"Light moss green" : @"ADDFAD", @"Light orchid" : @"E6A8D7", @"Light pastel purple" : @"B19CD9", @"Light pink" : @"FFB6C1", @"Light red ochre" : @"E97451", @"Light salmon" : @"FFA07A", @"Light salmon pink" : @"FF9999", @"Light sea green" : @"20B2AA", @"Light sky blue" : @"87CEFA", @"Light slate gray" : @"778899", @"Light steel blue" : @"B0C4DE", @"Light taupe" : @"B38B6D", @"Light Thulian pink" : @"E68FAC", @"Light yellow" : @"FFFFE0", @"Lilac" : @"C8A2C8", @"Lime (color wheel)" : @"BFFF00", @"Lime (web) (X11 green)" : @"00FF00", @"Lime green" : @"32CD32", @"Limerick" : @"9DC209", @"Lincoln green" : @"195905", @"Linen" : @"FAF0E6", @"Lion" : @"C19A6B", @"Little boy blue" : @"6CA0DC", @"Liver" : @"534B4F", @"Lumber" : @"FFE4CD", @"Lust" : @"E62020", @"Magenta" : @"FF00FF", @"Magenta (Crayola)" : @"FF55A3", @"Magenta (dye)" : @"CA1F7B", @"Magenta (Pantone)" : @"D0417E", @"Magenta (process)" : @"FF0090", @"Magic mint" : @"AAF0D1", @"Magnolia" : @"F8F4FF", @"Mahogany" : @"C04000", @"Maize" : @"FBEC5D", @"Majorelle Blue" : @"6050DC", @"Malachite" : @"0BDA51", @"Manatee" : @"979AAA", @"Mango Tango" : @"FF8243", @"Mantis" : @"74C365", @"Mardi Gras" : @"880085", @"Maroon (Crayola)" : @"C32148", @"Maroon (HTML/CSS)" : @"800000", @"Maroon (X11)" : @"B03060", @"Mauve" : @"E0B0FF", @"Mauve taupe" : @"915F6D", @"Mauvelous" : @"EF98AA", @"Maya blue" : @"73C2FB", @"Meat brown" : @"E5B73B", @"Medium aquamarine" : @"66DDAA", @"Medium blue" : @"0000CD", @"Medium candy apple red" : @"E2062C", @"Medium carmine" : @"AF4035", @"Medium champagne" : @"F3E5AB", @"Medium electric blue" : @"035096", @"Medium jungle green" : @"1C352D", @"Medium lavender magenta" : @"DDA0DD", @"Medium orchid" : @"BA55D3", @"Medium Persian blue" : @"0067A5", @"Medium purple" : @"9370DB", @"Medium red-violet" : @"BB3385", @"Medium ruby" : @"AA4069", @"Medium sea green" : @"3CB371", @"Medium sky blue" : @"80DAEB", @"Medium slate blue" : @"7B68EE", @"Medium spring bud" : @"C9DC87", @"Medium spring green" : @"00FA9A", @"Medium taupe" : @"674C47", @"Medium turquoise" : @"48D1CC", @"Medium Tuscan red" : @"79443B", @"Medium vermilion" : @"D9603B", @"Medium violet-red" : @"C71585", @"Mellow apricot" : @"F8B878", @"Mellow yellow" : @"F8DE7E", @"Melon" : @"FDBCB4", @"Metallic Seaweed" : @"0A7E8C", @"Metallic Sunburst" : @"9C7C38", @"Mexican pink" : @"E4007C", @"Midnight blue" : @"191970", @"Midnight green (eagle green)" : @"004953", @"Midori" : @"E3F988", @"Mikado yellow" : @"FFC40C", @"Mint" : @"3EB489", @"Mint cream" : @"F5FFFA", @"Mint green" : @"98FF98", @"Misty rose" : @"FFE4E1", @"Moccasin" : @"FAEBD7", @"Mode beige" : @"967117", @"Moonstone blue" : @"73A9C2", @"Mordant red 19" : @"AE0C00", @"Moss green" : @"8A9A5B", @"Mountain Meadow" : @"30BA8F", @"Mountbatten pink" : @"997A8D", @"MSU Green" : @"18453B", @"Mughal green" : @"306030", @"Mulberry" : @"C54B8C", @"Mustard" : @"FFDB58", @"Myrtle green" : @"317873", @"Nadeshiko pink" : @"F6ADC6", @"Napier green" : @"2A8000", @"Naples yellow" : @"FADA5E", @"Navajo white" : @"FFDEAD", @"Navy blue" : @"000080", @"Navy purple" : @"9457EB", @"Neon Carrot" : @"FFA343", @"Neon fuchsia" : @"FE4164", @"Neon green" : @"39FF14", @"New Car" : @"214FC6", @"New York pink" : @"D7837F", @"Non-photo blue" : @"A4DDED", @"North Texas Green" : @"059033", @"Nyanza" : @"E9FFDB", @"Ocean Boat Blue" : @"0077BE", @"Ochre" : @"CC7722", @"Office green" : @"008000", @"Old burgundy" : @"43302E", @"Old gold" : @"CFB53B", @"Old lace" : @"FDF5E6", @"Old lavender" : @"796878", @"Old mauve" : @"673147", @"Old moss green" : @"867E36", @"Old rose" : @"C08081", @"Old silver" : @"848482", @"Olive" : @"808000", @"Olive Drab (web) (Olive Drab #3)" : @"6B8E23", @"Olive Drab #7" : @"3C341F", @"Olivine" : @"9AB973", @"Onyx" : @"353839", @"Opera mauve" : @"B784A7", @"Orange (color wheel)" : @"FF7F00", @"Orange (Crayola)" : @"FF7538", @"Orange (Pantone)" : @"FF5800", @"Orange (RYB)" : @"FB9902", @"Orange (web color)" : @"FFA500", @"Orange peel" : @"FF9F00", @"Orange-red" : @"FF4500", @"Orchid" : @"DA70D6", @"Orchid pink" : @"F28DCD", @"Orioles orange" : @"FB4F14", @"Otter brown" : @"654321", @"Outer Space" : @"414A4C", @"Outrageous Orange" : @"FF6E4A", @"Oxford Blue" : @"002147", @"OU Crimson Red" : @"990000", @"Pakistan green" : @"006600", @"Palatinate blue" : @"273BE2", @"Palatinate purple" : @"682860", @"Pale aqua" : @"BCD4E6", @"Pale blue" : @"AFEEEE", @"Pale brown" : @"987654", @"Pale carmine" : @"AF4035", @"Pale cerulean" : @"9BC4E2", @"Pale chestnut" : @"DDADAF", @"Pale copper" : @"DA8A67", @"Pale cornflower blue" : @"ABCDEF", @"Pale gold" : @"E6BE8A", @"Pale goldenrod" : @"EEE8AA", @"Pale green" : @"98FB98", @"Pale lavender" : @"DCD0FF", @"Pale magenta" : @"F984E5", @"Pale pink" : @"FADADD", @"Pale plum" : @"DDA0DD", @"Pale red-violet" : @"DB7093", @"Pale robin egg blue" : @"96DED1", @"Pale silver" : @"C9C0BB", @"Pale spring bud" : @"ECEBBD", @"Pale taupe" : @"BC987E", @"Pale turquoise" : @"AFEEEE", @"Pale violet-red" : @"DB7093", @"Pansy purple" : @"78184A", @"Papaya whip" : @"FFEFD5", @"Paris Green" : @"50C878", @"Pastel blue" : @"AEC6CF", @"Pastel brown" : @"836953", @"Pastel gray" : @"CFCFC4", @"Pastel green" : @"77DD77", @"Pastel magenta" : @"F49AC2", @"Pastel orange" : @"FFB347", @"Pastel pink" : @"DEA5A4", @"Pastel purple" : @"B39EB5", @"Pastel red" : @"FF6961", @"Pastel violet" : @"CB99C9", @"Pastel yellow" : @"FDFD96", @"Patriarch" : @"800080", @"Payne's gray" : @"536878", @"Peach" : @"FFE5B4", @"Peach (Crayola)" : @"FFCBA4", @"Peach-orange" : @"FFCC99", @"Peach puff" : @"FFDAB9", @"Peach-yellow" : @"FADFAD", @"Pear" : @"D1E231", @"Pearl" : @"EAE0C8", @"Pearl Aqua" : @"88D8C0", @"Pearly purple" : @"B768A2", @"Peridot" : @"E6E200", @"Periwinkle" : @"CCCCFF", @"Persian blue" : @"1C39BB", @"Persian green" : @"00A693", @"Persian indigo" : @"32127A", @"Persian orange" : @"D99058", @"Persian pink" : @"F77FBE", @"Persian plum" : @"701C1C", @"Persian red" : @"CC3333", @"Persian rose" : @"FE28A2", @"Persimmon" : @"EC5800", @"Peru" : @"CD853F", @"Phlox" : @"DF00FF", @"Phthalo blue" : @"000F89", @"Phthalo green" : @"123524", @"Pictorial carmine" : @"C30B4E", @"Piggy pink" : @"FDDDE6", @"Pine green" : @"01796F", @"Pink" : @"FFC0CB", @"Pink lace" : @"FFDDF4", @"Pink-orange" : @"FF9966", @"Pink pearl" : @"E7ACCF", @"Pink Sherbet" : @"F78FA7", @"Pistachio" : @"93C572", @"Platinum" : @"E5E4E2", @"Plum (traditional)" : @"8E4585", @"Plum (web)" : @"DDA0DD", @"Pomp and Power" : @"86608E", @"Portland Orange" : @"FF5A36", @"Powder blue (web)" : @"B0E0E6", @"Princeton orange" : @"FF8F00", @"Prune" : @"701C1C", @"Prussian blue" : @"003153", @"Psychedelic purple" : @"DF00FF", @"Puce" : @"CC8899", @"Pumpkin" : @"FF7518", @"Purple (HTML/CSS)" : @"800080", @"Purple (Munsell)" : @"9F00C5", @"Purple (X11)" : @"A020F0", @"Purple Heart" : @"69359C", @"Purple mountain majesty" : @"9678B6", @"Purple pizzazz" : @"FE4EDA", @"Purple taupe" : @"50404D", @"Quartz" : @"51484F", @"Queen blue" : @"436B95", @"Queen pink" : @"E8CCD7", @"Rackley" : @"5D8AA8", @"Radical Red" : @"FF355E", @"Rajah" : @"FBAB60", @"Raspberry" : @"E30B5D", @"Raspberry glace" : @"915F6D", @"Raspberry pink" : @"E25098", @"Raspberry rose" : @"B3446C", @"Raw umber" : @"826644", @"Razzle dazzle rose" : @"FF33CC", @"Razzmatazz" : @"E3256B", @"Razzmic Berry" : @"8D4E85", @"Red" : @"FF0000", @"Red (Crayola)" : @"EE204D", @"Red (Munsell)" : @"F2003C", @"Red (NCS)" : @"C40233", @"Red (Pantone)" : @"ED2939", @"Red (pigment)" : @"ED1C24", @"Red (RYB)" : @"FE2712", @"Red-brown" : @"A52A2A", @"Red devil" : @"860111", @"Red-orange" : @"FF5349", @"Red-violet" : @"C71585", @"Redwood" : @"A45A52", @"Regalia" : @"522D80", @"Resolution blue" : @"002387", @"Rhythm" : @"777696", @"Rich black" : @"004040", @"Rich brilliant lavender" : @"F1A7FE", @"Rich carmine" : @"D70040", @"Rich electric blue" : @"0892D0", @"Rich lavender" : @"A76BCF", @"Rich lilac" : @"B666D2", @"Rich maroon" : @"B03060", @"Rifle green" : @"444C38", @"Robin egg blue" : @"00CCCC", @"Rocket metallic" : @"8A7F80", @"Roman silver" : @"838996", @"Rose" : @"FF007F", @"Rose bonbon" : @"F9429E", @"Rose ebony" : @"674846", @"Rose gold" : @"B76E79", @"Rose madder" : @"E32636", @"Rose pink" : @"FF66CC", @"Rose quartz" : @"AA98A9", @"Rose red" : @"C21E56", @"Rose taupe" : @"905D5D", @"Rose vale" : @"AB4E52", @"Rosewood" : @"65000B", @"Rosso corsa" : @"D40000", @"Rosy brown" : @"BC8F8F", @"Royal azure" : @"0038A8", @"Royal blue (traditional)" : @"002366", @"Royal blue (web)" : @"4169E1", @"Royal fuchsia" : @"CA2C92", @"Royal purple" : @"7851A9", @"Royal yellow" : @"FADA5E", @"Ruber" : @"CE4676", @"Rubine red" : @"D10056", @"Ruby" : @"E0115F", @"Ruby red" : @"9B111E", @"Ruddy" : @"FF0028", @"Ruddy brown" : @"BB6528", @"Ruddy pink" : @"E18E96", @"Rufous" : @"A81C07", @"Russet" : @"80461B", @"Russian green" : @"679267", @"Russian violet" : @"32174D", @"Rust" : @"B7410E", @"Rusty red" : @"DA2C43", @"Sacramento State green" : @"00563F", @"Saddle brown" : @"8B4513", @"Safety orange (blaze orange)" : @"FF6700", @"Safety yellow" : @"EED202", @"Saffron" : @"F4C430", @"St. Patrick's blue" : @"23297A", @"Salmon" : @"FF8C69", @"Salmon pink" : @"FF91A4", @"Sand" : @"C2B280", @"Sand dune" : @"967117", @"Sandstorm" : @"ECD540", @"Sandy brown" : @"F4A460", @"Sandy taupe" : @"967117", @"Sangria" : @"92000A", @"Sap green" : @"507D2A", @"Sapphire" : @"0F52BA", @"Sapphire blue" : @"0067A5", @"Satin sheen gold" : @"CBA135", @"Scarlet" : @"FF2400", @"Scarlet (Crayola)" : @"FD0E35", @"Schauss pink" : @"FF91AF", @"School bus yellow" : @"FFD800", @"Screamin' Green" : @"76FF7A", @"Sea blue" : @"006994", @"Sea green" : @"2E8B57", @"Seal brown" : @"321414", @"Seashell" : @"FFF5EE", @"Selective yellow" : @"FFBA00", @"Sepia" : @"704214", @"Shadow" : @"8A795D", @"Shampoo" : @"FFCFF1", @"Shamrock green" : @"009E60", @"Sheen Green" : @"8FD400", @"Shimmering Blush" : @"D98695", @"Shocking pink" : @"FC0FC0", @"Shocking pink (Crayola)" : @"FF6FFF", @"Sienna" : @"882D17", @"Silver" : @"C0C0C0", @"Silver chalice" : @"ACACAC", @"Silver Lake blue" : @"5D89BA", @"Silver pink" : @"C4AEAD", @"Silver sand" : @"BFC1C2", @"Sinopia" : @"CB410B", @"Skobeloff" : @"007474", @"Sky blue" : @"87CEEB", @"Sky magenta" : @"CF71AF", @"Slate blue" : @"6A5ACD", @"Slate gray" : @"708090", @"Smalt (Dark powder blue)" : @"003399", @"Smitten" : @"C84186", @"Smoke" : @"738276", @"Smokey topaz" : @"933D41", @"Smoky black" : @"100C08", @"Snow" : @"FFFAFA", @"Soap" : @"CEC8EF", @"Sonic silver" : @"757575", @"Spartan Crimson" : @"9E1316", @"Space cadet" : @"1D2951", @"Spanish bistre" : @"80755A", @"Spanish carmine" : @"D10047", @"Spanish crimson" : @"E51A4C", @"Spanish orange" : @"E86100", @"Spanish sky blue" : @"00AAE4", @"Spiro Disco Ball" : @"0FC0FC", @"Spring bud" : @"A7FC00", @"Spring green" : @"00FF7F", @"Star command blue" : @"007BB8", @"Steel blue" : @"4682B4", @"Steel pink" : @"CC3366", @"Stil de grain yellow" : @"FADA5E", @"Stizza" : @"990000", @"Stormcloud" : @"4F666A", @"Straw" : @"E4D96F", @"Strawberry" : @"FC5A8D", @"Sunglow" : @"FFCC33", @"Sunray" : @"E3AB57", @"Sunset" : @"FAD6A5", @"Sunset orange" : @"FD5E53", @"Super pink" : @"CF6BA9", @"Tan" : @"D2B48C", @"Tangelo" : @"F94D00", @"Tangerine" : @"F28500", @"Tangerine yellow" : @"FFCC00", @"Tango pink" : @"E4717A", @"Taupe" : @"483C32", @"Taupe gray" : @"8B8589", @"Tea green" : @"D0F0C0", @"Tea rose (orange)" : @"F88379", @"Tea rose (rose)" : @"F4C2C2", @"Teal" : @"008080", @"Teal blue" : @"367588", @"Teal deer" : @"99E6B3", @"Teal green" : @"00827F", @"Telemagenta" : @"CF3476", @"Tenné (Tawny)" : @"CD5700", @"Terra cotta" : @"E2725B", @"Thistle" : @"D8BFD8", @"Thulian pink" : @"DE6FA1", @"Tickle Me Pink" : @"FC89AC", @"Tiffany Blue" : @"0ABAB5", @"Tiger's eye" : @"E08D3C", @"Timberwolf" : @"DBD7D2", @"Titanium yellow" : @"EEE600", @"Tomato" : @"FF6347", @"Toolbox" : @"746CC0", @"Topaz" : @"FFC87C", @"Tractor red" : @"FD0E35", @"Trolley gray" : @"808080", @"Tropical rain forest" : @"00755E", @"True Blue" : @"0073CF", @"Tufts Blue" : @"417DC1", @"Tulip" : @"FF878D", @"Tumbleweed" : @"DEAA88", @"Turkish rose" : @"B57281", @"Turquoise" : @"30D5C8", @"Turquoise blue" : @"00FFEF", @"Turquoise green" : @"A0D6B4", @"Tuscan" : @"FAD6A5", @"Tuscan brown" : @"6F4E37", @"Tuscan red" : @"7C4848", @"Tuscan tan" : @"A67B5B", @"Tuscany" : @"C09999", @"Twilight lavender" : @"8A496B", @"Tyrian purple" : @"66023C", @"UA blue" : @"0033AA", @"UA red" : @"D9004C", @"Ube" : @"8878C3", @"UCLA Blue" : @"536895", @"UCLA Gold" : @"FFB300", @"UFO Green" : @"3CD070", @"Ultramarine" : @"120A8F", @"Ultramarine blue" : @"4166F5", @"Ultra pink" : @"FF6FFF", @"Umber" : @"635147", @"Unbleached silk" : @"FFDDCA", @"United Nations blue" : @"5B92E5", @"University of California Gold" : @"B78727", @"Unmellow yellow" : @"FFFF66", @"UP Forest green" : @"014421", @"UP Maroon" : @"7B1113", @"Upsdell red" : @"AE2029", @"Urobilin" : @"E1AD21", @"USAFA blue" : @"004F98", @"USC Cardinal" : @"990000", @"USC Gold" : @"FFCC00", @"University of Tennessee Orange" : @"F77F00", @"Utah Crimson" : @"D3003F", @"Vanilla" : @"F3E5AB", @"Vanilla ice" : @"F3D9DF", @"Vegas gold" : @"C5B358", @"Venetian red" : @"C80815", @"Verdigris" : @"43B3AE", @"Vermilion (cinnabar)" : @"E34234", @"Vermilion (Plochere)" : @"D9603B", @"Veronica" : @"A020F0", @"Violet" : @"8F00FF", @"Violet (color wheel)" : @"7F00FF", @"Violet (RYB)" : @"8601AF", @"Violet (web)" : @"EE82EE", @"Violet-blue" : @"324AB2", @"Violet-red" : @"F75394", @"Viridian" : @"40826D", @"Vivid auburn" : @"922724", @"Vivid burgundy" : @"9F1D35", @"Vivid cerise" : @"DA1D81", @"Vivid orchid" : @"CC00FF", @"Vivid sky blue" : @"00CCFF", @"Vivid tangerine" : @"FFA089", @"Vivid violet" : @"9F00FF", @"Warm black" : @"004242", @"Waterspout" : @"A4F4F9", @"Wenge" : @"645452", @"Wheat" : @"F5DEB3", @"White" : @"FFFFFF", @"White smoke" : @"F5F5F5", @"Wild blue yonder" : @"A2ADD0", @"Wild orchid" : @"D77A02", @"Wild Strawberry" : @"FF43A4", @"Wild Watermelon" : @"FC6C85", @"Windsor tan" : @"AE6838", @"Wine" : @"722F37", @"Wine dregs" : @"673147", @"Wisteria" : @"C9A0DC", @"Wood brown" : @"C19A6B", @"Xanadu" : @"738678", @"Yale Blue" : @"0F4D92", @"Yankees blue" : @"1C2841", @"Yellow" : @"FFFF00", @"Yellow (Munsell)" : @"EFCC00", @"Yellow (NCS)" : @"FFD300", @"Yellow (process)" : @"FFEF00", @"Yellow (RYB)" : @"FEFE33", @"Yellow-green" : @"9ACD32", @"Yellow Orange" : @"FFAE42", @"Yellow rose" : @"FFF000", @"Zaffre" : @"0014A8", @"Zinnwaldite brown" : @"2C1608", @"Zomp" : @"39A78E"};

    /*
     http://www.hpl.hp.com/personal/Nathan_Moroney/ei03-moroney.pdf
     http://www.hpl.hp.com/personal/Nathan_Moroney/color-name-hpl.html     
     */
    NSDictionary *moroneyDictionary = @{@"navy blue": @"1b2183", @"dark blue": @"1b2596", @"navy": @"1c2182", @"midnight blue": @"1d1e87", @"black": @"1e1e20", @"true blue": @"1f47d7", @"bright blue": @"2052f3", @"forest green": @"247532", @"jungle green": @"24ae62", @"dark green": @"25702b", @"kelly green": @"25bd38", @"electric blue": @"2646ea", @"forest": @"267631", @"evergreen": @"267933", @"royal blue": @"2729d4", @"hunter green": @"276e33", @"cerulean": @"2975f1", @"green blue": @"29b795", @"deep blue": @"2a22bd", @"marine blue": @"2a6bcc", @"cobalt blue": @"2d3ad5", @"teal blue": @"2f7bac", @"emerald": @"30b853", @"blue green": @"31b49e", @"aquamarine": @"31d3c7", @"cobalt": @"3331d5", @"cerulean blue": @"3381f5", @"pine": @"357f39", @"pine green": @"377d2f", @"medium green": @"37b042", @"electric green": @"37fa33", @"steel blue": @"38619e", @"blue": @"3865d2", @"dark cyan": @"3884af", @"aqua green": @"38daae", @"medium blue": @"3957db", @"ocean blue": @"3987c9", @"grass green": @"39b82d", @"sea blue": @"3a8ed0", @"teal": @"3aafa9", @"charcoal": @"3b4445", @"emerald green": @"3bbc46", @"turquoise": @"3bd2ce", @"bright green": @"3bef37", @"leaf green": @"3db83b", @"azure": @"3e8ef4", @"cadet blue": @"3f72ae", @"grass": @"40bb30", @"jade": @"41bd85", @"dark gray": @"424c4c", @"bottle green": @"429e33", @"aqua marine": @"42d7d3", @"aqua": @"42dad3", @"slate blue": @"457da0", @"sea green": @"47d89a", @"fluorescent green": @"48fb47", @"cyan": @"49d6e7", @"neon green": @"49fb35", @"aqua blue": @"4acfee", @"dark olive": @"4b6124", @"gray blue": @"4c71a0", @"sky blue": @"4daff1", @"blue gray": @"4e89a4", @"gray green": @"4f8b78", @"sky": @"4faaee", @"green": @"4fc54a", @"cornflower blue": @"5074da", @"deep purple": @"551577", @"dark brown": @"551c1a", @"indigo": @"562bb2", @"moss green": @"579244", @"apple green": @"58e24a", @"sea foam": @"59ebad", @"gray blue": @"5a93b1", @"sea foam green": @"5aebad", @"eggplant": @"5c2068", @"purple blue": @"5c2ed0", @"light blue": @"5cb9f3", @"sea foam green": @"5ceaa9", @"slate": @"5d7e9a", @"spring green": @"5de549", @"moss": @"5e9846", @"mint": @"5eeca1", @"blue violet": @"5f26c8", @"blue gray": @"6192b5", @"sea foam": @"61e7aa", @"cornflower": @"627ede", @"mint green": @"62eca2", @"dark purple": @"63187d", @"bluish purple": @"6327c9", @"light turquoise": @"63efdf", @"army green": @"647f23", @"lime green": @"64ee38", @"dark violet": @"66248e", @"pale blue": @"66bce8", @"light teal": @"66c6bc", @"key lime": @"66ee4e", @"pastel green": @"69e49e", @"light green": @"69ea65", @"lime": @"6aef3b", @"sage green": @"6bae63", @"dark lavender": @"6f45ab", @"chocolate brown": @"71331f", @"violet blue": @"7230d8", @"baby blue": @"72c5f7", @"royal purple": @"7322b3", @"olive green": @"73922b", @"chocolate": @"743521", @"blue purple": @"7536e2", @"olive": @"77912c", @"sage": @"77b575", @"aubergine": @"7a1b70", @"gray": @"7a8e94", @"periwinkle blue": @"7e6ff3", @"gray": @"7e8f95", @"avocado": @"7fac2b", @"green yellow": @"7fe22e", @"pistachio": @"7fef76", @"periwinkle": @"8077e7", @"plum": @"872c82", @"powder blue": @"87b1f1", @"pea green": @"88c039", @"brown": @"894c24", @"pale green": @"8ae492", @"burgundy": @"8c1932", @"maroon": @"8c1c3d", @"wine": @"8c205c", @"mocha": @"8e452f", @"yellowish green": @"8ed93e", @"light cyan": @"8efff7", @"khaki": @"8f9645", @"grape": @"903093", @"purple": @"9330bc", @"yellow green": @"96dc30", @"violet": @"983bcd", @"red brown": @"993c27", @"chartreuse": @"99e326", @"lemon lime": @"9be448", @"reddish brown": @"9c3321", @"medium brown": @"9d612a", @"brick": @"ab2620", @"puce": @"ab8637", @"taupe": @"ab9371", @"bright purple": @"ae2de3", @"dark red": @"af132b", @"brick red": @"af221c", @"dark magenta": @"b21a9c", @"sienna": @"b2521d", @"light purple": @"b25fdc", @"light brown": @"b37839", @"mauve": @"b45fa0", @"rust": @"b54020", @"dark yellow": @"b5b820", @"lavender": @"b677e0", @"bright violet": @"b729f4", @"lilac": @"ba77e2", @"burnt sienna": @"c0561f", @"crimson": @"c11844", @"light violet": @"c173dd", @"light gray": @"c5c5c5", @"greenish yellow": @"c7db25", @"orchid": @"c966d4", @"raspberry": @"cd2e7a", @"dusty rose": @"ce758b", @"tan": @"d19c52", @"ochre": @"d1a329", @"mustard": @"d4b927", @"terracotta": @"d5603c", @"beige": @"d5c383", @"lemon": @"d5f14b", @"dark orange": @"d66219", @"burnt orange": @"d66715", @"sand": @"d6b55f", @"red": @"d8232c", @"gold": @"d9b324", @"magenta": @"db21ad", @"dark pink": @"dc3d96", @"rose": @"dd6398", @"yellow": @"dde840", @"mustard yellow": @"dfc12a", @"cream": @"e1dcaa", @"fuchsia": @"e62cbd", @"cerise": @"e72ba0", @"scarlet": @"e9264b", @"watermelon": @"ea5169", @"orange red": @"ed4217", @"rose pink": @"ed56a0", @"pumpkin": @"ee8a21", @"orange": @"f17820", @"bright yellow": @"f2f735", @"bright red": @"f3172d", @"flesh": @"f3b791", @"red orange": @"f4481d", @"pink": @"f45bb7", @"goldenrod": @"f4c220", @"coral": @"f55963", @"salmon": @"f57576", @"pale pink": @"f7b8b8", @"salmon pink": @"f88989", @"pastel pink": @"f999db", @"light orange": @"f9a833", @"white": @"f9fdf3", @"hot pink": @"fa27b6", @"canary yellow": @"faff45", @"light yellow": @"faff91", @"peach": @"fcaa7b", @"light pink": @"fcb3d3", @"lemon yellow": @"fcfc3e", @"tangerine": @"fd7f2a", @"pale yellow": @"fdffa0", @"bright pink": @"ff23b6", @"apricot": @"ffa863", @"yellow orange": @"ffc629", @"golden yellow": @"ffd138", @"sunshine yellow": @"fff92e"};
    
    /*
     http://xkcd.com/color/rgb.txt
     http://blog.xkcd.com/2010/05/03/color-survey-results/
     
     I have done some basic spelling fixes and replaced shit with poo
     for anyone who wants to submit with a 4+ rating to App Store.
     
     Known items *not* addressed are: orangeish, camo, azul, burple, purpleish, camo green, and blurple.
     */
    NSDictionary *xkcdDictionary = @{@"cloudy blue":@"acc2d9", @"dark pastel green":@"56ae57", @"dust":@"b2996e", @"electric lime":@"a8ff04", @"fresh green":@"69d84f", @"light eggplant":@"894585", @"nasty green":@"70b23f", @"really light blue":@"d4ffff", @"tea":@"65ab7c", @"warm purple":@"952e8f", @"yellowish tan":@"fcfc81", @"cement":@"a5a391", @"dark grass green":@"388004", @"dusty teal":@"4c9085", @"gray teal":@"5e9b8a", @"macaroni and cheese":@"efb435", @"pinkish tan":@"d99b82", @"spruce":@"0a5f38", @"strong blue":@"0c06f7", @"toxic green":@"61de2a", @"windows blue":@"3778bf", @"blue blue":@"2242c7", @"blue with a hint of purple":@"533cc6", @"booger":@"9bb53c", @"bright sea green":@"05ffa6", @"dark green blue":@"1f6357", @"deep turquoise":@"017374", @"green teal":@"0cb577", @"strong pink":@"ff0789", @"bland":@"afa88b", @"deep aqua":@"08787f", @"lavender pink":@"dd85d7", @"light moss green":@"a6c875", @"light sea foam green":@"a7ffb5", @"olive yellow":@"c2b709", @"pig pink":@"e78ea5", @"deep lilac":@"966ebd", @"desert":@"ccad60", @"dusty lavender":@"ac86a8", @"purple gray":@"947e94", @"purply":@"983fb2", @"candy pink":@"ff63e9", @"light pastel green":@"b2fba5", @"boring green":@"63b365", @"kiwi green":@"8ee53f", @"light gray green":@"b7e1a1", @"orange pink":@"ff6f52", @"tea green":@"bdf8a3", @"very light brown":@"d3b683", @"egg shell":@"fffcc4", @"eggplant purple":@"430541", @"powder pink":@"ffb2d0", @"reddish gray":@"997570", @"baby poop brown":@"ad900d", @"lilac":@"c48efd", @"stormy blue":@"507b9c", @"ugly brown":@"7d7103", @"custard":@"fffd78", @"darkish pink":@"da467d", @"deep brown":@"410200", @"greenish beige":@"c9d179", @"manilla":@"fffa86", @"off blue":@"5684ae", @"battleship gray":@"6b7c85", @"browny green":@"6f6c0a", @"bruise":@"7e4071", @"kelley green":@"009337", @"sickly yellow":@"d0e429", @"sunny yellow":@"fff917", @"azul":@"1d5dec", @"dark green":@"054907", @"green/yellow":@"b5ce08", @"lichen":@"8fb67b", @"light light green":@"c8ffb0", @"pale gold":@"fdde6c", @"sun yellow":@"ffdf22", @"tan green":@"a9be70", @"burple":@"6832e3", @"butterscotch":@"fdb147", @"taupe":@"c7ac7d", @"dark cream":@"fff39a", @"indian red":@"850e04", @"light lavender":@"efc0fe", @"poison green":@"40fd14", @"baby puke green":@"b6c406", @"bright yellow green":@"9dff00", @"charcoal gray":@"3c4142", @"squash":@"f2ab15", @"cinnamon":@"ac4f06", @"light pea green":@"c4fe82", @"radioactive green":@"2cfa1f", @"raw sienna":@"9a6200", @"baby purple":@"ca9bf7", @"cocoa":@"875f42", @"light royal blue":@"3a2efe", @"orangeish":@"fd8d49", @"rust brown":@"8b3103", @"sand brown":@"cba560", @"swamp":@"698339", @"teal green":@"0cdc73", @"burnt siena":@"b75203", @"camo":@"7f8f4e", @"dusk blue":@"26538d", @"fern":@"63a950", @"old rose":@"c87f89", @"pale light green":@"b1fc99", @"peachy pink":@"ff9a8a", @"rosy pink":@"f6688e", @"light bluish green":@"76fda8", @"light bright green":@"53fe5c", @"light neon green":@"4efd54", @"light sea foam":@"a0febf", @"tiffany blue":@"7bf2da", @"washed out green":@"bcf5a6", @"browny orange":@"ca6b02", @"nice blue":@"107ab0", @"sapphire":@"2138ab", @"gray teal":@"719f91", @"orangey yellow":@"fdb915", @"parchment":@"fefcaf", @"straw":@"fcf679", @"very dark brown":@"1d0200", @"terra cotta":@"cb6843", @"ugly blue":@"31668a", @"clear blue":@"247afd", @"creme":@"ffffb6", @"foam green":@"90fda9", @"gray/green":@"86a17d", @"light gold":@"fddc5c", @"sea foam blue":@"78d1b6", @"topaz":@"13bbaf", @"violet pink":@"fb5ffc", @"wintergreen":@"20f986", @"yellow tan":@"ffe36e", @"dark fuchsia":@"9d0759", @"indigo blue":@"3a18b1", @"light yellowish green":@"c2ff89", @"pale magenta":@"d767ad", @"rich purple":@"720058", @"sunflower yellow":@"ffda03", @"green/blue":@"01c08d", @"leather":@"ac7434", @"racing green":@"014600", @"vivid purple":@"9900fa", @"dark royal blue":@"02066f", @"hazel":@"8e7618", @"muted pink":@"d1768f", @"booger green":@"96b403", @"canary":@"fdff63", @"cool gray":@"95a3a6", @"dark taupe":@"7f684e", @"darkish purple":@"751973", @"true green":@"089404", @"coral pink":@"ff6163", @"dark sage":@"598556", @"dark slate blue":@"214761", @"flat blue":@"3c73a8", @"mushroom":@"ba9e88", @"rich blue":@"021bf9", @"dirty purple":@"734a65", @"green blue":@"23c48b", @"icky green":@"8fae22", @"light khaki":@"e6f2a2", @"warm blue":@"4b57db", @"dark hot pink":@"d90166", @"deep sea blue":@"015482", @"carmine":@"9d0216", @"dark yellow green":@"728f02", @"pale peach":@"ffe5ad", @"plum purple":@"4e0550", @"golden rod":@"f9bc08", @"neon red":@"ff073a", @"old pink":@"c77986", @"very pale blue":@"d6fffe", @"blood orange":@"fe4b03", @"grapefruit":@"fd5956", @"sand yellow":@"fce166", @"clay brown":@"b2713d", @"dark blue gray":@"1f3b4d", @"flat green":@"699d4c", @"light green blue":@"56fca2", @"warm pink":@"fb5581", @"dodger blue":@"3e82fc", @"gross green":@"a0bf16", @"ice":@"d6fffa", @"metallic blue":@"4f738e", @"pale salmon":@"ffb19a", @"sap green":@"5c8b15", @"algae":@"54ac68", @"blue gray":@"89a0b0", @"green gray":@"7ea07a", @"highlighter green":@"1bfc06", @"light light blue":@"cafffb", @"light mint":@"b6ffbb", @"raw umber":@"a75e09", @"vivid blue":@"152eff", @"deep lavender":@"8d5eb7", @"dull teal":@"5f9e8f", @"light greenish blue":@"63f7b4", @"mud green":@"606602", @"pinky":@"fc86aa", @"red wine":@"8c0034", @"poop green":@"758000", @"tan brown":@"ab7e4c", @"dark blue":@"030764", @"rosa":@"fe86a4", @"lipstick":@"d5174e", @"pale mauve":@"fed0fc", @"claret":@"680018", @"dandelion":@"fedf08", @"orange red":@"fe420f", @"poop green":@"6f7c00", @"ruby":@"ca0147", @"dark":@"1b2431", @"greenish turquoise":@"00fbb0", @"pastel red":@"db5856", @"piss yellow":@"ddd618", @"bright cyan":@"41fdfe", @"dark coral":@"cf524e", @"algae green":@"21c36f", @"darkish red":@"a90308", @"reddy brown":@"6e1005", @"blush pink":@"fe828c", @"camouflage green":@"4b6113", @"lawn green":@"4da409", @"putty":@"beae8a", @"vibrant blue":@"0339f8", @"dark sand":@"a88f59", @"purple/blue":@"5d21d0", @"saffron":@"feb209", @"twilight":@"4e518b", @"warm brown":@"964e02", @"blue gray":@"85a3b2", @"bubble gum pink":@"ff69af", @"duck egg blue":@"c3fbf4", @"greenish cyan":@"2afeb7", @"petrol":@"005f6a", @"royal":@"0c1793", @"butter":@"ffff81", @"dusty orange":@"f0833a", @"off yellow":@"f1f33f", @"pale olive green":@"b1d27b", @"orangish":@"fc824a", @"leaf":@"71aa34", @"light blue gray":@"b7c9e2", @"dried blood":@"4b0101", @"lightish purple":@"a552e6", @"rusty red":@"af2f0d", @"lavender blue":@"8b88f8", @"light grass green":@"9af764", @"light mint green":@"a6fbb2", @"sunflower":@"ffc512", @"velvet":@"750851", @"brick orange":@"c14a09", @"lightish red":@"fe2f4a", @"pure blue":@"0203e2", @"twilight blue":@"0a437a", @"violet red":@"a50055", @"yellowy brown":@"ae8b0c", @"carnation":@"fd798f", @"muddy yellow":@"bfac05", @"dark sea foam green":@"3eaf76", @"deep rose":@"c74767", @"dusty red":@"b9484e", @"gray/blue":@"647d8e", @"lemon lime":@"bffe28", @"purple/pink":@"d725de", @"brown yellow":@"b29705", @"purple brown":@"673a3f", @"wisteria":@"a87dc2", @"banana yellow":@"fafe4b", @"lipstick red":@"c0022f", @"water blue":@"0e87cc", @"brown gray":@"8d8468", @"vibrant purple":@"ad03de", @"baby green":@"8cff9e", @"barf green":@"94ac02", @"eggshell blue":@"c4fff7", @"sandy yellow":@"fdee73", @"cool green":@"33b864", @"pale":@"fff9d0", @"blue/gray":@"758da3", @"hot magenta":@"f504c9", @"gray blue":@"77a1b5", @"purple":@"8756e4", @"baby poop green":@"889717", @"brownish pink":@"c27e79", @"dark aquamarine":@"017371", @"diarrhea":@"9f8303", @"light mustard":@"f7d560", @"pale sky blue":@"bdf6fe", @"turtle green":@"75b84f", @"bright olive":@"9cbb04", @"dark gray blue":@"29465b", @"green brown":@"696006", @"lemon green":@"adf802", @"light periwinkle":@"c1c6fc", @"seaweed green":@"35ad6b", @"sunshine yellow":@"fffd37", @"ugly purple":@"a442a0", @"medium pink":@"f36196", @"puke brown":@"947706", @"very light pink":@"fff4f2", @"viridian":@"1e9167", @"bile":@"b5c306", @"faded yellow":@"feff7f", @"very pale green":@"cffdbc", @"vibrant green":@"0add08", @"bright lime":@"87fd05", @"spearmint":@"1ef876", @"light aquamarine":@"7bfdc7", @"light sage":@"bcecac", @"yellow green":@"bbf90f", @"baby poo":@"ab9004", @"dark sea foam":@"1fb57a", @"deep teal":@"00555a", @"heather":@"a484ac", @"rust orange":@"c45508", @"dirty blue":@"3f829d", @"fern green":@"548d44", @"bright lilac":@"c95efb", @"weird green":@"3ae57f", @"peacock blue":@"016795", @"avocado green":@"87a922", @"faded orange":@"f0944d", @"grape purple":@"5d1451", @"hot green":@"25ff29", @"lime yellow":@"d0fe1d", @"mango":@"ffa62b", @"shamrock":@"01b44c", @"bubblegum":@"ff6cb5", @"purple brown":@"6b4247", @"vomit yellow":@"c7c10c", @"pale cyan":@"b7fffa", @"key lime":@"aeff6e", @"tomato red":@"ec2d01", @"light green":@"76ff7b", @"merlot":@"730039", @"night blue":@"040348", @"purple pink":@"df4ec8", @"apple":@"6ecb3c", @"baby poop green":@"8f9805", @"green apple":@"5edc1f", @"heliotrope":@"d94ff5", @"yellow/green":@"c8fd3d", @"almost black":@"070d0d", @"cool blue":@"4984b8", @"leafy green":@"51b73b", @"mustard brown":@"ac7e04", @"dusk":@"4e5481", @"dull brown":@"876e4b", @"frog green":@"58bc08", @"vivid green":@"2fef10", @"bright light green":@"2dfe54", @"fluorescent green":@"0aff02", @"kiwi":@"9cef43", @"seaweed":@"18d17b", @"navy green":@"35530a", @"ultramarine blue":@"1805db", @"iris":@"6258c4", @"pastel orange":@"ff964f", @"yellowish orange":@"ffab0f", @"periwinkle":@"8f8ce7", @"teal":@"24bca8", @"dark plum":@"3f012c", @"pear":@"cbf85f", @"pinkish orange":@"ff724c", @"midnight purple":@"280137", @"light purple":@"b36ff6", @"dark mint":@"48c072", @"greenish tan":@"bccb7a", @"light burgundy":@"a8415b", @"turquoise blue":@"06b1c4", @"ugly pink":@"cd7584", @"sandy":@"f1da7a", @"electric pink":@"ff0490", @"muted purple":@"805b87", @"mid green":@"50a747", @"grayish":@"a8a495", @"neon yellow":@"cfff04", @"banana":@"ffff7e", @"carnation pink":@"ff7fa7", @"tomato":@"ef4026", @"sea":@"3c9992", @"muddy brown":@"886806", @"turquoise green":@"04f489", @"buff":@"fef69e", @"fawn":@"cfaf7b", @"muted blue":@"3b719f", @"pale rose":@"fdc1c5", @"dark mint green":@"20c073", @"amethyst":@"9b5fc0", @"blue/green":@"0f9b8e", @"chestnut":@"742802", @"sick green":@"9db92c", @"pea":@"a4bf20", @"rusty orange":@"cd5909", @"stone":@"ada587", @"rose red":@"be013c", @"pale aqua":@"b8ffeb", @"deep orange":@"dc4d01", @"earth":@"a2653e", @"mossy green":@"638b27", @"grassy green":@"419c03", @"pale lime green":@"b1ff65", @"light gray blue":@"9dbcd4", @"pale gray":@"fdfdfe", @"asparagus":@"77ab56", @"blueberry":@"464196", @"purple red":@"990147", @"pale lime":@"befd73", @"greenish teal":@"32bf84", @"caramel":@"af6f09", @"deep magenta":@"a0025c", @"light peach":@"ffd8b1", @"milk chocolate":@"7f4e1e", @"ocher":@"bf9b0c", @"off green":@"6ba353", @"purply pink":@"f075e6", @"light blue":@"7bc8f6", @"dusky blue":@"475f94", @"golden":@"f5bf03", @"light beige":@"fffeb6", @"butter yellow":@"fffd74", @"dusky purple":@"895b7b", @"french blue":@"436bad", @"ugly yellow":@"d0c101", @"green yellow":@"c6f808", @"orangish red":@"f43605", @"shamrock green":@"02c14d", @"orangish brown":@"b25f03", @"tree green":@"2a7e19", @"deep violet":@"490648", @"gunmetal":@"536267", @"blue/purple":@"5a06ef", @"cherry":@"cf0234", @"sandy brown":@"c4a661", @"warm gray":@"978a84", @"dark indigo":@"1f0954", @"midnight":@"03012d", @"blue green":@"2bb179", @"gray pink":@"c3909b", @"soft purple":@"a66fb5", @"blood":@"770001", @"brown red":@"922b05", @"medium gray":@"7d7f7c", @"berry":@"990f4b", @"poo":@"8f7303", @"purple pink":@"c83cb9", @"light salmon":@"fea993", @"snot":@"acbb0d", @"easter purple":@"c071fe", @"light yellow green":@"ccfd7f", @"dark navy blue":@"00022e", @"drab":@"828344", @"light rose":@"ffc5cb", @"rouge":@"ab1239", @"purple red":@"b0054b", @"slime green":@"99cc04", @"baby poop":@"937c00", @"irish green":@"019529", @"pink/purple":@"ef1de7", @"dark navy":@"000435", @"green blue":@"42b395", @"light plum":@"9d5783", @"pinkish gray":@"c8aca9", @"dirty orange":@"c87606", @"rust red":@"aa2704", @"pale lilac":@"e4cbff", @"orangey red":@"fa4224", @"primary blue":@"0804f9", @"kermit green":@"5cb200", @"brownish purple":@"76424e", @"murky green":@"6c7a0e", @"wheat":@"fbdd7e", @"very dark purple":@"2a0134", @"bottle green":@"044a05", @"watermelon":@"fd4659", @"deep sky blue":@"0d75f8", @"fire engine red":@"fe0002", @"yellow ochre":@"cb9d06", @"pumpkin orange":@"fb7d07", @"pale olive":@"b9cc81", @"light lilac":@"edc8ff", @"lightish green":@"61e160", @"carolina blue":@"8ab8fe", @"mulberry":@"920a4e", @"shocking pink":@"fe02a2", @"auburn":@"9a3001", @"bright lime green":@"65fe08", @"celadon":@"befdb7", @"pinkish brown":@"b17261", @"poo brown":@"885f01", @"bright sky blue":@"02ccfe", @"celery":@"c1fd95", @"dirt brown":@"836539", @"strawberry":@"fb2943", @"dark lime":@"84b701", @"copper":@"b66325", @"medium brown":@"7f5112", @"muted green":@"5fa052", @"robin's egg":@"6dedfd", @"bright aqua":@"0bf9ea", @"bright lavender":@"c760ff", @"ivory":@"ffffcb", @"very light purple":@"f6cefc", @"light navy":@"155084", @"pink red":@"f5054f", @"olive brown":@"645403", @"poop brown":@"7a5901", @"mustard green":@"a8b504", @"ocean green":@"3d9973", @"very dark blue":@"000133", @"dusty green":@"76a973", @"light navy blue":@"2e5a88", @"minty green":@"0bf77d", @"adobe":@"bd6c48", @"barney":@"ac1db8", @"jade green":@"2baf6a", @"bright light blue":@"26f7fd", @"light lime":@"aefd6c", @"dark khaki":@"9b8f55", @"orange yellow":@"ffad01", @"ochre":@"c69c04", @"maize":@"f4d054", @"faded pink":@"de9dac", @"british racing green":@"05480d", @"sandstone":@"c9ae74", @"mud brown":@"60460f", @"light sea green":@"98f6b0", @"robin egg blue":@"8af1fe", @"aqua marine":@"2ee8bb", @"dark sea green":@"11875d", @"soft pink":@"fdb0c0", @"orangey brown":@"b16002", @"cherry red":@"f7022a", @"burnt yellow":@"d5ab09", @"brownish gray":@"86775f", @"camel":@"c69f59", @"purple gray":@"7a687f", @"marine":@"042e60", @"gray pink":@"c88d94", @"pale turquoise":@"a5fbd5", @"pastel yellow":@"fffe71", @"blue purple":@"6241c7", @"canary yellow":@"fffe40", @"faded red":@"d3494e", @"sepia":@"985e2b", @"coffee":@"a6814c", @"bright magenta":@"ff08e8", @"mocha":@"9d7651", @"ecru":@"feffca", @"purpleish":@"98568d", @"cranberry":@"9e003a", @"darkish green":@"287c37", @"brown orange":@"b96902", @"dusky rose":@"ba6873", @"melon":@"ff7855", @"sickly green":@"94b21c", @"silver":@"c5c9c7", @"purply blue":@"661aee", @"purple blue":@"6140ef", @"hospital green":@"9be5aa", @"poop brown":@"7b5804", @"mid blue":@"276ab3", @"amber":@"feb308", @"easter green":@"8cfd7e", @"soft blue":@"6488ea", @"cerulean blue":@"056eee", @"golden brown":@"b27a01", @"bright turquoise":@"0ffef9", @"red pink":@"fa2a55", @"red purple":@"820747", @"gray brown":@"7a6a4f", @"vermillion":@"f4320c", @"russet":@"a13905", @"steel gray":@"6f828a", @"lighter purple":@"a55af4", @"bright violet":@"ad0afd", @"prussian blue":@"004577", @"slate green":@"658d6d", @"dirty pink":@"ca7b80", @"dark blue green":@"005249", @"pine":@"2b5d34", @"yellowy green":@"bff128", @"dark gold":@"b59410", @"bluish":@"2976bb", @"darkish blue":@"014182", @"dull red":@"bb3f3f", @"pinky red":@"fc2647", @"bronze":@"a87900", @"pale teal":@"82cbb2", @"military green":@"667c3e", @"barbie pink":@"fe46a5", @"bubblegum pink":@"fe83cc", @"pea soup green":@"94a617", @"dark mustard":@"a88905", @"poop":@"7f5f00", @"medium purple":@"9e43a2", @"very dark green":@"062e03", @"dirt":@"8a6e45", @"dusky pink":@"cc7a8b", @"red violet":@"9e0168", @"lemon yellow":@"fdff38", @"pistachio":@"c0fa8b", @"dull yellow":@"eedc5b", @"dark lime green":@"7ebd01", @"denim blue":@"3b5b92", @"teal blue":@"01889f", @"lightish blue":@"3d7afd", @"purple blue":@"5f34e7", @"light indigo":@"6d5acf", @"swamp green":@"748500", @"brown green":@"706c11", @"dark maroon":@"3c0008", @"hot purple":@"cb00f5", @"dark forest green":@"002d04", @"faded blue":@"658cbb", @"drab green":@"749551", @"light lime green":@"b9ff66", @"snot green":@"9dc100", @"yellowish":@"faee66", @"light blue green":@"7efbb3", @"bordeaux":@"7b002c", @"light mauve":@"c292a1", @"ocean":@"017b92", @"marigold":@"fcc006", @"muddy green":@"657432", @"dull orange":@"d8863b", @"steel":@"738595", @"electric purple":@"aa23ff", @"fluorescent green":@"08ff08", @"yellowish brown":@"9b7a01", @"blush":@"f29e8e", @"soft green":@"6fc276", @"bright orange":@"ff5b00", @"lemon":@"fdff52", @"purple gray":@"866f85", @"acid green":@"8ffe09", @"pale lavender":@"eecffe", @"violet blue":@"510ac9", @"light forest green":@"4f9153", @"burnt red":@"9f2305", @"khaki green":@"728639", @"cerise":@"de0c62", @"faded purple":@"916e99", @"apricot":@"ffb16d", @"dark olive green":@"3c4d03", @"gray brown":@"7f7053", @"green gray":@"77926f", @"true blue":@"010fcc", @"pale violet":@"ceaefa", @"periwinkle blue":@"8f99fb", @"light sky blue":@"c6fcff", @"blurple":@"5539cc", @"green brown":@"544e03", @"blue green":@"017a79", @"bright teal":@"01f9c6", @"brownish yellow":@"c9b003", @"pea soup":@"929901", @"forest":@"0b5509", @"barney purple":@"a00498", @"ultramarine":@"2000b1", @"purplish":@"94568c", @"puke yellow":@"c2be0e", @"bluish gray":@"748b97", @"dark periwinkle":@"665fd1", @"dark lilac":@"9c6da5", @"reddish":@"c44240", @"light maroon":@"a24857", @"dusty purple":@"825f87", @"terra cotta":@"c9643b", @"avocado":@"90b134", @"marine blue":@"01386a", @"teal green":@"25a36f", @"slate gray":@"59656d", @"lighter green":@"75fd63", @"electric green":@"21fc0d", @"dusty blue":@"5a86ad", @"golden yellow":@"fec615", @"bright yellow":@"fffd01", @"light lavender":@"dfc5fe", @"umber":@"b26400", @"poop":@"7f5e00", @"dark peach":@"de7e5d", @"jungle green":@"048243", @"eggshell":@"ffffd4", @"denim":@"3b638c", @"yellow brown":@"b79400", @"dull purple":@"84597e", @"chocolate brown":@"411900", @"wine red":@"7b0323", @"neon blue":@"04d9ff", @"dirty green":@"667e2c", @"light tan":@"fbeeac", @"ice blue":@"d7fffe", @"cadet blue":@"4e7496", @"dark mauve":@"874c62", @"very light blue":@"d5ffff", @"gray purple":@"826d8c", @"pastel pink":@"ffbacd", @"very light green":@"d1ffbd", @"dark sky blue":@"448ee4", @"evergreen":@"05472a", @"dull pink":@"d5869d", @"aubergine":@"3d0734", @"mahogany":@"4a0100", @"reddish orange":@"f8481c", @"deep green":@"02590f", @"vomit green":@"89a203", @"purple pink":@"e03fd8", @"dusty pink":@"d58a94", @"faded green":@"7bb274", @"camo green":@"526525", @"pinky purple":@"c94cbe", @"pink purple":@"db4bda", @"brownish red":@"9e3623", @"dark rose":@"b5485d", @"mud":@"735c12", @"brownish":@"9c6d57", @"emerald green":@"028f1e", @"pale brown":@"b1916e", @"dull blue":@"49759c", @"burnt umber":@"a0450e", @"medium green":@"39ad48", @"clay":@"b66a50", @"light aqua":@"8cffdb", @"light olive green":@"a4be5c", @"brownish orange":@"cb7723", @"dark aqua":@"05696b", @"purple pink":@"ce5dae", @"dark salmon":@"c85a53", @"greenish gray":@"96ae8d", @"jade":@"1fa774", @"ugly green":@"7a9703", @"dark beige":@"ac9362", @"emerald":@"01a049", @"pale red":@"d9544d", @"light magenta":@"fa5ff7", @"sky":@"82cafc", @"light cyan":@"acfffc", @"yellow orange":@"fcb001", @"reddish purple":@"910951", @"reddish pink":@"fe2c54", @"orchid":@"c875c4", @"dirty yellow":@"cdc50a", @"orange red":@"fd411e", @"deep red":@"9a0200", @"orange brown":@"be6400", @"cobalt blue":@"030aa7", @"neon pink":@"fe019a", @"rose pink":@"f7879a", @"gray purple":@"887191", @"raspberry":@"b00149", @"aqua green":@"12e193", @"salmon pink":@"fe7b7c", @"tangerine":@"ff9408", @"brownish green":@"6a6e09", @"red brown":@"8b2e16", @"greenish brown":@"696112", @"pumpkin":@"e17701", @"pine green":@"0a481e", @"charcoal":@"343837", @"baby pink":@"ffb7ce", @"cornflower":@"6a79f7", @"blue violet":@"5d06e9", @"chocolate":@"3d1c02", @"gray green":@"82a67d", @"scarlet":@"be0119", @"green yellow":@"c9ff27", @"dark olive":@"373e02", @"sienna":@"a9561e", @"pastel purple":@"caa0ff", @"terra cotta":@"ca6641", @"aqua blue":@"02d8e9", @"sage green":@"88b378", @"blood red":@"980002", @"deep pink":@"cb0162", @"grass":@"5cac2d", @"moss":@"769958", @"pastel blue":@"a2bffe", @"bluish green":@"10a674", @"green blue":@"06b48b", @"dark tan":@"af884a", @"greenish blue":@"0b8b87", @"pale orange":@"ffa756", @"vomit":@"a2a415", @"forrest green":@"154406", @"dark lavender":@"856798", @"dark violet":@"34013f", @"purple blue":@"632de9", @"dark cyan":@"0a888a", @"olive drab":@"6f7632", @"pinkish":@"d46a7e", @"cobalt":@"1e488f", @"neon purple":@"bc13fe", @"light turquoise":@"7ef4cc", @"apple green":@"76cd26", @"dull green":@"74a662", @"wine":@"80013f", @"powder blue":@"b1d1fc", @"off white":@"ffffe4", @"electric blue":@"0652ff", @"dark turquoise":@"045c5a", @"blue purple":@"5729ce", @"azure":@"069af3", @"bright red":@"ff000d", @"pinkish red":@"f10c45", @"cornflower blue":@"5170d7", @"light olive":@"acbf69", @"grape":@"6c3461", @"gray blue":@"5e819d", @"purple blue":@"601ef9", @"yellowish green":@"b0dd16", @"greenish yellow":@"cdfd02", @"medium blue":@"2c6fbb", @"dusty rose":@"c0737a", @"light violet":@"d6b4fc", @"midnight blue":@"020035", @"bluish purple":@"703be7", @"red orange":@"fd3c06", @"dark magenta":@"960056", @"greenish":@"40a368", @"ocean blue":@"03719c", @"coral":@"fc5a50", @"cream":@"ffffc2", @"reddish brown":@"7f2b0a", @"burnt sienna":@"b04e0f", @"brick":@"a03623", @"sage":@"87ae73", @"gray green":@"789b73", @"white":@"ffffff", @"robin's egg blue":@"98eff9", @"moss green":@"658b38", @"steel blue":@"5a7d9a", @"eggplant":@"380835", @"light yellow":@"fffe7a", @"leaf green":@"5ca904", @"light gray":@"d8dcd6", @"puke":@"a5a502", @"pinkish purple":@"d648d7", @"sea blue":@"047495", @"pale purple":@"b790d4", @"slate blue":@"5b7c99", @"blue gray":@"607c8e", @"hunter green":@"0b4008", @"fuchsia":@"ed0dd9", @"crimson":@"8c000f", @"pale yellow":@"ffff84", @"ochre":@"bf9005", @"mustard yellow":@"d2bd0a", @"light red":@"ff474c", @"cerulean":@"0485d1", @"pale pink":@"ffcfdc", @"deep blue":@"040273", @"rust":@"a83c09", @"light teal":@"90e4c1", @"slate":@"516572", @"goldenrod":@"fac205", @"dark yellow":@"d5b60a", @"dark gray":@"363737", @"army green":@"4b5d16", @"gray blue":@"6b8ba4", @"sea foam":@"80f9ad", @"puce":@"a57e52", @"spring green":@"a9f971", @"dark orange":@"c65102", @"sand":@"e2ca76", @"pastel green":@"b0ff9d", @"mint":@"9ffeb0", @"light orange":@"fdaa48", @"bright pink":@"fe01b1", @"chartreuse":@"c1f80a", @"deep purple":@"36013f", @"dark brown":@"341c02", @"taupe":@"b9a281", @"pea green":@"8eab12", @"puke green":@"9aae07", @"kelly green":@"02ab2e", @"sea foam green":@"7af9ab", @"blue green":@"137e6d", @"khaki":@"aaa662", @"burgundy":@"610023", @"dark teal":@"014d4e", @"brick red":@"8f1402", @"royal purple":@"4b006e", @"plum":@"580f41", @"mint green":@"8fff9f", @"gold":@"dbb40c", @"baby blue":@"a2cffe", @"yellow green":@"c0fb2d", @"bright purple":@"be03fd", @"dark red":@"840000", @"pale blue":@"d0fefe", @"grass green":@"3f9b0b", @"navy":@"01153e", @"aquamarine":@"04d8b2", @"burnt orange":@"c04e01", @"neon green":@"0cff0c", @"bright blue":@"0165fc", @"rose":@"cf6275", @"light pink":@"ffd1df", @"mustard":@"ceb301", @"indigo":@"380282", @"lime":@"aaff32", @"sea green":@"53fca1", @"periwinkle":@"8e82fe", @"dark pink":@"cb416b", @"olive green":@"677a04", @"peach":@"ffb07c", @"pale green":@"c7fdb5", @"light brown":@"ad8150", @"hot pink":@"ff028d", @"black":@"000000", @"lilac":@"cea2fd", @"navy blue":@"001146", @"royal blue":@"0504aa", @"beige":@"e6daa6", @"salmon":@"ff796c", @"olive":@"6e750e", @"maroon":@"650021", @"bright green":@"01ff07", @"dark purple":@"35063e", @"mauve":@"ae7181", @"forest green":@"06470c", @"aqua":@"13eac9", @"cyan":@"00ffff", @"tan":@"d1b26f", @"dark blue":@"00035b", @"lavender":@"c79fef", @"turquoise":@"06c2ac", @"dark green":@"033500", @"violet":@"9a0eea", @"light purple":@"bf77f6", @"lime green":@"89fe05", @"gray":@"929591", @"sky blue":@"75bbfd", @"yellow":@"ffff14", @"magenta":@"c20078", @"light green":@"96f97b", @"orange":@"f97306", @"teal":@"029386", @"light blue":@"95d0fc", @"red":@"e50000", @"brown":@"653700", @"pink":@"ff81c0", @"blue":@"0343df", @"green":@"15b01a", @"purple":@"7e1e9c",};
    
    colorNameDictionaries = @{
                              @"Base" : baseDictionary,
                              @"Crayon" : crayonDictionary,
                              @"CSS" : cssDictionary,
                              @"System" : systemColorDictionary,
                              @"Wikipedia" : wikipediaColorDictionary,
                              @"Moroney": moroneyDictionary,
                              @"xkcd" : xkcdDictionary,
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
	float bestScore = MAXFLOAT;
    NSString *bestKey = nil;
    
    for (NSString *colorName in colorDictionary.allKeys)
    {
        NSString *colorHex = colorDictionary[colorName];
        UIColor *comparisonColor = [UIColor colorWithHexString:colorHex];
        if (!comparisonColor)
            continue;
        
        CGFloat score;
        score = [self distanceFrom:comparisonColor];
        if (score < bestScore)
        {
            bestScore = score;
            bestKey = colorName;
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

    // Even more limited
//     NSArray *baseColors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor yellowColor], [UIColor orangeColor], [UIColor purpleColor]];

    NSArray *baseColors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor]];

    NSArray *grayColors = @[[UIColor blackColor], [UIColor lightGrayColor], [UIColor grayColor], [UIColor darkGrayColor]];
    
    CGFloat bestScore = MAXFLOAT;
    UIColor *winner = nil;
    BOOL evaluateAsGray = self.colorfulness < 0.45f;
    
    NSArray *colors = evaluateAsGray ? grayColors : baseColors;
    
    for (UIColor *color in colors)
    {
        
        CGFloat score = evaluateAsGray ? [self distanceFrom:color] : [self hueDistanceFrom:color];
        
        if (score < bestScore)
        {
            bestScore = score;
            winner = color;
        }
    }

    
    return winner;
}

- (NSDictionary *) closestColors
{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    for (NSString *key in [UIColor availableColorDictionaries])
    {
        NSString *colorName = [self closestColorNameUsingDictionary:key];
        results[key] = colorName;
    }
    
    return results;
}
@end