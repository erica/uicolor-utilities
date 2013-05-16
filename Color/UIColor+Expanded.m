#import "UIColor+Expanded.h"

CGColorSpaceRef DeviceRGBSpace()
{
    static CGColorSpaceRef rgbSpace = NULL;
    if (rgbSpace == NULL)
        rgbSpace = CGColorSpaceCreateDeviceRGB();
    return rgbSpace;
}

CGColorSpaceRef DeviceGraySpace()
{
    static CGColorSpaceRef graySpace = NULL;
    if (graySpace == NULL)
        graySpace = CGColorSpaceCreateDeviceGray();
    return graySpace;
}

UIColor *RandomColor()
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

UIColor *InterpolateColors(UIColor *c1, UIColor *c2, CGFloat amt)
{
    CGFloat r = (c2.red * amt) + (c1.red * (1.0 - amt));
    CGFloat g = (c2.green * amt) + (c1.green * (1.0 - amt));
    CGFloat b = (c2.blue * amt) + (c1.blue * (1.0 - amt));
    CGFloat a = (c2.alpha * amt) + (c1.alpha * (1.0 - amt));
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@implementation UIColor (UIColor_Expanded)

// Generate a color wheel. You supply the size, e.g.
// UIImage *image = [UIColor colorWheelOfSize:500];

+ (UIImage *) colorWheelOfSize: (CGFloat) side border: (BOOL) useBorder
{
    UIBezierPath *path;
    CGSize size = CGSizeMake(side, side);
    CGPoint center = CGPointMake(side / 2, side / 2);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
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
        path.lineWidth = 4;
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

#pragma mark - CMYK Utility

+ (UIColor *) colorWithCyan: (CGFloat) c magenta: (CGFloat) m yellow: (CGFloat) y black: (CGFloat) k
{
    CGFloat r = (1.0f - c) * (1.0f - k);
    CGFloat g = (1.0f - m) * (1.0f - k);
    CGFloat b = (1.0f - y) * (1.0f - k);
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
}

- (void) toC: (CGFloat *) cyan toM: (CGFloat *) magenta toY: (CGFloat *) yellow toK: (CGFloat *) black
{
    CGFloat r = self.red;
    CGFloat g = self.green;
    CGFloat b = self.blue;
    
    CGFloat k = 1.0f - fmaxf(fmaxf(r, g), b);
    CGFloat dK = 1.0f - k;
    
    CGFloat c = (1.0f - (r + k)) / dK;
    CGFloat m = (1.0f - (g + k)) / dK;
    CGFloat y = (1.0f - (b + k)) / dK;
    
    if (cyan) *cyan = c;
    if (magenta) *magenta = m;
    if (yellow) *yellow = y;
    if (black) *black = k;
}

- (CGFloat) cyanChannel
{
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -cyanChannel");
    CGFloat c = 0.0f;
    [self toC:&c toM:NULL toY:NULL toK:NULL];
    return c;
}

- (CGFloat) magentaChannel
{
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -magentaChannel");
    CGFloat m = 0.0f;
    [self toC:NULL toM:&m toY:NULL toK:NULL];
    return m;
}

- (CGFloat) yellowChannel
{
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -yellowChannel");
    CGFloat y = 0.0f;
    [self toC:NULL toM:NULL toY:&y toK:NULL];
    return y;
}

- (CGFloat) blackChannel
{
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -blackChannel");
    CGFloat k = 0.0f;
    [self toC:NULL toM:NULL toY:NULL toK:&k];
    return k;
}

- (NSArray *) cmyk
{
    CGFloat c = 0.0f;
    CGFloat m = 0.0f;
    CGFloat y = 0.0f;
    CGFloat k = 0.0f;
    [self toC:&c toM:&m toY:&y toK:&k];
    return @[@(c), @(m), @(y), @(k)];
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
        h /= 60.0f;                                        // h is now in [0, 6)
        
        int i = floorf(h);                                // largest integer <= h
        CGFloat f = h - i;                                // fractional part of h
        CGFloat p = v * (1 - s);
        CGFloat q = v * (1 - (s * f));
        CGFloat t = v * (1 - (s * (1 - f)));
        
        switch (i)
        {
            case 0:    r = v; g = t; b = p;    break;
            case 1:    r = q; g = v; b = p;    break;
            case 2:    r = p; g = v; b = t;    break;
            case 3:    r = p; g = q; b = v;    break;
            case 4:    r = t; g = p; b = v;    break;
            case 5:    r = v; g = p; b = q;    break;
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
    
    CGFloat max = fmax(r, fmax(g, b));
    CGFloat min = fmin(r, fmin(g, b));
    
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
        CGFloat rc = (max - r) / (max - min);        // Distance of color from red
        CGFloat gc = (max - g) / (max - min);        // Distance of color from green
        CGFloat bc = (max - b) / (max - min);        // Distance of color from blue
        
        if (r == max) h = bc - gc;                    // resulting color between yellow and magenta
        else if (g == max) h = 2 + rc - bc;            // resulting color between cyan and yellow
        else /* if (b == max) */ h = 4 + gc - rc;    // resulting color between magenta and cyan
        
        h *= 60.0f;                                    // Convert to degrees
        if (h < 0.0f) h += 360.0f;                    // Make non-negative
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
    
    if (y) *y = fmin(1.0, fmax(0, *y));
    if (u) *u = fmin(1.0, fmax(0, *u));
    if (v) *v = fmin(1.0, fmax(0, *v));
}

void YUV2RGB_f(CGFloat y, CGFloat u, CGFloat v, CGFloat *r, CGFloat *g, CGFloat *b)
{
    CGFloat    Y = y;
    CGFloat    U = u - 0.5;
    CGFloat    V = v - 0.5;
    
    if (r) *r = ( Y + 1.403f * V);
    if (g) *g = ( Y - 0.344f * U - 0.714f * V);
    if (b) *b = ( Y + 1.770f * U);
    
    if (r) *r = fmin(1.0, fmax(0, *r));
    if (g) *g = fmin(1.0, fmax(0, *g));
    if (b) *b = fmin(1.0, fmax(0, *b));
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

- (CGFloat) premultipliedRed { return self.red * self.alpha; }
- (CGFloat) premultipliedGreen { return self.green * self.alpha; }
- (CGFloat) premultipliedBlue {return self.blue * self.alpha; }

- (Byte) redByte { return MAKEBYTE(self.red); }
- (Byte) greenByte { return MAKEBYTE(self.green); }
- (Byte) blueByte { return MAKEBYTE(self.blue); }
- (Byte) alphaByte { return MAKEBYTE(self.alpha); }
- (Byte) whiteByte { return MAKEBYTE(self.white); };

- (NSData *) colorBytes
{
    Byte bytes[4] = {self.alphaByte, self.redByte, self.greenByte, self.blueByte};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    return data;
}

- (NSData *) premultipledColorBytes
{
    Byte bytes[4] = {MAKEBYTE(self.alpha), MAKEBYTE(self.premultipliedRed), MAKEBYTE(self.premultipliedGreen), MAKEBYTE(self.premultipliedBlue)};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    return data;
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
    CGFloat d1 = fabs(self.red - self.green);
    CGFloat d2 = fabs(self.green - self.blue);
    CGFloat d3 = fabs(self.blue - self.red);
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
    
    hue = fmax(0.0, hue);
    if (hue < 0.5f)
        hue = fmin(0.5f, hue);
    else
        hue = fmax(0.5f, hue);
    
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
    b = fmin(1.0f, b);
    b = fmax(0.0f, b);
    
    return [UIColor colorWithHue:self.hue saturation:self.saturation brightness:b alpha:self.alpha];
}

// Return more saturated
- (UIColor *) adjustSaturation: (CGFloat) delta
{
    CGFloat s = self.saturation;
    s += delta;
    s = fmin(1.0f, s);
    s = fmax(0.0f, s);
    
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
    
    return fabs(dH);
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
    
    return [UIColor colorWithRed:fmax(0.0, fmin(1.0, r * red))
                           green:fmax(0.0, fmin(1.0, g * green))
                            blue:fmax(0.0, fmin(1.0, b * blue))
                           alpha:fmax(0.0, fmin(1.0, a * alpha))];
}

- (UIColor *) colorByAddingRed: (CGFloat) red
                         green: (CGFloat) green
                          blue: (CGFloat) blue
                         alpha: (CGFloat) alpha
{
    NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r, g, b, a;
    if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
    
    return [UIColor colorWithRed:fmax(0.0, fmin(1.0, r + red))
                           green:fmax(0.0, fmin(1.0, g + green))
                            blue:fmax(0.0, fmin(1.0, b + blue))
                           alpha:fmax(0.0, fmin(1.0, a + alpha))];
}

- (UIColor *) colorByLighteningToRed: (CGFloat) red
                               green: (CGFloat) green
                                blue: (CGFloat) blue
                               alpha: (CGFloat) alpha
{
    NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r, g, b, a;
    if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
    
    return [UIColor colorWithRed:fmax(r, red)
                           green:fmax(g, green)
                            blue:fmax(b, blue)
                           alpha:fmax(a, alpha)];
}

- (UIColor *) colorByDarkeningToRed: (CGFloat) red
                              green: (CGFloat) green
                               blue: (CGFloat) blue
                              alpha: (CGFloat) alpha
{
    NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r, g, b, a;
    if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
    
    return [UIColor colorWithRed:fmin(r, red)
                           green:fmin(g, green)
                            blue:fmin(b, blue)
                           alpha:fmin(a, alpha)];
}

- (UIColor *) colorByMultiplyingBy: (CGFloat) f
{
    // Multiply by 1 alpha
    return [self colorByMultiplyingByRed:f green:f blue:f alpha:self.alpha];
}

- (UIColor *) colorByAdding: (CGFloat) f
{
    // Add 0 alpha
    return [self colorByMultiplyingByRed:f green:f blue:f alpha:self.alpha];
}

- (UIColor *) colorByLighteningTo: (CGFloat) f
{
    // Alpha is ignored
    return [self colorByLighteningToRed:f green:f blue:f alpha:self.alpha];
}

- (UIColor *) colorByDarkeningTo: (CGFloat) f
{
    // Alpha is ignored
    return [self colorByDarkeningToRed:f green:f blue:f alpha:self.alpha];
}

- (UIColor *) colorByMultiplyingByColor: (UIColor *) color
{
    NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r, g, b, a;
    if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
    
    return [self colorByMultiplyingByRed:r green:g blue:b alpha:self.alpha];
}

- (UIColor *) colorByAddingColor: (UIColor *) color
{
    NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use arithmetic operations");
    
    CGFloat r, g, b, a;
    if (![self getRed: &r green: &g blue: &b alpha: &a]) return nil;
    
    return [self colorByAddingRed:r green:g blue:b alpha:self.alpha];
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
    
    return [self colorByDarkeningToRed:r green:g blue:b alpha:self.alpha];
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
- (UIColor *) colorWithBrightness: (CGFloat) brightness
{
    return [UIColor colorWithHue:self.hue saturation:self.saturation brightness:brightness alpha:self.alpha];
}

- (UIColor *) colorWithSaturation: (CGFloat) saturation
{
    return [UIColor colorWithHue:self.hue saturation:saturation brightness:self.brightness alpha:self.alpha];
}

- (UIColor *) colorWithHue: (CGFloat) hue
{
    return [UIColor colorWithHue: hue saturation:self.saturation brightness:self.brightness alpha:self.alpha];
}

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
    CGFloat startingHue = fmin(self.hue, secondColor.hue);
    CGFloat distance = fabs(self.hue - secondColor.hue);
    if (distance > 0.5)
    {
        distance = 1 - distance;
        startingHue = fmax(self.hue, secondColor.hue);
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
    if ((H == NULL) || (S == NULL) || (P == NULL))
    {
        // It is too much of a pain to check the referencing for each of these bits.
        fprintf(stderr, "Sorry. Please call RGBtoHSP with non-NULL H, S, and P.  Bailing.\n");
        return;
    }
    
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
    
    if ((R == NULL) || (G == NULL) || (B == NULL))
    {
        // It is too much of a pain to check the referencing for each of these bits.
        fprintf(stderr, "Sorry. Please call with HSPtoRGB with non-NULL R, G, and B.  Bailing.\n");
        return;
    }

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
    CGFloat h = 0;
    CGFloat s = 0;
    CGFloat p = 0;
    
    CGFloat r = self.red;
    CGFloat g = self.green;
    CGFloat b = self.blue;
    
    RGBtoHSP(r, g, b, &h, &s, &p);
    
    return p;
}

#pragma mark - String Support
- (UInt32) rgbHex
{
    NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use -rgbHex");
    
    CGFloat r, g, b, a;
    if (![self getRed: &r green: &g blue: &b alpha: &a])
        return 0.0f;
    
    r = fmin(fmax(r, 0.0f), 1.0f);
    g = fmin(fmax(g, 0.0f), 1.0f);
    b = fmin(fmax(b, 0.0f), 1.0f);
    
    return (((int)roundf(r * 0xFF)) << 16) | (((int)roundf(g * 0xFF)) << 8) | (((int)roundf(b * 0xFF)));
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
            result = [NSString stringWithFormat:@"%02X%02X%02X", self.redByte, self.greenByte, self.blueByte];
            break;
        case kCGColorSpaceModelMonochrome:
            result = [NSString stringWithFormat:@"%02X%02X%02X", self.whiteByte, self.whiteByte, self.whiteByte];
            break;
        default:
            result = nil;
    }
    return result;
}

- (NSString *) valueString
{
    return [NSString stringWithFormat:@"%@ [%d %d %d] (%@): RGB:(%f, %f, %f) HSB:(%f, %f, %f) CMYK:(%@) alpha: %f",
            self.hexStringValue,
            self.redByte, self.greenByte, self.blueByte,
            self.closestColorName,
            self.red, self.green, self.blue,
            self.hue, self.saturation, self.brightness,
            [self.cmyk componentsJoinedByString:@", "],
            self.alpha];
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
        red = 0xFF;
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
        blue = 0xFF;
    else if (temperature <= 19)
        blue = 0;
    else
    {
        blue = temperature - 10;
        blue = 138.5177312231 * log(blue) - 305.0447927307;
    }
    
    
    red = fmax(red, 0);
    red = fmin(red, 0xFF);
    green = fmax(green, 0);
    green = fmin(green, 0xFF);
    blue = fmax(blue, 0);
    blue = fmin(blue, 0xFF);
    
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
    NSDictionary *crayonDictionary = @{@"Almond":@"EED9C4", @"Antique Brass":@"C88A65", @"Apricot":@"FDD5B1", @"Aquamarine":@"71D9E2", @"Asparagus":@"7BA05B", @"Atomic Tangerine":@"FF9966", @"Banana Mania":@"FBE7B2", @"Beaver":@"926F5B", @"Bittersweet":@"FE6F5E", @"Black":@"000000", @"Blizzard Blue":@"A3E3ED", @"Blue":@"0066FF", @"Blue Bell":@"9999CC", @"Blue Green":@"0095B6", @"Blue Violet":@"6456B7", @"Brick Red":@"C62D42", @"Brink Pink":@"FB607F", @"Brown":@"AF593E", @"Burnt Orange":@"FF7034", @"Burnt Sienna":@"E97451", @"Cadet Blue":@"A9B2C3", @"Canary":@"FFFF99", @"Caribbean Green":@"00CC99", @"Carnation Pink":@"FFA6C9", @"Cerise":@"DA3287", @"Cerulean":@"02A4D3", @"Chestnut":@"B94E48", @"Copper":@"DA8A67", @"Cornflower":@"93CCEA", @"Cotton Candy":@"FFB7D5", @"Cranberry":@"DB5079", @"Dandelion":@"FED85D", @"Denim":@"1560BD", @"Desert Sand":@"EDC9AF", @"Eggplant":@"614051", @"Electric Lime":@"CCFF00", @"Fern":@"63B76C", @"Flesh":@"FFCBA4", @"Forest Green":@"5FA777", @"Fuchsia":@"C154C1", @"Fuzzy Wuzzy Brown":@"C45655", @"Gold":@"E6BE8A", @"Goldenrod":@"FCD667", @"Granny Smith Apple":@"9DE093", @"Gray":@"8B8680", @"Green":@"01A368", @"Green Yellow":@"F1E788", @"Happy Ever After":@"6CDA37", @"Hot Magenta":@"FF00CC", @"Inch Worm":@"B0E313", @"Indigo":@"4F69C6", @"Jazzberry Jam":@"A50B5E", @"Jungle Green":@"29AB87", @"Laser Lemon":@"FFFF66", @"Lavender":@"FBAED2", @"Macaroni And Cheese":@"FFB97B", @"Magenta":@"F653A6", @"Magic Mint":@"AAF0D1", @"Mahogany":@"CA3435", @"Manatee":@"8D90A1", @"Mango Tango":@"E77200", @"Maroon":@"C32148", @"Mauvelous":@"F091A9", @"Melon":@"FEBAAD", @"Midnight Blue":@"003366", @"Mountain Meadow":@"1AB385", @"Mulberry":@"C54B8C", @"Navy Blue":@"0066CC", @"Neon Carrot":@"FF9933", @"Olive Green":@"B5B35C", @"Orange":@"FF681F", @"Orchid":@"E29CD2", @"Outer Space":@"2D383A", @"Outrageous Orange":@"FF6037", @"Pacific Blue":@"009DC4", @"Periwinkle":@"C3CDE6", @"Pig Pink":@"FDD7E4", @"Pine Green":@"01796F", @"Pink Flamingo":@"FF66FF", @"Plum":@"843179", @"Purple Heart":@"652DC1", @"Purple Mountain's Majesty":@"9678B6", @"Radical Red":@"FF355E", @"Raw Sienna":@"D27D46", @"Razzle Dazzle Rose":@"FF33CC", @"Razzmatazz":@"E30B5C", @"Red":@"ED0A3F", @"Red Orange":@"FF3F34", @"Red Violet":@"BB3385", @"Robin's Egg Blue":@"00CCCC", @"Royal Purple":@"6B3FA0", @"Salmon":@"FF91A4", @"Scarlet":@"FD0E35", @"Screamin' Green":@"66FF66", @"Sea Green":@"93DFB8", @"Sepia":@"9E5B40", @"Shadow":@"837050", @"Shamrock":@"33CC99", @"Shocking Pink":@"FF6FFF", @"Silver":@"C9C0BB", @"Sky Blue":@"76D7EA", @"Spring Green":@"ECEBBD", @"Sunglow":@"FFCC33", @"Sunset Orange":@"FE4C40", @"Tan":@"FA9D5A", @"Tickle Me Pink":@"FC80A5", @"Timberwolf":@"D9D6CF", @"Tropical Rain Forest":@"00755E", @"Tumbleweed":@"DEA681", @"Turquoise Blue":@"6CDAE7", @"Ultra Red":@"FD5B78", @"Violet (Purple)":@"8359A3", @"Violet Red":@"F7468A", @"Vivid Tangerine":@"FF9980", @"Vivid Violet":@"803790", @"White":@"FFFFFF", @"Wild Blue Yonder":@"7A89B8", @"Wild Strawberry":@"FF3399", @"Wisteria":@"C9A0DC", @"Yellow":@"FBE870", @"Yellow Green":@"C5E17A", @"Yellow Orange":@"FFAE42", };
    
    /*
     Database of color names and hex rgb values, derived
     from the css 3 color spec:
     http://www.w3.org/TR/css3-color/
     */
    NSDictionary *cssDictionary = @{@"lightseagreen":@"20b2aa", @"floralwhite":@"fffaf0", @"lightgray":@"d3d3d3", @"darkgoldenrod":@"b8860b", @"paleturquoise":@"afeeee", @"goldenrod":@"daa520", @"skyblue":@"87ceeb", @"indianred":@"cd5c5c", @"darkgray":@"a9a9a9", @"khaki":@"f0e68c", @"blue":@"0000ff", @"darkred":@"8b0000", @"lightyellow":@"ffffe0", @"midnightblue":@"191970", @"chartreuse":@"7fff00", @"lightsteelblue":@"b0c4de", @"slateblue":@"6a5acd", @"firebrick":@"b22222", @"moccasin":@"ffe4b5", @"salmon":@"fa8072", @"sienna":@"a0522d", @"slategray":@"708090", @"teal":@"008080", @"lightsalmon":@"ffa07a", @"pink":@"ffc0cb", @"burlywood":@"deb887", @"gold":@"ffd700", @"springgreen":@"00ff7f", @"lightcoral":@"f08080", @"black":@"000000", @"blueviolet":@"8a2be2", @"chocolate":@"d2691e", @"aqua":@"00ffff", @"darkviolet":@"9400d3", @"indigo":@"4b0082", @"darkcyan":@"008b8b", @"orange":@"ffa500", @"antiquewhite":@"faebd7", @"peru":@"cd853f", @"silver":@"c0c0c0", @"purple":@"800080", @"saddlebrown":@"8b4513", @"lawngreen":@"7cfc00", @"dodgerblue":@"1e90ff", @"lime":@"00ff00", @"linen":@"faf0e6", @"lightblue":@"add8e6", @"darkslategray":@"2f4f4f", @"lightskyblue":@"87cefa", @"mintcream":@"f5fffa", @"olive":@"808000", @"hotpink":@"ff69b4", @"papayawhip":@"ffefd5", @"mediumseagreen":@"3cb371", @"mediumspringgreen":@"00fa9a", @"cornflowerblue":@"6495ed", @"plum":@"dda0dd", @"seagreen":@"2e8b57", @"palevioletred":@"db7093", @"bisque":@"ffe4c4", @"beige":@"f5f5dc", @"darkorchid":@"9932cc", @"royalblue":@"4169e1", @"darkolivegreen":@"556b2f", @"darkmagenta":@"8b008b", @"orange red":@"ff4500", @"lavender":@"e6e6fa", @"fuchsia":@"ff00ff", @"darkseagreen":@"8fbc8f", @"lavenderblush":@"fff0f5", @"wheat":@"f5deb3", @"steelblue":@"4682b4", @"lightgoldenrodyellow":@"fafad2", @"lightcyan":@"e0ffff", @"mediumaquamarine":@"66cdaa", @"turquoise":@"40e0d0", @"dark blue":@"00008b", @"darkorange":@"ff8c00", @"brown":@"a52a2a", @"dimgray":@"696969", @"deeppink":@"ff1493", @"powderblue":@"b0e0e6", @"red":@"ff0000", @"darkgreen":@"006400", @"ghostwhite":@"f8f8ff", @"white":@"ffffff", @"navajowhite":@"ffdead", @"navy":@"000080", @"ivory":@"fffff0", @"palegreen":@"98fb98", @"whitesmoke":@"f5f5f5", @"gainsboro":@"dcdcdc", @"mediumslateblue":@"7b68ee", @"olivedrab":@"6b8e23", @"mediumpurple":@"9370db", @"darkslateblue":@"483d8b", @"blanchedalmond":@"ffebcd", @"darkkhaki":@"bdb76b", @"green":@"008000", @"limegreen":@"32cd32", @"snow":@"fffafa", @"tomato":@"ff6347", @"darkturquoise":@"00ced1", @"orchid":@"da70d6", @"yellow":@"ffff00", @"green yellow":@"adff2f", @"azure":@"f0ffff", @"mistyrose":@"ffe4e1", @"cadetblue":@"5f9ea0", @"oldlace":@"fdf5e6", @"gray":@"808080", @"honeydew":@"f0fff0", @"peachpuff":@"ffdab9", @"tan":@"d2b48c", @"thistle":@"d8bfd8", @"palegoldenrod":@"eee8aa", @"mediumorchid":@"ba55d3", @"rosybrown":@"bc8f8f", @"mediumturquoise":@"48d1cc", @"lemonchiffon":@"fffacd", @"maroon":@"800000", @"mediumvioletred":@"c71585", @"violet":@"ee82ee", @"yellow green":@"9acd32", @"coral":@"ff7f50", @"lightgreen":@"90ee90", @"cornsilk":@"fff8dc", @"mediumblue":@"0000cd", @"aliceblue":@"f0f8ff", @"forestgreen":@"228b22", @"aquamarine":@"7fffd4", @"deepskyblue":@"00bfff", @"lightslategray":@"778899", @"darksalmon":@"e9967a", @"crimson":@"dc143c", @"sandybrown":@"f4a460", @"lightpink":@"ffb6c1", @"seashell":@"fff5ee"};
    
    /*
     Similar to CSS but more readable
     */
    NSDictionary *baseDictionary = @{@"Alice Blue":@"F0F8FF", @"Antique White":@"FAEBD7", @"Aqua":@"00FFFF", @"Aquamarine":@"7FFFD4", @"Azure":@"F0FFFF", @"Beige":@"F5F5DC", @"Bisque":@"FFE4C4", @"Black":@"000000", @"Blanched Almond":@"FFEBCD", @"Blue":@"0000FF", @"Blue Violet":@"8A2BE2", @"Brown":@"A52A2A", @"Burlywood":@"DEB887", @"Cadet Blue":@"5F9EA0", @"Chartreuse":@"7FFF00", @"Chocolate":@"D2691E", @"Coral":@"FF7F50", @"Cornflower":@"6495ED", @"Cornsilk":@"FFF8DC", @"Crimson":@"DC143C", @"Dark Blue":@"00008B", @"Dark Cyan":@"008B8B", @"Dark Goldenrod":@"B8860B", @"Dark Gray":@"A9A9A9", @"Dark Green":@"006400", @"Dark Khaki":@"BDB76B", @"Dark Magenta":@"8B008B", @"Dark Olive Green":@"556B2F", @"Dark Orange":@"FF8C00", @"Dark Orchid":@"9932CC", @"Dark Red":@"8B0000", @"Dark Salmon":@"E9967A", @"Dark Sea Green":@"8FBC8F", @"Dark Slate Blue":@"483D8B", @"Dark Slate Gray":@"2F4F4F", @"Dark Turquoise":@"00CED1", @"Dark Violet":@"9400D3", @"Deep Pink":@"FF1493", @"Deep Sky Blue":@"00BFFF", @"Dim Gray":@"696969", @"Dodger Blue":@"1E90FF", @"Firebrick":@"B22222", @"Floral White":@"FFFAF0", @"Forest Green":@"228B22", @"Fuchsia":@"FF00FF", @"Gainsboro":@"DCDCDC", @"Ghost White":@"F8F8FF", @"Gold":@"FFD700", @"Goldenrod":@"DAA520", @"Gray (W3C)":@"808080", @"Gray (X11)":@"BEBEBE", @"Green (W3C)":@"008000", @"Green (X11)":@"00FF00", @"Green Yellow":@"ADFF2F", @"Honeydew":@"F0FFF0", @"Hot Pink":@"FF69B4", @"Indian Red":@"CD5C5C", @"Indigo":@"4B0082", @"Ivory":@"FFFFF0", @"Khaki":@"F0E68C", @"Lavender":@"E6E6FA", @"Lavender Blush":@"FFF0F5", @"Lawn Green":@"7CFC00", @"Lemon Chiffon":@"FFFACD", @"Light Blue":@"ADD8E6", @"Light Coral":@"F08080", @"Light Cyan":@"E0FFFF", @"Light Goldenrod":@"FAFAD2", @"Light Gray":@"D3D3D3", @"Light Green":@"90EE90", @"Light Pink":@"FFB6C1", @"Light Salmon":@"FFA07A", @"Light Sea Green":@"20B2AA", @"Light Sky Blue":@"87CEFA", @"Light Slate Gray":@"778899", @"Light Steel Blue":@"B0C4DE", @"Light Yellow":@"FFFFE0", @"Lime Green":@"32CD32", @"Linen":@"FAF0E6", @"Maroon (W3C)":@"7F0000", @"Maroon (X11)":@"B03060", @"Medium Aquamarine":@"66CDAA", @"Medium Blue":@"0000CD", @"Medium Orchid":@"BA55D3", @"Medium Purple":@"9370DB", @"Medium Sea Green":@"3CB371", @"Medium Slate Blue":@"7B68EE", @"Medium Spring Green":@"00FA9A", @"Medium Turquoise":@"48D1CC", @"Medium Violet Red":@"C71585", @"Midnight Blue":@"191970", @"Mint Cream":@"F5FFFA", @"Misty Rose":@"FFE4E1", @"Moccasin":@"FFE4B5", @"Navajo White":@"FFDEAD", @"Navy":@"000080", @"Old Lace":@"FDF5E6", @"Olive":@"808000", @"Olive Drab":@"6B8E23", @"Orange":@"FFA500", @"Orange Red":@"FF4500", @"Orchid":@"DA70D6", @"Pale Goldenrod":@"EEE8AA", @"Pale Green":@"98FB98", @"Pale Turquoise":@"AFEEEE", @"Pale Violet Red":@"DB7093", @"Papaya Whip":@"FFEFD5", @"Peach Puff":@"FFDAB9", @"Peru":@"CD853F", @"Pink":@"FFC0CB", @"Plum":@"DDA0DD", @"Powder Blue":@"B0E0E6", @"Purple (W3C)":@"7F007F", @"Purple (X11)":@"A020F0", @"Red":@"FF0000", @"Rosy Brown":@"BC8F8F", @"Royal Blue":@"4169E1", @"Saddle Brown":@"8B4513", @"Salmon":@"FA8072", @"Sandy Brown":@"F4A460", @"Sea Green":@"2E8B57", @"Seashell":@"FFF5EE", @"Sienna":@"A0522D", @"Silver (W3C)":@"C0C0C0", @"Sky Blue":@"87CEEB", @"Slate Blue":@"6A5ACD", @"Slate Gray":@"708090", @"Snow":@"FFFAFA", @"Spring Green":@"00FF7F", @"Steel Blue":@"4682B4", @"Tan":@"D2B48C", @"Teal":@"008080", @"Thistle":@"D8BFD8", @"Tomato":@"FF6347", @"Turquoise":@"40E0D0", @"Violet":@"EE82EE", @"Wheat":@"F5DEB3", @"White":@"FFFFFF", @"White Smoke":@"F5F5F5", @"Yellow":@"FFFF00", @"Yellow Green":@"9ACD32", };
    
    NSDictionary *systemColorDictionary = @{@"Black":@"000000", @"Dark Gray":@"555555", @"Light Gray":@"AAAAAA", @"White":@"FFFFFF", @"Gray":@"7F7F7F", @"Red":@"FF0000", @"Green":@"00FF00", @"Blue":@"0000FF", @"Cyan":@"00FFFF", @"Yellow":@"FFFF00", @"Magenta":@"FF00FF", @"Orange":@"FF7F00", @"Purple":@"7F007F", @"Brown":@"996633"};
    
    // See: http://en.wikipedia.org/wiki/List_of_colors:_A-M
    // and: http://en.wikipedia.org/wiki/List_of_colors:_N-Z
    NSDictionary *wikipediaColorDictionary = @{@"Aero":@"7CB9E8", @"Aero Blue":@"C9FFE5", @"African Violet":@"B284BE", @"Air Force Blue (Raf)":@"5D8AA8", @"Air Force Blue (Usaf)":@"00308F", @"Air Superiority Blue":@"72A0C1", @"Alabama Crimson":@"A32638", @"Alice Blue":@"F0F8FF", @"Alizarin Crimson":@"E32636", @"Alloy Orange":@"C46210", @"Almond":@"EFDECD", @"Amaranth":@"E52B50", @"Amazon":@"3B7A57", @"Amber":@"FFBF00", @"American Rose":@"FF033E", @"Amethyst":@"9966CC", @"Android Green":@"A4C639", @"Anti-Flash White":@"F2F3F4", @"Antique Brass":@"CD9575", @"Antique Bronze":@"665D1E", @"Antique Fuchsia":@"915C83", @"Antique Ruby":@"841B2D", @"Antique White":@"FAEBD7", @"Ao (English)":@"008000", @"Apple Green":@"8DB600", @"Apricot":@"FBCEB1", @"Aqua":@"00FFFF", @"Aquamarine":@"7FFFD4", @"Army Green":@"4B5320", @"Arsenic":@"3B444B", @"Arylide Yellow":@"E9D66B", @"Ash Gray":@"B2BEB5", @"Asparagus":@"87A96B", @"Atomic Tangerine":@"FF9966", @"Auburn":@"A52A2A", @"Aureolin":@"FDEE00", @"Aurometalsaurus":@"6E7F80", @"Avocado":@"568203", @"Azure":@"007FFF", @"Azure Mist/Web":@"F0FFFF", @"B'dazzled Blue":@"2E5894", @"Baby Blue":@"89CFF0", @"Baby Blue Eyes":@"A1CAF1", @"Baby Pink":@"F4C2C2", @"Baby Powder":@"FEFEFA", @"Baker-Miller Pink":@"FF91AF", @"Ball Blue":@"21ABCD", @"Banana Mania":@"FAE7B5", @"Banana Yellow":@"FFE135", @"Barbie Pink":@"E0218A", @"Barn Red":@"7C0A02", @"Battleship Gray":@"848482", @"Bazaar":@"98777B", @"Beau Blue":@"BCD4E6", @"Beaver":@"9F8170", @"Beige":@"F5F5DC", @"Big Dip O’ruby":@"9C2542", @"Bisque":@"FFE4C4", @"Bistre":@"3D2B1F", @"Bistre Brown":@"967117", @"Bitter Lemon":@"CAE00D", @"Bitter Lime":@"BFFF00", @"Bittersweet":@"FE6F5E", @"Bittersweet Shimmer":@"BF4F51", @"Black":@"000000", @"Black Bean":@"3D0C02", @"Black Leather Jacket":@"253529", @"Black Olive":@"3B3C36", @"Blanched Almond":@"FFEBCD", @"Blast-Off Bronze":@"A57164", @"Bleu De France":@"318CE7", @"Blizzard Blue":@"ACE5EE", @"Blond":@"FAF0BE", @"Blue":@"0000FF", @"Blue (Crayola)":@"1F75FE", @"Blue (Munsell)":@"0093AF", @"Blue (Ncs)":@"0087BD", @"Blue (Ryb)":@"0247FE", @"Blue (Pigment)":@"333399", @"Blue Bell":@"A2A2D0", @"Blue Sapphire":@"126180", @"Blue-Gray":@"6699CC", @"Blue-Green":@"0D98BA", @"Blue-Violet":@"8A2BE2", @"Blueberry":@"4F86F7", @"Bluebonnet":@"1C1CF0", @"Blush":@"DE5D83", @"Bole":@"79443B", @"Bondi Blue":@"0095B6", @"Bone":@"E3DAC9", @"Boston University Red":@"CC0000", @"Bottle Green":@"006A4E", @"Boysenberry":@"873260", @"Brandeis Blue":@"0070FF", @"Brass":@"B5A642", @"Brick Red":@"CB4154", @"Bright Cerulean":@"1DACD6", @"Bright Green":@"66FF00", @"Bright Lavender":@"BF94E4", @"Bright Maroon":@"C32148", @"Bright Pink":@"FF007F", @"Bright Turquoise":@"08E8DE", @"Bright Ube":@"D19FE8", @"Brilliant Lavender":@"F4BBFF", @"Brilliant Rose":@"FF55A3", @"Brink Pink":@"FB607F", @"British Racing Green":@"004225", @"Bronze":@"CD7F32", @"Bronze Yellow":@"737000", @"Brown (Traditional)":@"964B00", @"Brown (Web)":@"A52A2A", @"Brown-Nose":@"6B4423", @"Brunswick Green":@"1B4D3E", @"Bubble Gum":@"FFC1CC", @"Bubbles":@"E7FEFF", @"Buff":@"F0DC82", @"Bulgarian Rose":@"480607", @"Burgundy":@"800020", @"Burlywood":@"DEB887", @"Burnt Orange":@"CC5500", @"Burnt Sienna":@"E97451", @"Burnt Umber":@"8A3324", @"Byzantine":@"BD33A4", @"Byzantium":@"702963", @"Cg Blue":@"007AA5", @"Cg Red":@"E03C31", @"Cadet":@"536872", @"Cadet Blue":@"5F9EA0", @"Cadet Gray":@"91A3B0", @"Cadmium Green":@"006B3C", @"Cadmium Orange":@"ED872D", @"Cadmium Red":@"E30022", @"Cadmium Yellow":@"FFF600", @"Café Au Lait":@"A67B5B", @"Café Noir":@"4B3621", @"Cal Poly Green":@"1E4D2B", @"Cambridge Blue":@"A3C1AD", @"Camel":@"C19A6B", @"Cameo Pink":@"EFBBCC", @"Camouflage Green":@"78866B", @"Canary Yellow":@"FFEF00", @"Candy Apple Red":@"FF0800", @"Candy Pink":@"E4717A", @"Capri":@"00BFFF", @"Caput Mortuum":@"592720", @"Cardinal":@"C41E3A", @"Caribbean Green":@"00CC99", @"Carmine":@"960018", @"Carmine (M&P)":@"D70040", @"Carmine Pink":@"EB4C42", @"Carmine Red":@"FF0038", @"Carnation Pink":@"FFA6C9", @"Carnelian":@"B31B1B", @"Carolina Blue":@"99BADD", @"Carrot Orange":@"ED9121", @"Castleton Green":@"00563F", @"Catalina Blue":@"062A78", @"Catawba":@"703642", @"Cedar Chest":@"C95A49", @"Ceil":@"92A1CF", @"Celadon":@"ACE1AF", @"Celadon Blue":@"007BA7", @"Celadon Green":@"2F847C", @"Celeste (Colour)":@"B2FFFF", @"Celestial Blue":@"4997D0", @"Cerise":@"DE3163", @"Cerise Pink":@"EC3B83", @"Cerulean":@"007BA7", @"Cerulean Blue":@"2A52BE", @"Cerulean Frost":@"6D9BC3", @"Chamoisee":@"A0785A", @"Champagne":@"F7E7CE", @"Charcoal":@"36454F", @"Charleston Green":@"232B2B", @"Charm Pink":@"E68FAC", @"Chartreuse (Traditional)":@"DFFF00", @"Chartreuse (Web)":@"7FFF00", @"Cherry":@"DE3163", @"Cherry Blossom Pink":@"FFB7C5", @"Chestnut":@"954535", @"China Pink":@"DE6FA1", @"China Rose":@"A8516E", @"Chinese Red":@"AA381E", @"Chinese Violet":@"856088", @"Chocolate (Traditional)":@"7B3F00", @"Chocolate (Web)":@"D2691E", @"Chrome Yellow":@"FFA700", @"Cinereous":@"98817B", @"Cinnabar":@"E34234", @"Cinnamon":@"D2691E", @"Citrine":@"E4D00A", @"Citron":@"9FA91F", @"Claret":@"7F1734", @"Classic Rose":@"FBCCE7", @"Cobalt":@"0047AB", @"Cocoa Brown":@"D2691E", @"Coconut":@"965A3E", @"Coffee":@"6F4E37", @"Columbia Blue":@"9BDDFF", @"Congo Pink":@"F88379", @"Cool Black":@"002E63", @"Cool Gray":@"8C92AC", @"Copper":@"B87333", @"Copper (Crayola)":@"DA8A67", @"Copper Penny":@"AD6F69", @"Copper Red":@"CB6D51", @"Copper Rose":@"996666", @"Coquelicot":@"FF3800", @"Coral":@"FF7F50", @"Coral Pink":@"F88379", @"Coral Red":@"FF4040", @"Cordovan":@"893F45", @"Corn":@"FBEC5D", @"Cornell Red":@"B31B1B", @"Cornflower Blue":@"6495ED", @"Cornsilk":@"FFF8DC", @"Cosmic Latte":@"FFF8E7", @"Cotton Candy":@"FFBCD9", @"Cream":@"FFFDD0", @"Crimson":@"DC143C", @"Crimson Glory":@"BE0032", @"Cyan":@"00FFFF", @"Cyan (Process)":@"00B7EB", @"Cyber Grape":@"58427C", @"Daffodil":@"FFFF31", @"Dandelion":@"F0E130", @"Dark Blue":@"00008B", @"Dark Blue-Gray":@"666699", @"Dark Brown":@"654321", @"Dark Byzantium":@"5D3954", @"Dark Candy Apple Red":@"A40000", @"Dark Cerulean":@"08457E", @"Dark Chestnut":@"986960", @"Dark Coral":@"CD5B45", @"Dark Cyan":@"008B8B", @"Dark Electric Blue":@"536878", @"Dark Goldenrod":@"B8860B", @"Dark Gray":@"A9A9A9", @"Dark Green":@"013220", @"Dark Imperial Blue":@"00416A", @"Dark Jungle Green":@"1A2421", @"Dark Khaki":@"BDB76B", @"Dark Lava":@"483C32", @"Dark Lavender":@"734F96", @"Dark Magenta":@"8B008B", @"Dark Midnight Blue":@"003366", @"Dark Moss Green":@"4A5D23", @"Dark Olive Green":@"556B2F", @"Dark Orange":@"FF8C00", @"Dark Orchid":@"9932CC", @"Dark Pastel Blue":@"779ECB", @"Dark Pastel Green":@"03C03C", @"Dark Pastel Purple":@"966FD6", @"Dark Pastel Red":@"C23B22", @"Dark Pink":@"E75480", @"Dark Powder Blue":@"003399", @"Dark Raspberry":@"872657", @"Dark Red":@"8B0000", @"Dark Salmon":@"E9967A", @"Dark Scarlet":@"560319", @"Dark Sea Green":@"8FBC8F", @"Dark Sienna":@"3C1414", @"Dark Sky Blue":@"8CBED6", @"Dark Slate Blue":@"483D8B", @"Dark Slate Gray":@"2F4F4F", @"Dark Spring Green":@"177245", @"Dark Tan":@"918151", @"Dark Tangerine":@"FFA812", @"Dark Taupe":@"483C32", @"Dark Terra Cotta":@"CC4E5C", @"Dark Turquoise":@"00CED1", @"Dark Vanilla":@"D1BEA8", @"Dark Violet":@"9400D3", @"Dark Yellow":@"9B870C", @"Dartmouth Green":@"00703C", @"Davy's Gray":@"555555", @"Debian Red":@"D70A53", @"Deep Space Sparkle":@"4A646C", @"Deep Taupe":@"7E5E60", @"Deep Tuscan Red":@"66424D", @"Deep Carmine":@"A9203E", @"Deep Carmine Pink":@"EF3038", @"Deep Carrot Orange":@"E9692C", @"Deep Cerise":@"DA3287", @"Deep Champagne":@"FAD6A5", @"Deep Chestnut":@"B94E48", @"Deep Coffee":@"704241", @"Deep Fuchsia":@"C154C1", @"Deep Jungle Green":@"004B49", @"Deep Lemon":@"F5C71A", @"Deep Lilac":@"9955BB", @"Deep Magenta":@"CC00CC", @"Deep Mauve":@"D473D4", @"Deep Moss Green":@"355E3B", @"Deep Peach":@"FFCBA4", @"Deep Pink":@"FF1493", @"Deep Ruby":@"843F5B", @"Deep Saffron":@"FF9933", @"Deep Sky Blue":@"00BFFF", @"Deer":@"BA8759", @"Denim":@"1560BD", @"Desert":@"C19A6B", @"Desert Sand":@"EDC9AF", @"Diamond":@"B9F2FF", @"Dim Gray":@"696969", @"Dirt":@"9B7653", @"Dodger Blue":@"1E90FF", @"Dogwood Rose":@"D71868", @"Dollar Bill":@"85BB65", @"Drab":@"967117", @"Duke Blue":@"00009C", @"Dust Storm":@"E5CCC9", @"Earth Yellow":@"E1A95F", @"Ebony":@"555D50", @"Ecru":@"C2B280", @"Eggplant":@"614051", @"Eggshell":@"F0EAD6", @"Egyptian Blue":@"1034A6", @"Electric Blue":@"7DF9FF", @"Electric Crimson":@"FF003F", @"Electric Cyan":@"00FFFF", @"Electric Green":@"00FF00", @"Electric Indigo":@"6F00FF", @"Electric Lavender":@"F4BBFF", @"Electric Lime":@"CCFF00", @"Electric Purple":@"BF00FF", @"Electric Ultramarine":@"3F00FF", @"Electric Violet":@"8F00FF", @"Electric Yellow":@"FFFF33", @"Emerald":@"50C878", @"English Green":@"1B4D3E", @"English Lavender":@"B48395", @"English Red":@"AB4B52", @"English Violet":@"563C5C", @"Eton Blue":@"96C8A2", @"Eucalyptus":@"44D7A8", @"Fallow":@"C19A6B", @"Falu Red":@"801818", @"Fandango":@"B53389", @"Fandango Pink":@"DE5285", @"Fashion Fuchsia":@"F400A1", @"Fawn":@"E5AA70", @"Feldgrau":@"4D5D53", @"Feldspar":@"FDD5B1", @"Fern Green":@"4F7942", @"Ferrari Red":@"FF2800", @"Field Drab":@"6C541E", @"Fire Engine Red":@"CE2029", @"Firebrick":@"B22222", @"Flame":@"E25822", @"Flamingo Pink":@"FC8EAC", @"Flattery":@"6B4423", @"Flavescent":@"F7E98E", @"Flax":@"EEDC82", @"Floral White":@"FFFAF0", @"Fluorescent Orange":@"FFBF00", @"Fluorescent Pink":@"FF1493", @"Fluorescent Yellow":@"CCFF00", @"Folly":@"FF004F", @"Forest Green (Traditional)":@"014421", @"Forest Green (Web)":@"228B22", @"French Beige":@"A67B5B", @"French Bistre":@"856D4D", @"French Blue":@"0072BB", @"French Lilac":@"86608E", @"French Lime":@"9EFD38", @"French Mauve":@"D473D4", @"French Raspberry":@"C72C48", @"French Rose":@"F64A8A", @"French Sky Blue":@"77B5FE", @"French Wine":@"AC1E44", @"Fresh Air":@"A6E7FF", @"Fuchsia":@"FF00FF", @"Fuchsia (Crayola)":@"C154C1", @"Fuchsia Pink":@"FF77FF", @"Fuchsia Rose":@"C74375", @"Fulvous":@"E48400", @"Fuzzy Wuzzy":@"CC6666", @"Go Green":@"00AB66", @"Gainsboro":@"DCDCDC", @"Gamboge":@"E49B0F", @"Ghost White":@"F8F8FF", @"Giants Orange":@"FE5A1D", @"Ginger":@"B06500", @"Glaucous":@"6082B6", @"Glitter":@"E6E8FA", @"Gold (Metallic)":@"D4AF37", @"Gold (Web) (Golden)":@"FFD700", @"Gold Fusion":@"85754E", @"Golden Brown":@"996515", @"Golden Poppy":@"FCC200", @"Golden Yellow":@"FFDF00", @"Goldenrod":@"DAA520", @"Granny Smith Apple":@"A8E4A0", @"Grape":@"6F2DA8", @"Gray":@"808080", @"Gray (Html/Css Gray)":@"808080", @"Gray (X11 Gray)":@"BEBEBE", @"Gray-Asparagus":@"465945", @"Gray-Blue":@"8C92AC", @"Green (Crayola)":@"1CAC78", @"Green (Html/Css Color)":@"008000", @"Green (Munsell)":@"00A877", @"Green (Ncs)":@"009F6B", @"Green (Ryb)":@"66B032", @"Green (Color Wheel) (X11 Green)":@"00FF00", @"Green (Pigment)":@"00A550", @"Green-Yellow":@"ADFF2F", @"Grullo":@"A99A86", @"Guppie Green":@"00FF7F", @"Halayà Úbe":@"663854", @"Han Blue":@"446CCF", @"Han Purple":@"5218FA", @"Hansa Yellow":@"E9D66B", @"Harlequin":@"3FFF00", @"Harvard Crimson":@"C90016", @"Harvest Gold":@"DA9100", @"Heart Gold":@"808000", @"Heliotrope":@"DF73FF", @"Hollywood Cerise":@"F400A1", @"Honeydew":@"F0FFF0", @"Honolulu Blue":@"006DB0", @"Hooker's Green":@"49796B", @"Hot Magenta":@"FF1DCE", @"Hot Pink":@"FF69B4", @"Hunter Green":@"355E3B", @"Iceberg":@"71A6D2", @"Icterine":@"FCF75E", @"Illuminating Emerald":@"319177", @"Imperial":@"602F6B", @"Imperial Blue":@"002395", @"Imperial Purple":@"66023C", @"Imperial Red":@"ED2939", @"Inchworm":@"B2EC5D", @"India Green":@"138808", @"Indian Red":@"CD5C5C", @"Indian Yellow":@"E3A857", @"Indigo":@"6F00FF", @"Indigo (Dye)":@"00416A", @"Indigo (Web)":@"4B0082", @"International Klein Blue":@"002FA7", @"International Orange (Golden Gate Bridge)":@"C0362C", @"International Orange (Aerospace)":@"FF4F00", @"International Orange (Engineering)":@"BA160C", @"Iris":@"5A4FCF", @"Irresistible":@"B3446C", @"Isabelline":@"F4F0EC", @"Islamic Green":@"009000", @"Italian Sky Blue":@"B2FFFF", @"Ivory":@"FFFFF0", @"Jade":@"00A86B", @"Japanese Indigo":@"264348", @"Japanese Violet":@"5B3256", @"Jasmine":@"F8DE7E", @"Jasper":@"D73B3E", @"Jazzberry Jam":@"A50B5E", @"Jelly Bean":@"DA614E", @"Jet":@"343434", @"Jonquil":@"F4CA16", @"June Bud":@"BDDA57", @"Jungle Green":@"29AB87", @"Ku Crimson":@"E8000D", @"Kelly Green":@"4CBB17", @"Kenyan Copper":@"7C1C05", @"Keppel":@"3AB09E", @"Khaki (Html/Css) (Khaki)":@"C3B091", @"Khaki (X11) (Light Khaki)":@"F0E68C", @"Kobe":@"882D17", @"Kobi":@"E79FC4", @"La Salle Green":@"087830", @"Languid Lavender":@"D6CADD", @"Lapis Lazuli":@"26619C", @"Laser Lemon":@"FFFF66", @"Laurel Green":@"A9BA9D", @"Lava":@"CF1020", @"Lavender (Floral)":@"B57EDC", @"Lavender (Web)":@"E6E6FA", @"Lavender Blue":@"CCCCFF", @"Lavender Blush":@"FFF0F5", @"Lavender Gray":@"C4C3D0", @"Lavender Indigo":@"9457EB", @"Lavender Magenta":@"EE82EE", @"Lavender Mist":@"E6E6FA", @"Lavender Pink":@"FBAED2", @"Lavender Purple":@"967BB6", @"Lavender Rose":@"FBA0E3", @"Lawn Green":@"7CFC00", @"Lemon":@"FFF700", @"Lemon Chiffon":@"FFFACD", @"Lemon Curry":@"CCA01D", @"Lemon Glacier":@"FDFF00", @"Lemon Lime":@"E3FF00", @"Lemon Meringue":@"F6EABE", @"Lemon Yellow":@"FFF44F", @"Licorice":@"1A1110", @"Light Thulian Pink":@"E68FAC", @"Light Apricot":@"FDD5B1", @"Light Blue":@"ADD8E6", @"Light Brown":@"B5651D", @"Light Carmine Pink":@"E66771", @"Light Coral":@"F08080", @"Light Cornflower Blue":@"93CCEA", @"Light Crimson":@"F56991", @"Light Cyan":@"E0FFFF", @"Light Fuchsia Pink":@"F984EF", @"Light Goldenrod Yellow":@"FAFAD2", @"Light Gray":@"D3D3D3", @"Light Green":@"90EE90", @"Light Khaki":@"F0E68C", @"Light Medium Orchid":@"D39BCB", @"Light Moss Green":@"ADDFAD", @"Light Orchid":@"E6A8D7", @"Light Pastel Purple":@"B19CD9", @"Light Pink":@"FFB6C1", @"Light Red Ochre":@"E97451", @"Light Salmon":@"FFA07A", @"Light Salmon Pink":@"FF9999", @"Light Sea Green":@"20B2AA", @"Light Sky Blue":@"87CEFA", @"Light Slate Gray":@"778899", @"Light Steel Blue":@"B0C4DE", @"Light Taupe":@"B38B6D", @"Light Yellow":@"FFFFE0", @"Lilac":@"C8A2C8", @"Lime (Color Wheel)":@"BFFF00", @"Lime (Web) (X11 Green)":@"00FF00", @"Lime Green":@"32CD32", @"Limerick":@"9DC209", @"Lincoln Green":@"195905", @"Linen":@"FAF0E6", @"Lion":@"C19A6B", @"Little Boy Blue":@"6CA0DC", @"Liver":@"534B4F", @"Lumber":@"FFE4CD", @"Lust":@"E62020", @"Msu Green":@"18453B", @"Magenta":@"FF00FF", @"Magenta (Crayola)":@"FF55A3", @"Magenta (Pantone)":@"D0417E", @"Magenta (Dye)":@"CA1F7B", @"Magenta (Process)":@"FF0090", @"Magic Mint":@"AAF0D1", @"Magnolia":@"F8F4FF", @"Mahogany":@"C04000", @"Maize":@"FBEC5D", @"Majorelle Blue":@"6050DC", @"Malachite":@"0BDA51", @"Manatee":@"979AAA", @"Mango Tango":@"FF8243", @"Mantis":@"74C365", @"Mardi Gras":@"880085", @"Maroon (Crayola)":@"C32148", @"Maroon (Html/Css)":@"800000", @"Maroon (X11)":@"B03060", @"Mauve":@"E0B0FF", @"Mauve Taupe":@"915F6D", @"Mauvelous":@"EF98AA", @"Maya Blue":@"73C2FB", @"Meat Brown":@"E5B73B", @"Medium Persian Blue":@"0067A5", @"Medium Tuscan Red":@"79443B", @"Medium Aquamarine":@"66DDAA", @"Medium Blue":@"0000CD", @"Medium Candy Apple Red":@"E2062C", @"Medium Carmine":@"AF4035", @"Medium Champagne":@"F3E5AB", @"Medium Electric Blue":@"035096", @"Medium Jungle Green":@"1C352D", @"Medium Lavender Magenta":@"DDA0DD", @"Medium Orchid":@"BA55D3", @"Medium Purple":@"9370DB", @"Medium Red-Violet":@"BB3385", @"Medium Ruby":@"AA4069", @"Medium Sea Green":@"3CB371", @"Medium Sky Blue":@"80DAEB", @"Medium Slate Blue":@"7B68EE", @"Medium Spring Bud":@"C9DC87", @"Medium Spring Green":@"00FA9A", @"Medium Taupe":@"674C47", @"Medium Turquoise":@"48D1CC", @"Medium Vermilion":@"D9603B", @"Medium Violet-Red":@"C71585", @"Mellow Apricot":@"F8B878", @"Mellow Yellow":@"F8DE7E", @"Melon":@"FDBCB4", @"Metallic Seaweed":@"0A7E8C", @"Metallic Sunburst":@"9C7C38", @"Mexican Pink":@"E4007C", @"Midnight Blue":@"191970", @"Midnight Green (Eagle Green)":@"004953", @"Midori":@"E3F988", @"Mikado Yellow":@"FFC40C", @"Mint":@"3EB489", @"Mint Cream":@"F5FFFA", @"Mint Green":@"98FF98", @"Misty Rose":@"FFE4E1", @"Moccasin":@"FAEBD7", @"Mode Beige":@"967117", @"Moonstone Blue":@"73A9C2", @"Mordant Red 19":@"AE0C00", @"Moss Green":@"8A9A5B", @"Mountain Meadow":@"30BA8F", @"Mountbatten Pink":@"997A8D", @"Mughal Green":@"306030", @"Mulberry":@"C54B8C", @"Mustard":@"FFDB58", @"Myrtle Green":@"317873", @"Nadeshiko Pink":@"F6ADC6", @"Napier Green":@"2A8000", @"Naples Yellow":@"FADA5E", @"Navajo White":@"FFDEAD", @"Navy Blue":@"000080", @"Navy Purple":@"9457EB", @"Neon Carrot":@"FFA343", @"Neon Fuchsia":@"FE4164", @"Neon Green":@"39FF14", @"New Car":@"214FC6", @"New York Pink":@"D7837F", @"Non-Photo Blue":@"A4DDED", @"North Texas Green":@"059033", @"Nyanza":@"E9FFDB", @"Ou Crimson Red":@"990000", @"Ocean Boat Blue":@"0077BE", @"Ochre":@"CC7722", @"Office Green":@"008000", @"Old Burgundy":@"43302E", @"Old Gold":@"CFB53B", @"Old Lace":@"FDF5E6", @"Old Lavender":@"796878", @"Old Mauve":@"673147", @"Old Moss Green":@"867E36", @"Old Rose":@"C08081", @"Old Silver":@"848482", @"Olive":@"808000", @"Olive Drab #7":@"3C341F", @"Olive Drab (Web) (Olive Drab #3)":@"6B8E23", @"Olivine":@"9AB973", @"Onyx":@"353839", @"Opera Mauve":@"B784A7", @"Orange (Crayola)":@"FF7538", @"Orange (Pantone)":@"FF5800", @"Orange (Ryb)":@"FB9902", @"Orange (Color Wheel)":@"FF7F00", @"Orange (Web Color)":@"FFA500", @"Orange Peel":@"FF9F00", @"Orange-Red":@"FF4500", @"Orchid":@"DA70D6", @"Orchid Pink":@"F28DCD", @"Orioles Orange":@"FB4F14", @"Otter Brown":@"654321", @"Outer Space":@"414A4C", @"Outrageous Orange":@"FF6E4A", @"Oxford Blue":@"002147", @"Pakistan Green":@"006600", @"Palatinate Blue":@"273BE2", @"Palatinate Purple":@"682860", @"Pale Aqua":@"BCD4E6", @"Pale Blue":@"AFEEEE", @"Pale Brown":@"987654", @"Pale Carmine":@"AF4035", @"Pale Cerulean":@"9BC4E2", @"Pale Chestnut":@"DDADAF", @"Pale Copper":@"DA8A67", @"Pale Cornflower Blue":@"ABCDEF", @"Pale Gold":@"E6BE8A", @"Pale Goldenrod":@"EEE8AA", @"Pale Green":@"98FB98", @"Pale Lavender":@"DCD0FF", @"Pale Magenta":@"F984E5", @"Pale Pink":@"FADADD", @"Pale Plum":@"DDA0DD", @"Pale Red-Violet":@"DB7093", @"Pale Robin Egg Blue":@"96DED1", @"Pale Silver":@"C9C0BB", @"Pale Spring Bud":@"ECEBBD", @"Pale Taupe":@"BC987E", @"Pale Turquoise":@"AFEEEE", @"Pale Violet-Red":@"DB7093", @"Pansy Purple":@"78184A", @"Papaya Whip":@"FFEFD5", @"Paris Green":@"50C878", @"Pastel Blue":@"AEC6CF", @"Pastel Brown":@"836953", @"Pastel Gray":@"CFCFC4", @"Pastel Green":@"77DD77", @"Pastel Magenta":@"F49AC2", @"Pastel Orange":@"FFB347", @"Pastel Pink":@"DEA5A4", @"Pastel Purple":@"B39EB5", @"Pastel Red":@"FF6961", @"Pastel Violet":@"CB99C9", @"Pastel Yellow":@"FDFD96", @"Patriarch":@"800080", @"Payne's Gray":@"536878", @"Peach":@"FFE5B4", @"Peach (Crayola)":@"FFCBA4", @"Peach Puff":@"FFDAB9", @"Peach-Orange":@"FFCC99", @"Peach-Yellow":@"FADFAD", @"Pear":@"D1E231", @"Pearl":@"EAE0C8", @"Pearl Aqua":@"88D8C0", @"Pearly Purple":@"B768A2", @"Peridot":@"E6E200", @"Periwinkle":@"CCCCFF", @"Persian Blue":@"1C39BB", @"Persian Green":@"00A693", @"Persian Indigo":@"32127A", @"Persian Orange":@"D99058", @"Persian Pink":@"F77FBE", @"Persian Plum":@"701C1C", @"Persian Red":@"CC3333", @"Persian Rose":@"FE28A2", @"Persimmon":@"EC5800", @"Peru":@"CD853F", @"Phlox":@"DF00FF", @"Phthalo Blue":@"000F89", @"Phthalo Green":@"123524", @"Pictorial Carmine":@"C30B4E", @"Piggy Pink":@"FDDDE6", @"Pine Green":@"01796F", @"Pink":@"FFC0CB", @"Pink Sherbet":@"F78FA7", @"Pink Lace":@"FFDDF4", @"Pink Pearl":@"E7ACCF", @"Pink-Orange":@"FF9966", @"Pistachio":@"93C572", @"Platinum":@"E5E4E2", @"Plum (Traditional)":@"8E4585", @"Plum (Web)":@"DDA0DD", @"Pomp And Power":@"86608E", @"Portland Orange":@"FF5A36", @"Powder Blue (Web)":@"B0E0E6", @"Princeton Orange":@"FF8F00", @"Prune":@"701C1C", @"Prussian Blue":@"003153", @"Psychedelic Purple":@"DF00FF", @"Puce":@"CC8899", @"Pumpkin":@"FF7518", @"Purple (Html/Css)":@"800080", @"Purple (Munsell)":@"9F00C5", @"Purple (X11)":@"A020F0", @"Purple Heart":@"69359C", @"Purple Mountain Majesty":@"9678B6", @"Purple Pizzazz":@"FE4EDA", @"Purple Taupe":@"50404D", @"Quartz":@"51484F", @"Queen Blue":@"436B95", @"Queen Pink":@"E8CCD7", @"Rackley":@"5D8AA8", @"Radical Red":@"FF355E", @"Rajah":@"FBAB60", @"Raspberry":@"E30B5D", @"Raspberry Glace":@"915F6D", @"Raspberry Pink":@"E25098", @"Raspberry Rose":@"B3446C", @"Raw Umber":@"826644", @"Razzle Dazzle Rose":@"FF33CC", @"Razzmatazz":@"E3256B", @"Razzmic Berry":@"8D4E85", @"Red":@"FF0000", @"Red (Crayola)":@"EE204D", @"Red (Munsell)":@"F2003C", @"Red (Ncs)":@"C40233", @"Red (Pantone)":@"ED2939", @"Red (Ryb)":@"FE2712", @"Red (Pigment)":@"ED1C24", @"Red Devil":@"860111", @"Red-Brown":@"A52A2A", @"Red-Orange":@"FF5349", @"Red-Violet":@"C71585", @"Redwood":@"A45A52", @"Regalia":@"522D80", @"Resolution Blue":@"002387", @"Rhythm":@"777696", @"Rich Black":@"004040", @"Rich Brilliant Lavender":@"F1A7FE", @"Rich Carmine":@"D70040", @"Rich Electric Blue":@"0892D0", @"Rich Lavender":@"A76BCF", @"Rich Lilac":@"B666D2", @"Rich Maroon":@"B03060", @"Rifle Green":@"444C38", @"Robin Egg Blue":@"00CCCC", @"Rocket Metallic":@"8A7F80", @"Roman Silver":@"838996", @"Rose":@"FF007F", @"Rose Bonbon":@"F9429E", @"Rose Ebony":@"674846", @"Rose Gold":@"B76E79", @"Rose Madder":@"E32636", @"Rose Pink":@"FF66CC", @"Rose Quartz":@"AA98A9", @"Rose Red":@"C21E56", @"Rose Taupe":@"905D5D", @"Rose Vale":@"AB4E52", @"Rosewood":@"65000B", @"Rosso Corsa":@"D40000", @"Rosy Brown":@"BC8F8F", @"Royal Azure":@"0038A8", @"Royal Blue (Traditional)":@"002366", @"Royal Blue (Web)":@"4169E1", @"Royal Fuchsia":@"CA2C92", @"Royal Purple":@"7851A9", @"Royal Yellow":@"FADA5E", @"Ruber":@"CE4676", @"Rubine Red":@"D10056", @"Ruby":@"E0115F", @"Ruby Red":@"9B111E", @"Ruddy":@"FF0028", @"Ruddy Brown":@"BB6528", @"Ruddy Pink":@"E18E96", @"Rufous":@"A81C07", @"Russet":@"80461B", @"Russian Green":@"679267", @"Russian Violet":@"32174D", @"Rust":@"B7410E", @"Rusty Red":@"DA2C43", @"Sae/Ece Amber (Color)":@"FF7E00", @"Sacramento State Green":@"00563F", @"Saddle Brown":@"8B4513", @"Safety Orange (Blaze Orange)":@"FF6700", @"Safety Yellow":@"EED202", @"Saffron":@"F4C430", @"Salmon":@"FF8C69", @"Salmon Pink":@"FF91A4", @"Sand":@"C2B280", @"Sand Dune":@"967117", @"Sandstorm":@"ECD540", @"Sandy Brown":@"F4A460", @"Sandy Taupe":@"967117", @"Sangria":@"92000A", @"Sap Green":@"507D2A", @"Sapphire":@"0F52BA", @"Sapphire Blue":@"0067A5", @"Satin Sheen Gold":@"CBA135", @"Scarlet":@"FF2400", @"Scarlet (Crayola)":@"FD0E35", @"Schauss Pink":@"FF91AF", @"School Bus Yellow":@"FFD800", @"Screamin' Green":@"76FF7A", @"Sea Blue":@"006994", @"Sea Green":@"2E8B57", @"Seal Brown":@"321414", @"Seashell":@"FFF5EE", @"Selective Yellow":@"FFBA00", @"Sepia":@"704214", @"Shadow":@"8A795D", @"Shampoo":@"FFCFF1", @"Shamrock Green":@"009E60", @"Sheen Green":@"8FD400", @"Shimmering Blush":@"D98695", @"Shocking Pink":@"FC0FC0", @"Shocking Pink (Crayola)":@"FF6FFF", @"Sienna":@"882D17", @"Silver":@"C0C0C0", @"Silver Lake Blue":@"5D89BA", @"Silver Chalice":@"ACACAC", @"Silver Pink":@"C4AEAD", @"Silver Sand":@"BFC1C2", @"Sinopia":@"CB410B", @"Skobeloff":@"007474", @"Sky Blue":@"87CEEB", @"Sky Magenta":@"CF71AF", @"Slate Blue":@"6A5ACD", @"Slate Gray":@"708090", @"Smalt (Dark Powder Blue)":@"003399", @"Smitten":@"C84186", @"Smoke":@"738276", @"Smokey Topaz":@"933D41", @"Smoky Black":@"100C08", @"Snow":@"FFFAFA", @"Soap":@"CEC8EF", @"Sonic Silver":@"757575", @"Space Cadet":@"1D2951", @"Spanish Bistre":@"80755A", @"Spanish Carmine":@"D10047", @"Spanish Crimson":@"E51A4C", @"Spanish Orange":@"E86100", @"Spanish Sky Blue":@"00AAE4", @"Spartan Crimson":@"9E1316", @"Spiro Disco Ball":@"0FC0FC", @"Spring Bud":@"A7FC00", @"Spring Green":@"00FF7F", @"St. Patrick's Blue":@"23297A", @"Star Command Blue":@"007BB8", @"Steel Blue":@"4682B4", @"Steel Pink":@"CC3366", @"Stil De Grain Yellow":@"FADA5E", @"Stizza":@"990000", @"Stormcloud":@"4F666A", @"Straw":@"E4D96F", @"Strawberry":@"FC5A8D", @"Sunglow":@"FFCC33", @"Sunray":@"E3AB57", @"Sunset":@"FAD6A5", @"Sunset Orange":@"FD5E53", @"Super Pink":@"CF6BA9", @"Tan":@"D2B48C", @"Tangelo":@"F94D00", @"Tangerine":@"F28500", @"Tangerine Yellow":@"FFCC00", @"Tango Pink":@"E4717A", @"Taupe":@"483C32", @"Taupe Gray":@"8B8589", @"Tea Green":@"D0F0C0", @"Tea Rose (Orange)":@"F88379", @"Tea Rose (Rose)":@"F4C2C2", @"Teal":@"008080", @"Teal Blue":@"367588", @"Teal Deer":@"99E6B3", @"Teal Green":@"00827F", @"Telemagenta":@"CF3476", @"Tenné (Tawny)":@"CD5700", @"Terra Cotta":@"E2725B", @"Thistle":@"D8BFD8", @"Thulian Pink":@"DE6FA1", @"Tickle Me Pink":@"FC89AC", @"Tiffany Blue":@"0ABAB5", @"Tiger's Eye":@"E08D3C", @"Timberwolf":@"DBD7D2", @"Titanium Yellow":@"EEE600", @"Tomato":@"FF6347", @"Toolbox":@"746CC0", @"Topaz":@"FFC87C", @"Tractor Red":@"FD0E35", @"Trolley Gray":@"808080", @"Tropical Rain Forest":@"00755E", @"True Blue":@"0073CF", @"Tufts Blue":@"417DC1", @"Tulip":@"FF878D", @"Tumbleweed":@"DEAA88", @"Turkish Rose":@"B57281", @"Turquoise":@"30D5C8", @"Turquoise Blue":@"00FFEF", @"Turquoise Green":@"A0D6B4", @"Tuscan":@"FAD6A5", @"Tuscan Brown":@"6F4E37", @"Tuscan Red":@"7C4848", @"Tuscan Tan":@"A67B5B", @"Tuscany":@"C09999", @"Twilight Lavender":@"8A496B", @"Tyrian Purple":@"66023C", @"Ua Blue":@"0033AA", @"Ua Red":@"D9004C", @"Ucla Blue":@"536895", @"Ucla Gold":@"FFB300", @"Ufo Green":@"3CD070", @"Up Forest Green":@"014421", @"Up Maroon":@"7B1113", @"Usafa Blue":@"004F98", @"Usc Cardinal":@"990000", @"Usc Gold":@"FFCC00", @"Ube":@"8878C3", @"Ultra Pink":@"FF6FFF", @"Ultramarine":@"120A8F", @"Ultramarine Blue":@"4166F5", @"Umber":@"635147", @"Unbleached Silk":@"FFDDCA", @"United Nations Blue":@"5B92E5", @"University Of California Gold":@"B78727", @"University Of Tennessee Orange":@"F77F00", @"Unmellow Yellow":@"FFFF66", @"Upsdell Red":@"AE2029", @"Urobilin":@"E1AD21", @"Utah Crimson":@"D3003F", @"Vanilla":@"F3E5AB", @"Vanilla Ice":@"F3D9DF", @"Vegas Gold":@"C5B358", @"Venetian Red":@"C80815", @"Verdigris":@"43B3AE", @"Vermilion (Plochere)":@"D9603B", @"Vermilion (Cinnabar)":@"E34234", @"Veronica":@"A020F0", @"Violet":@"8F00FF", @"Violet (Ryb)":@"8601AF", @"Violet (Color Wheel)":@"7F00FF", @"Violet (Web)":@"EE82EE", @"Violet-Blue":@"324AB2", @"Violet-Red":@"F75394", @"Viridian":@"40826D", @"Vivid Auburn":@"922724", @"Vivid Burgundy":@"9F1D35", @"Vivid Cerise":@"DA1D81", @"Vivid Orchid":@"CC00FF", @"Vivid Sky Blue":@"00CCFF", @"Vivid Tangerine":@"FFA089", @"Vivid Violet":@"9F00FF", @"Warm Black":@"004242", @"Waterspout":@"A4F4F9", @"Wenge":@"645452", @"Wheat":@"F5DEB3", @"White":@"FFFFFF", @"White Smoke":@"F5F5F5", @"Wild Strawberry":@"FF43A4", @"Wild Watermelon":@"FC6C85", @"Wild Blue Yonder":@"A2ADD0", @"Wild Orchid":@"D77A02", @"Windsor Tan":@"AE6838", @"Wine":@"722F37", @"Wine Dregs":@"673147", @"Wisteria":@"C9A0DC", @"Wood Brown":@"C19A6B", @"Xanadu":@"738678", @"Yale Blue":@"0F4D92", @"Yankees Blue":@"1C2841", @"Yellow":@"FFFF00", @"Yellow (Munsell)":@"EFCC00", @"Yellow (Ncs)":@"FFD300", @"Yellow (Ryb)":@"FEFE33", @"Yellow (Process)":@"FFEF00", @"Yellow Orange":@"FFAE42", @"Yellow Rose":@"FFF000", @"Yellow-Green":@"9ACD32", @"Zaffre":@"0014A8", @"Zinnwaldite Brown":@"2C1608", @"Zomp":@"39A78E", };
    
    /*
     http://www.hpl.hp.com/personal/Nathan_Moroney/ei03-moroney.pdf
     http://www.hpl.hp.com/personal/Nathan_Moroney/color-name-hpl.html
     
     I have sorted and capitalized the strings 5/15/13
     */
    NSDictionary *moroneyDictionary = @{@"Apple Green":@"58e24a", @"Apricot":@"ffa863", @"Aqua":@"42dad3", @"Aqua Blue":@"4acfee", @"Aqua Green":@"38daae", @"Aqua Marine":@"42d7d3", @"Aquamarine":@"31d3c7", @"Army Green":@"647f23", @"Aubergine":@"7a1b70", @"Avocado":@"7fac2b", @"Azure":@"3e8ef4", @"Baby Blue":@"72c5f7", @"Beige":@"d5c383", @"Black":@"1e1e20", @"Blue":@"3865d2", @"Blue Gray":@"4e89a4", @"Blue Green":@"31b49e", @"Blue Purple":@"7536e2", @"Blue Violet":@"5f26c8", @"Bluish Purple":@"6327c9", @"Bottle Green":@"429e33", @"Brick":@"ab2620", @"Brick Red":@"af221c", @"Bright Blue":@"2052f3", @"Bright Green":@"3bef37", @"Bright Pink":@"ff23b6", @"Bright Purple":@"ae2de3", @"Bright Red":@"f3172d", @"Bright Violet":@"b729f4", @"Bright Yellow":@"f2f735", @"Brown":@"894c24", @"Burgundy":@"8c1932", @"Burnt Orange":@"d66715", @"Burnt Sienna":@"c0561f", @"Cadet Blue":@"3f72ae", @"Canary Yellow":@"faff45", @"Cerise":@"e72ba0", @"Cerulean":@"2975f1", @"Cerulean Blue":@"3381f5", @"Charcoal":@"3b4445", @"Chartreuse":@"99e326", @"Chocolate":@"743521", @"Chocolate Brown":@"71331f", @"Cobalt":@"3331d5", @"Cobalt Blue":@"2d3ad5", @"Coral":@"f55963", @"Cornflower":@"627ede", @"Cornflower Blue":@"5074da", @"Cream":@"e1dcaa", @"Crimson":@"c11844", @"Cyan":@"49d6e7", @"Dark Blue":@"1b2596", @"Dark Brown":@"551c1a", @"Dark Cyan":@"3884af", @"Dark Gray":@"424c4c", @"Dark Green":@"25702b", @"Dark Lavender":@"6f45ab", @"Dark Magenta":@"b21a9c", @"Dark Olive":@"4b6124", @"Dark Orange":@"d66219", @"Dark Pink":@"dc3d96", @"Dark Purple":@"63187d", @"Dark Red":@"af132b", @"Dark Violet":@"66248e", @"Dark Yellow":@"b5b820", @"Deep Blue":@"2a22bd", @"Deep Purple":@"551577", @"Dusty Rose":@"ce758b", @"Eggplant":@"5c2068", @"Electric Blue":@"2646ea", @"Electric Green":@"37fa33", @"Emerald":@"30b853", @"Emerald Green":@"3bbc46", @"Evergreen":@"267933", @"Flesh":@"f3b791", @"Fluorescent Green":@"48fb47", @"Forest":@"267631", @"Forest Green":@"247532", @"Fuchsia":@"e62cbd", @"Gold":@"d9b324", @"Golden Yellow":@"ffd138", @"Goldenrod":@"f4c220", @"Grape":@"903093", @"Grass":@"40bb30", @"Grass Green":@"39b82d", @"Gray":@"7a8e94", @"Gray Blue":@"4c71a0", @"Gray Green":@"4f8b78", @"Green":@"4fc54a", @"Green Blue":@"29b795", @"Green Yellow":@"7fe22e", @"Greenish Yellow":@"c7db25", @"Hot Pink":@"fa27b6", @"Hunter Green":@"276e33", @"Indigo":@"562bb2", @"Jade":@"41bd85", @"Jungle Green":@"24ae62", @"Kelly Green":@"25bd38", @"Key Lime":@"66ee4e", @"Khaki":@"8f9645", @"Lavender":@"b677e0", @"Leaf Green":@"3db83b", @"Lemon":@"d5f14b", @"Lemon Lime":@"9be448", @"Lemon Yellow":@"fcfc3e", @"Light Blue":@"5cb9f3", @"Light Brown":@"b37839", @"Light Cyan":@"8efff7", @"Light Gray":@"c5c5c5", @"Light Green":@"69ea65", @"Light Orange":@"f9a833", @"Light Pink":@"fcb3d3", @"Light Purple":@"b25fdc", @"Light Teal":@"66c6bc", @"Light Turquoise":@"63efdf", @"Light Violet":@"c173dd", @"Light Yellow":@"faff91", @"Lilac":@"ba77e2", @"Lime":@"6aef3b", @"Lime Green":@"64ee38", @"Magenta":@"db21ad", @"Marine Blue":@"2a6bcc", @"Maroon":@"8c1c3d", @"Mauve":@"b45fa0", @"Medium Blue":@"3957db", @"Medium Brown":@"9d612a", @"Medium Green":@"37b042", @"Midnight Blue":@"1d1e87", @"Mint":@"5eeca1", @"Mint Green":@"62eca2", @"Mocha":@"8e452f", @"Moss":@"5e9846", @"Moss Green":@"579244", @"Mustard":@"d4b927", @"Mustard Yellow":@"dfc12a", @"Navy":@"1c2182", @"Navy Blue":@"1b2183", @"Neon Green":@"49fb35", @"Ocean Blue":@"3987c9", @"Ochre":@"d1a329", @"Olive":@"77912c", @"Olive Green":@"73922b", @"Orange":@"f17820", @"Orange Red":@"ed4217", @"Orchid":@"c966d4", @"Pale Blue":@"66bce8", @"Pale Green":@"8ae492", @"Pale Pink":@"f7b8b8", @"Pale Yellow":@"fdffa0", @"Pastel Green":@"69e49e", @"Pastel Pink":@"f999db", @"Pea Green":@"88c039", @"Peach":@"fcaa7b", @"Periwinkle":@"8077e7", @"Periwinkle Blue":@"7e6ff3", @"Pine":@"357f39", @"Pine Green":@"377d2f", @"Pink":@"f45bb7", @"Pistachio":@"7fef76", @"Plum":@"872c82", @"Powder Blue":@"87b1f1", @"Puce":@"ab8637", @"Pumpkin":@"ee8a21", @"Purple":@"9330bc", @"Purple Blue":@"5c2ed0", @"Raspberry":@"cd2e7a", @"Red":@"d8232c", @"Red Brown":@"993c27", @"Red Orange":@"f4481d", @"Reddish Brown":@"9c3321", @"Rose":@"dd6398", @"Rose Pink":@"ed56a0", @"Royal Blue":@"2729d4", @"Royal Purple":@"7322b3", @"Rust":@"b54020", @"Sage":@"77b575", @"Sage Green":@"6bae63", @"Salmon":@"f57576", @"Salmon Pink":@"f88989", @"Sand":@"d6b55f", @"Scarlet":@"e9264b", @"Sea Blue":@"3a8ed0", @"Sea Foam":@"59ebad", @"Sea Foam Green":@"5aebad", @"Sea Green":@"47d89a", @"Sienna":@"b2521d", @"Sky":@"4faaee", @"Sky Blue":@"4daff1", @"Slate":@"5d7e9a", @"Slate Blue":@"457da0", @"Spring Green":@"5de549", @"Steel Blue":@"38619e", @"Sunshine Yellow":@"fff92e", @"Tan":@"d19c52", @"Tangerine":@"fd7f2a", @"Taupe":@"ab9371", @"Teal":@"3aafa9", @"Teal Blue":@"2f7bac", @"Terracotta":@"d5603c", @"True Blue":@"1f47d7", @"Turquoise":@"3bd2ce", @"Violet":@"983bcd", @"Violet Blue":@"7230d8", @"Watermelon":@"ea5169", @"White":@"f9fdf3", @"Wine":@"8c205c", @"Yellow":@"dde840", @"Yellow Green":@"96dc30", @"Yellow Orange":@"ffc629", @"Yellowish Green":@"8ed93e", };
    
    /*
     http://xkcd.com/color/rgb.txt
     http://blog.xkcd.com/2010/05/03/color-survey-results/
     
     I have done some basic spelling fixes and replaced shit with poo
     for anyone who wants to submit with a 4+ rating to App Store.
     
     5/15 - Updated all strings to capitalized format.
     
     Known items *not* addressed are: orangeish, camo, azul, burple, purpleish, camo green, and blurple.
     */
    NSDictionary *xkcdDictionary = @{@"Acid Green":@"8ffe09", @"Adobe":@"bd6c48", @"Algae":@"54ac68", @"Algae Green":@"21c36f", @"Almost Black":@"070d0d", @"Amber":@"feb308", @"Amethyst":@"9b5fc0", @"Apple":@"6ecb3c", @"Apple Green":@"76cd26", @"Apricot":@"ffb16d", @"Aqua":@"13eac9", @"Aqua Blue":@"02d8e9", @"Aqua Green":@"12e193", @"Aqua Marine":@"2ee8bb", @"Aquamarine":@"04d8b2", @"Army Green":@"4b5d16", @"Asparagus":@"77ab56", @"Aubergine":@"3d0734", @"Auburn":@"9a3001", @"Avocado":@"90b134", @"Avocado Green":@"87a922", @"Azul":@"1d5dec", @"Azure":@"069af3", @"Baby Blue":@"a2cffe", @"Baby Green":@"8cff9e", @"Baby Pink":@"ffb7ce", @"Baby Poo":@"ab9004", @"Baby Poop":@"937c00", @"Baby Poop Brown":@"ad900d", @"Baby Poop Green":@"889717", @"Baby Puke Green":@"b6c406", @"Baby Purple":@"ca9bf7", @"Banana":@"ffff7e", @"Banana Yellow":@"fafe4b", @"Barbie Pink":@"fe46a5", @"Barf Green":@"94ac02", @"Barney":@"ac1db8", @"Barney Purple":@"a00498", @"Battleship Gray":@"6b7c85", @"Beige":@"e6daa6", @"Berry":@"990f4b", @"Bile":@"b5c306", @"Black":@"000000", @"Bland":@"afa88b", @"Blood":@"770001", @"Blood Orange":@"fe4b03", @"Blood Red":@"980002", @"Blue":@"0343df", @"Blue Blue":@"2242c7", @"Blue Gray":@"89a0b0", @"Blue Green":@"2bb179", @"Blue Purple":@"6241c7", @"Blue Violet":@"5d06e9", @"Blue With A Hint Of Purple":@"533cc6", @"Blue/Gray":@"758da3", @"Blue/Green":@"0f9b8e", @"Blue/Purple":@"5a06ef", @"Blueberry":@"464196", @"Bluish":@"2976bb", @"Bluish Gray":@"748b97", @"Bluish Green":@"10a674", @"Bluish Purple":@"703be7", @"Blurple":@"5539cc", @"Blush":@"f29e8e", @"Blush Pink":@"fe828c", @"Booger":@"9bb53c", @"Booger Green":@"96b403", @"Bordeaux":@"7b002c", @"Boring Green":@"63b365", @"Bottle Green":@"044a05", @"Brick":@"a03623", @"Brick Orange":@"c14a09", @"Brick Red":@"8f1402", @"Bright Aqua":@"0bf9ea", @"Bright Blue":@"0165fc", @"Bright Cyan":@"41fdfe", @"Bright Green":@"01ff07", @"Bright Lavender":@"c760ff", @"Bright Light Blue":@"26f7fd", @"Bright Light Green":@"2dfe54", @"Bright Lilac":@"c95efb", @"Bright Lime":@"87fd05", @"Bright Lime Green":@"65fe08", @"Bright Magenta":@"ff08e8", @"Bright Olive":@"9cbb04", @"Bright Orange":@"ff5b00", @"Bright Pink":@"fe01b1", @"Bright Purple":@"be03fd", @"Bright Red":@"ff000d", @"Bright Sea Green":@"05ffa6", @"Bright Sky Blue":@"02ccfe", @"Bright Teal":@"01f9c6", @"Bright Turquoise":@"0ffef9", @"Bright Violet":@"ad0afd", @"Bright Yellow":@"fffd01", @"Bright Yellow Green":@"9dff00", @"British Racing Green":@"05480d", @"Bronze":@"a87900", @"Brown":@"653700", @"Brown Gray":@"8d8468", @"Brown Green":@"706c11", @"Brown Orange":@"b96902", @"Brown Red":@"922b05", @"Brown Yellow":@"b29705", @"Brownish":@"9c6d57", @"Brownish Gray":@"86775f", @"Brownish Green":@"6a6e09", @"Brownish Orange":@"cb7723", @"Brownish Pink":@"c27e79", @"Brownish Purple":@"76424e", @"Brownish Red":@"9e3623", @"Brownish Yellow":@"c9b003", @"Browny Green":@"6f6c0a", @"Browny Orange":@"ca6b02", @"Bruise":@"7e4071", @"Bubble Gum Pink":@"ff69af", @"Bubblegum":@"ff6cb5", @"Bubblegum Pink":@"fe83cc", @"Buff":@"fef69e", @"Burgundy":@"610023", @"Burnt Orange":@"c04e01", @"Burnt Red":@"9f2305", @"Burnt Siena":@"b75203", @"Burnt Sienna":@"b04e0f", @"Burnt Umber":@"a0450e", @"Burnt Yellow":@"d5ab09", @"Burple":@"6832e3", @"Butter":@"ffff81", @"Butter Yellow":@"fffd74", @"Butterscotch":@"fdb147", @"Cadet Blue":@"4e7496", @"Camel":@"c69f59", @"Camo":@"7f8f4e", @"Camo Green":@"526525", @"Camouflage Green":@"4b6113", @"Canary":@"fdff63", @"Canary Yellow":@"fffe40", @"Candy Pink":@"ff63e9", @"Caramel":@"af6f09", @"Carmine":@"9d0216", @"Carnation":@"fd798f", @"Carnation Pink":@"ff7fa7", @"Carolina Blue":@"8ab8fe", @"Celadon":@"befdb7", @"Celery":@"c1fd95", @"Cement":@"a5a391", @"Cerise":@"de0c62", @"Cerulean":@"0485d1", @"Cerulean Blue":@"056eee", @"Charcoal":@"343837", @"Charcoal Gray":@"3c4142", @"Chartreuse":@"c1f80a", @"Cherry":@"cf0234", @"Cherry Red":@"f7022a", @"Chestnut":@"742802", @"Chocolate":@"3d1c02", @"Chocolate Brown":@"411900", @"Cinnamon":@"ac4f06", @"Claret":@"680018", @"Clay":@"b66a50", @"Clay Brown":@"b2713d", @"Clear Blue":@"247afd", @"Cloudy Blue":@"acc2d9", @"Cobalt":@"1e488f", @"Cobalt Blue":@"030aa7", @"Cocoa":@"875f42", @"Coffee":@"a6814c", @"Cool Blue":@"4984b8", @"Cool Gray":@"95a3a6", @"Cool Green":@"33b864", @"Copper":@"b66325", @"Coral":@"fc5a50", @"Coral Pink":@"ff6163", @"Cornflower":@"6a79f7", @"Cornflower Blue":@"5170d7", @"Cranberry":@"9e003a", @"Cream":@"ffffc2", @"Creme":@"ffffb6", @"Crimson":@"8c000f", @"Custard":@"fffd78", @"Cyan":@"00ffff", @"Dandelion":@"fedf08", @"Dark":@"1b2431", @"Dark Aqua":@"05696b", @"Dark Aquamarine":@"017371", @"Dark Beige":@"ac9362", @"Dark Blue":@"030764", @"Dark Blue Gray":@"1f3b4d", @"Dark Blue Green":@"005249", @"Dark Brown":@"341c02", @"Dark Coral":@"cf524e", @"Dark Cream":@"fff39a", @"Dark Cyan":@"0a888a", @"Dark Forest Green":@"002d04", @"Dark Fuchsia":@"9d0759", @"Dark Gold":@"b59410", @"Dark Grass Green":@"388004", @"Dark Gray":@"363737", @"Dark Gray Blue":@"29465b", @"Dark Green":@"054907", @"Dark Green Blue":@"1f6357", @"Dark Hot Pink":@"d90166", @"Dark Indigo":@"1f0954", @"Dark Khaki":@"9b8f55", @"Dark Lavender":@"856798", @"Dark Lilac":@"9c6da5", @"Dark Lime":@"84b701", @"Dark Lime Green":@"7ebd01", @"Dark Magenta":@"960056", @"Dark Maroon":@"3c0008", @"Dark Mauve":@"874c62", @"Dark Mint":@"48c072", @"Dark Mint Green":@"20c073", @"Dark Mustard":@"a88905", @"Dark Navy":@"000435", @"Dark Navy Blue":@"00022e", @"Dark Olive":@"373e02", @"Dark Olive Green":@"3c4d03", @"Dark Orange":@"c65102", @"Dark Pastel Green":@"56ae57", @"Dark Peach":@"de7e5d", @"Dark Periwinkle":@"665fd1", @"Dark Pink":@"cb416b", @"Dark Plum":@"3f012c", @"Dark Purple":@"35063e", @"Dark Red":@"840000", @"Dark Rose":@"b5485d", @"Dark Royal Blue":@"02066f", @"Dark Sage":@"598556", @"Dark Salmon":@"c85a53", @"Dark Sand":@"a88f59", @"Dark Sea Foam":@"1fb57a", @"Dark Sea Foam Green":@"3eaf76", @"Dark Sea Green":@"11875d", @"Dark Sky Blue":@"448ee4", @"Dark Slate Blue":@"214761", @"Dark Tan":@"af884a", @"Dark Taupe":@"7f684e", @"Dark Teal":@"014d4e", @"Dark Turquoise":@"045c5a", @"Dark Violet":@"34013f", @"Dark Yellow":@"d5b60a", @"Dark Yellow Green":@"728f02", @"Darkish Blue":@"014182", @"Darkish Green":@"287c37", @"Darkish Pink":@"da467d", @"Darkish Purple":@"751973", @"Darkish Red":@"a90308", @"Deep Aqua":@"08787f", @"Deep Blue":@"040273", @"Deep Brown":@"410200", @"Deep Green":@"02590f", @"Deep Lavender":@"8d5eb7", @"Deep Lilac":@"966ebd", @"Deep Magenta":@"a0025c", @"Deep Orange":@"dc4d01", @"Deep Pink":@"cb0162", @"Deep Purple":@"36013f", @"Deep Red":@"9a0200", @"Deep Rose":@"c74767", @"Deep Sea Blue":@"015482", @"Deep Sky Blue":@"0d75f8", @"Deep Teal":@"00555a", @"Deep Turquoise":@"017374", @"Deep Violet":@"490648", @"Denim":@"3b638c", @"Denim Blue":@"3b5b92", @"Desert":@"ccad60", @"Diarrhea":@"9f8303", @"Dirt":@"8a6e45", @"Dirt Brown":@"836539", @"Dirty Blue":@"3f829d", @"Dirty Green":@"667e2c", @"Dirty Orange":@"c87606", @"Dirty Pink":@"ca7b80", @"Dirty Purple":@"734a65", @"Dirty Yellow":@"cdc50a", @"Dodger Blue":@"3e82fc", @"Drab":@"828344", @"Drab Green":@"749551", @"Dried Blood":@"4b0101", @"Duck Egg Blue":@"c3fbf4", @"Dull Blue":@"49759c", @"Dull Brown":@"876e4b", @"Dull Green":@"74a662", @"Dull Orange":@"d8863b", @"Dull Pink":@"d5869d", @"Dull Purple":@"84597e", @"Dull Red":@"bb3f3f", @"Dull Teal":@"5f9e8f", @"Dull Yellow":@"eedc5b", @"Dusk":@"4e5481", @"Dusk Blue":@"26538d", @"Dusky Blue":@"475f94", @"Dusky Pink":@"cc7a8b", @"Dusky Purple":@"895b7b", @"Dusky Rose":@"ba6873", @"Dust":@"b2996e", @"Dusty Blue":@"5a86ad", @"Dusty Green":@"76a973", @"Dusty Lavender":@"ac86a8", @"Dusty Orange":@"f0833a", @"Dusty Pink":@"d58a94", @"Dusty Purple":@"825f87", @"Dusty Red":@"b9484e", @"Dusty Rose":@"c0737a", @"Dusty Teal":@"4c9085", @"Earth":@"a2653e", @"Easter Green":@"8cfd7e", @"Easter Purple":@"c071fe", @"Ecru":@"feffca", @"Egg Shell":@"fffcc4", @"Eggplant":@"380835", @"Eggplant Purple":@"430541", @"Eggshell":@"ffffd4", @"Eggshell Blue":@"c4fff7", @"Electric Blue":@"0652ff", @"Electric Green":@"21fc0d", @"Electric Lime":@"a8ff04", @"Electric Pink":@"ff0490", @"Electric Purple":@"aa23ff", @"Emerald":@"01a049", @"Emerald Green":@"028f1e", @"Evergreen":@"05472a", @"Faded Blue":@"658cbb", @"Faded Green":@"7bb274", @"Faded Orange":@"f0944d", @"Faded Pink":@"de9dac", @"Faded Purple":@"916e99", @"Faded Red":@"d3494e", @"Faded Yellow":@"feff7f", @"Fawn":@"cfaf7b", @"Fern":@"63a950", @"Fern Green":@"548d44", @"Fire Engine Red":@"fe0002", @"Flat Blue":@"3c73a8", @"Flat Green":@"699d4c", @"Fluorescent Green":@"0aff02", @"Foam Green":@"90fda9", @"Forest":@"0b5509", @"Forest Green":@"06470c", @"Forrest Green":@"154406", @"French Blue":@"436bad", @"Fresh Green":@"69d84f", @"Frog Green":@"58bc08", @"Fuchsia":@"ed0dd9", @"Gold":@"dbb40c", @"Golden":@"f5bf03", @"Golden Brown":@"b27a01", @"Golden Rod":@"f9bc08", @"Golden Yellow":@"fec615", @"Goldenrod":@"fac205", @"Grape":@"6c3461", @"Grape Purple":@"5d1451", @"Grapefruit":@"fd5956", @"Grass":@"5cac2d", @"Grass Green":@"3f9b0b", @"Grassy Green":@"419c03", @"Gray":@"929591", @"Gray Blue":@"77a1b5", @"Gray Brown":@"7a6a4f", @"Gray Green":@"82a67d", @"Gray Pink":@"c3909b", @"Gray Purple":@"826d8c", @"Gray Teal":@"5e9b8a", @"Gray/Blue":@"647d8e", @"Gray/Green":@"86a17d", @"Grayish":@"a8a495", @"Green":@"15b01a", @"Green Apple":@"5edc1f", @"Green Blue":@"23c48b", @"Green Brown":@"696006", @"Green Gray":@"7ea07a", @"Green Teal":@"0cb577", @"Green Yellow":@"c6f808", @"Green/Blue":@"01c08d", @"Green/Yellow":@"b5ce08", @"Greenish":@"40a368", @"Greenish Beige":@"c9d179", @"Greenish Blue":@"0b8b87", @"Greenish Brown":@"696112", @"Greenish Cyan":@"2afeb7", @"Greenish Gray":@"96ae8d", @"Greenish Tan":@"bccb7a", @"Greenish Teal":@"32bf84", @"Greenish Turquoise":@"00fbb0", @"Greenish Yellow":@"cdfd02", @"Gross Green":@"a0bf16", @"Gunmetal":@"536267", @"Hazel":@"8e7618", @"Heather":@"a484ac", @"Heliotrope":@"d94ff5", @"Highlighter Green":@"1bfc06", @"Hospital Green":@"9be5aa", @"Hot Green":@"25ff29", @"Hot Magenta":@"f504c9", @"Hot Pink":@"ff028d", @"Hot Purple":@"cb00f5", @"Hunter Green":@"0b4008", @"Ice":@"d6fffa", @"Ice Blue":@"d7fffe", @"Icky Green":@"8fae22", @"Indian Red":@"850e04", @"Indigo":@"380282", @"Indigo Blue":@"3a18b1", @"Iris":@"6258c4", @"Irish Green":@"019529", @"Ivory":@"ffffcb", @"Jade":@"1fa774", @"Jade Green":@"2baf6a", @"Jungle Green":@"048243", @"Kelley Green":@"009337", @"Kelly Green":@"02ab2e", @"Kermit Green":@"5cb200", @"Key Lime":@"aeff6e", @"Khaki":@"aaa662", @"Khaki Green":@"728639", @"Kiwi":@"9cef43", @"Kiwi Green":@"8ee53f", @"Lavender":@"c79fef", @"Lavender Blue":@"8b88f8", @"Lavender Pink":@"dd85d7", @"Lawn Green":@"4da409", @"Leaf":@"71aa34", @"Leaf Green":@"5ca904", @"Leafy Green":@"51b73b", @"Leather":@"ac7434", @"Lemon":@"fdff52", @"Lemon Green":@"adf802", @"Lemon Lime":@"bffe28", @"Lemon Yellow":@"fdff38", @"Lichen":@"8fb67b", @"Light Aqua":@"8cffdb", @"Light Aquamarine":@"7bfdc7", @"Light Beige":@"fffeb6", @"Light Blue":@"7bc8f6", @"Light Blue Gray":@"b7c9e2", @"Light Blue Green":@"7efbb3", @"Light Bluish Green":@"76fda8", @"Light Bright Green":@"53fe5c", @"Light Brown":@"ad8150", @"Light Burgundy":@"a8415b", @"Light Cyan":@"acfffc", @"Light Eggplant":@"894585", @"Light Forest Green":@"4f9153", @"Light Gold":@"fddc5c", @"Light Grass Green":@"9af764", @"Light Gray":@"d8dcd6", @"Light Gray Blue":@"9dbcd4", @"Light Gray Green":@"b7e1a1", @"Light Green":@"76ff7b", @"Light Green Blue":@"56fca2", @"Light Greenish Blue":@"63f7b4", @"Light Indigo":@"6d5acf", @"Light Khaki":@"e6f2a2", @"Light Lavender":@"efc0fe", @"Light Light Blue":@"cafffb", @"Light Light Green":@"c8ffb0", @"Light Lilac":@"edc8ff", @"Light Lime":@"aefd6c", @"Light Lime Green":@"b9ff66", @"Light Magenta":@"fa5ff7", @"Light Maroon":@"a24857", @"Light Mauve":@"c292a1", @"Light Mint":@"b6ffbb", @"Light Mint Green":@"a6fbb2", @"Light Moss Green":@"a6c875", @"Light Mustard":@"f7d560", @"Light Navy":@"155084", @"Light Navy Blue":@"2e5a88", @"Light Neon Green":@"4efd54", @"Light Olive":@"acbf69", @"Light Olive Green":@"a4be5c", @"Light Orange":@"fdaa48", @"Light Pastel Green":@"b2fba5", @"Light Pea Green":@"c4fe82", @"Light Peach":@"ffd8b1", @"Light Periwinkle":@"c1c6fc", @"Light Pink":@"ffd1df", @"Light Plum":@"9d5783", @"Light Purple":@"b36ff6", @"Light Red":@"ff474c", @"Light Rose":@"ffc5cb", @"Light Royal Blue":@"3a2efe", @"Light Sage":@"bcecac", @"Light Salmon":@"fea993", @"Light Sea Foam":@"a0febf", @"Light Sea Foam Green":@"a7ffb5", @"Light Sea Green":@"98f6b0", @"Light Sky Blue":@"c6fcff", @"Light Tan":@"fbeeac", @"Light Teal":@"90e4c1", @"Light Turquoise":@"7ef4cc", @"Light Violet":@"d6b4fc", @"Light Yellow":@"fffe7a", @"Light Yellow Green":@"ccfd7f", @"Light Yellowish Green":@"c2ff89", @"Lighter Green":@"75fd63", @"Lighter Purple":@"a55af4", @"Lightish Blue":@"3d7afd", @"Lightish Green":@"61e160", @"Lightish Purple":@"a552e6", @"Lightish Red":@"fe2f4a", @"Lilac":@"c48efd", @"Lime":@"aaff32", @"Lime Green":@"89fe05", @"Lime Yellow":@"d0fe1d", @"Lipstick":@"d5174e", @"Lipstick Red":@"c0022f", @"Macaroni And Cheese":@"efb435", @"Magenta":@"c20078", @"Mahogany":@"4a0100", @"Maize":@"f4d054", @"Mango":@"ffa62b", @"Manilla":@"fffa86", @"Marigold":@"fcc006", @"Marine":@"042e60", @"Marine Blue":@"01386a", @"Maroon":@"650021", @"Mauve":@"ae7181", @"Medium Blue":@"2c6fbb", @"Medium Brown":@"7f5112", @"Medium Gray":@"7d7f7c", @"Medium Green":@"39ad48", @"Medium Pink":@"f36196", @"Medium Purple":@"9e43a2", @"Melon":@"ff7855", @"Merlot":@"730039", @"Metallic Blue":@"4f738e", @"Mid Blue":@"276ab3", @"Mid Green":@"50a747", @"Midnight":@"03012d", @"Midnight Blue":@"020035", @"Midnight Purple":@"280137", @"Military Green":@"667c3e", @"Milk Chocolate":@"7f4e1e", @"Mint":@"9ffeb0", @"Mint Green":@"8fff9f", @"Minty Green":@"0bf77d", @"Mocha":@"9d7651", @"Moss":@"769958", @"Moss Green":@"658b38", @"Mossy Green":@"638b27", @"Mud":@"735c12", @"Mud Brown":@"60460f", @"Mud Green":@"606602", @"Muddy Brown":@"886806", @"Muddy Green":@"657432", @"Muddy Yellow":@"bfac05", @"Mulberry":@"920a4e", @"Murky Green":@"6c7a0e", @"Mushroom":@"ba9e88", @"Mustard":@"ceb301", @"Mustard Brown":@"ac7e04", @"Mustard Green":@"a8b504", @"Mustard Yellow":@"d2bd0a", @"Muted Blue":@"3b719f", @"Muted Green":@"5fa052", @"Muted Pink":@"d1768f", @"Muted Purple":@"805b87", @"Nasty Green":@"70b23f", @"Navy":@"01153e", @"Navy Blue":@"001146", @"Navy Green":@"35530a", @"Neon Blue":@"04d9ff", @"Neon Green":@"0cff0c", @"Neon Pink":@"fe019a", @"Neon Purple":@"bc13fe", @"Neon Red":@"ff073a", @"Neon Yellow":@"cfff04", @"Nice Blue":@"107ab0", @"Night Blue":@"040348", @"Ocean":@"017b92", @"Ocean Blue":@"03719c", @"Ocean Green":@"3d9973", @"Ocher":@"bf9b0c", @"Ochre":@"c69c04", @"Off Blue":@"5684ae", @"Off Green":@"6ba353", @"Off White":@"ffffe4", @"Off Yellow":@"f1f33f", @"Old Pink":@"c77986", @"Old Rose":@"c87f89", @"Olive":@"6e750e", @"Olive Brown":@"645403", @"Olive Drab":@"6f7632", @"Olive Green":@"677a04", @"Olive Yellow":@"c2b709", @"Orange":@"f97306", @"Orange Brown":@"be6400", @"Orange Pink":@"ff6f52", @"Orange Red":@"fe420f", @"Orange Yellow":@"ffad01", @"Orangeish":@"fd8d49", @"Orangey Brown":@"b16002", @"Orangey Red":@"fa4224", @"Orangey Yellow":@"fdb915", @"Orangish":@"fc824a", @"Orangish Brown":@"b25f03", @"Orangish Red":@"f43605", @"Orchid":@"c875c4", @"Pale":@"fff9d0", @"Pale Aqua":@"b8ffeb", @"Pale Blue":@"d0fefe", @"Pale Brown":@"b1916e", @"Pale Cyan":@"b7fffa", @"Pale Gold":@"fdde6c", @"Pale Gray":@"fdfdfe", @"Pale Green":@"c7fdb5", @"Pale Lavender":@"eecffe", @"Pale Light Green":@"b1fc99", @"Pale Lilac":@"e4cbff", @"Pale Lime":@"befd73", @"Pale Lime Green":@"b1ff65", @"Pale Magenta":@"d767ad", @"Pale Mauve":@"fed0fc", @"Pale Olive":@"b9cc81", @"Pale Olive Green":@"b1d27b", @"Pale Orange":@"ffa756", @"Pale Peach":@"ffe5ad", @"Pale Pink":@"ffcfdc", @"Pale Purple":@"b790d4", @"Pale Red":@"d9544d", @"Pale Rose":@"fdc1c5", @"Pale Salmon":@"ffb19a", @"Pale Sky Blue":@"bdf6fe", @"Pale Teal":@"82cbb2", @"Pale Turquoise":@"a5fbd5", @"Pale Violet":@"ceaefa", @"Pale Yellow":@"ffff84", @"Parchment":@"fefcaf", @"Pastel Blue":@"a2bffe", @"Pastel Green":@"b0ff9d", @"Pastel Orange":@"ff964f", @"Pastel Pink":@"ffbacd", @"Pastel Purple":@"caa0ff", @"Pastel Red":@"db5856", @"Pastel Yellow":@"fffe71", @"Pea":@"a4bf20", @"Pea Green":@"8eab12", @"Pea Soup":@"929901", @"Pea Soup Green":@"94a617", @"Peach":@"ffb07c", @"Peachy Pink":@"ff9a8a", @"Peacock Blue":@"016795", @"Pear":@"cbf85f", @"Periwinkle":@"8f8ce7", @"Periwinkle Blue":@"8f99fb", @"Petrol":@"005f6a", @"Pig Pink":@"e78ea5", @"Pine":@"2b5d34", @"Pine Green":@"0a481e", @"Pink":@"ff81c0", @"Pink Purple":@"db4bda", @"Pink Red":@"f5054f", @"Pink/Purple":@"ef1de7", @"Pinkish":@"d46a7e", @"Pinkish Brown":@"b17261", @"Pinkish Gray":@"c8aca9", @"Pinkish Orange":@"ff724c", @"Pinkish Purple":@"d648d7", @"Pinkish Red":@"f10c45", @"Pinkish Tan":@"d99b82", @"Pinky":@"fc86aa", @"Pinky Purple":@"c94cbe", @"Pinky Red":@"fc2647", @"Piss Yellow":@"ddd618", @"Pistachio":@"c0fa8b", @"Plum":@"580f41", @"Plum Purple":@"4e0550", @"Poison Green":@"40fd14", @"Poo":@"8f7303", @"Poo Brown":@"885f01", @"Poop":@"7f5f00", @"Poop Brown":@"7a5901", @"Poop Green":@"758000", @"Powder Blue":@"b1d1fc", @"Powder Pink":@"ffb2d0", @"Primary Blue":@"0804f9", @"Prussian Blue":@"004577", @"Puce":@"a57e52", @"Puke":@"a5a502", @"Puke Brown":@"947706", @"Puke Green":@"9aae07", @"Puke Yellow":@"c2be0e", @"Pumpkin":@"e17701", @"Pumpkin Orange":@"fb7d07", @"Pure Blue":@"0203e2", @"Purple":@"8756e4", @"Purple Blue":@"6140ef", @"Purple Brown":@"673a3f", @"Purple Gray":@"947e94", @"Purple Pink":@"df4ec8", @"Purple Red":@"990147", @"Purple/Blue":@"5d21d0", @"Purple/Pink":@"d725de", @"Purpleish":@"98568d", @"Purplish":@"94568c", @"Purply":@"983fb2", @"Purply Blue":@"661aee", @"Purply Pink":@"f075e6", @"Putty":@"beae8a", @"Racing Green":@"014600", @"Radioactive Green":@"2cfa1f", @"Raspberry":@"b00149", @"Raw Sienna":@"9a6200", @"Raw Umber":@"a75e09", @"Really Light Blue":@"d4ffff", @"Red":@"e50000", @"Red Brown":@"8b2e16", @"Red Orange":@"fd3c06", @"Red Pink":@"fa2a55", @"Red Purple":@"820747", @"Red Violet":@"9e0168", @"Red Wine":@"8c0034", @"Reddish":@"c44240", @"Reddish Brown":@"7f2b0a", @"Reddish Gray":@"997570", @"Reddish Orange":@"f8481c", @"Reddish Pink":@"fe2c54", @"Reddish Purple":@"910951", @"Reddy Brown":@"6e1005", @"Rich Blue":@"021bf9", @"Rich Purple":@"720058", @"Robin Egg Blue":@"8af1fe", @"Robin's Egg":@"6dedfd", @"Robin's Egg Blue":@"98eff9", @"Rosa":@"fe86a4", @"Rose":@"cf6275", @"Rose Pink":@"f7879a", @"Rose Red":@"be013c", @"Rosy Pink":@"f6688e", @"Rouge":@"ab1239", @"Royal":@"0c1793", @"Royal Blue":@"0504aa", @"Royal Purple":@"4b006e", @"Ruby":@"ca0147", @"Russet":@"a13905", @"Rust":@"a83c09", @"Rust Brown":@"8b3103", @"Rust Orange":@"c45508", @"Rust Red":@"aa2704", @"Rusty Orange":@"cd5909", @"Rusty Red":@"af2f0d", @"Saffron":@"feb209", @"Sage":@"87ae73", @"Sage Green":@"88b378", @"Salmon":@"ff796c", @"Salmon Pink":@"fe7b7c", @"Sand":@"e2ca76", @"Sand Brown":@"cba560", @"Sand Yellow":@"fce166", @"Sandstone":@"c9ae74", @"Sandy":@"f1da7a", @"Sandy Brown":@"c4a661", @"Sandy Yellow":@"fdee73", @"Sap Green":@"5c8b15", @"Sapphire":@"2138ab", @"Scarlet":@"be0119", @"Sea":@"3c9992", @"Sea Blue":@"047495", @"Sea Foam":@"80f9ad", @"Sea Foam Blue":@"78d1b6", @"Sea Foam Green":@"7af9ab", @"Sea Green":@"53fca1", @"Seaweed":@"18d17b", @"Seaweed Green":@"35ad6b", @"Sepia":@"985e2b", @"Shamrock":@"01b44c", @"Shamrock Green":@"02c14d", @"Shocking Pink":@"fe02a2", @"Sick Green":@"9db92c", @"Sickly Green":@"94b21c", @"Sickly Yellow":@"d0e429", @"Sienna":@"a9561e", @"Silver":@"c5c9c7", @"Sky":@"82cafc", @"Sky Blue":@"75bbfd", @"Slate":@"516572", @"Slate Blue":@"5b7c99", @"Slate Gray":@"59656d", @"Slate Green":@"658d6d", @"Slime Green":@"99cc04", @"Snot":@"acbb0d", @"Snot Green":@"9dc100", @"Soft Blue":@"6488ea", @"Soft Green":@"6fc276", @"Soft Pink":@"fdb0c0", @"Soft Purple":@"a66fb5", @"Spearmint":@"1ef876", @"Spring Green":@"a9f971", @"Spruce":@"0a5f38", @"Squash":@"f2ab15", @"Steel":@"738595", @"Steel Blue":@"5a7d9a", @"Steel Gray":@"6f828a", @"Stone":@"ada587", @"Stormy Blue":@"507b9c", @"Straw":@"fcf679", @"Strawberry":@"fb2943", @"Strong Blue":@"0c06f7", @"Strong Pink":@"ff0789", @"Sun Yellow":@"ffdf22", @"Sunflower":@"ffc512", @"Sunflower Yellow":@"ffda03", @"Sunny Yellow":@"fff917", @"Sunshine Yellow":@"fffd37", @"Swamp":@"698339", @"Swamp Green":@"748500", @"Tan":@"d1b26f", @"Tan Brown":@"ab7e4c", @"Tan Green":@"a9be70", @"Tangerine":@"ff9408", @"Taupe":@"c7ac7d", @"Tea":@"65ab7c", @"Tea Green":@"bdf8a3", @"Teal":@"24bca8", @"Teal Blue":@"01889f", @"Teal Green":@"0cdc73", @"Terra Cotta":@"cb6843", @"Tiffany Blue":@"7bf2da", @"Tomato":@"ef4026", @"Tomato Red":@"ec2d01", @"Topaz":@"13bbaf", @"Toxic Green":@"61de2a", @"Tree Green":@"2a7e19", @"True Blue":@"010fcc", @"True Green":@"089404", @"Turquoise":@"06c2ac", @"Turquoise Blue":@"06b1c4", @"Turquoise Green":@"04f489", @"Turtle Green":@"75b84f", @"Twilight":@"4e518b", @"Twilight Blue":@"0a437a", @"Ugly Blue":@"31668a", @"Ugly Brown":@"7d7103", @"Ugly Green":@"7a9703", @"Ugly Pink":@"cd7584", @"Ugly Purple":@"a442a0", @"Ugly Yellow":@"d0c101", @"Ultramarine":@"2000b1", @"Ultramarine Blue":@"1805db", @"Umber":@"b26400", @"Velvet":@"750851", @"Vermillion":@"f4320c", @"Very Dark Blue":@"000133", @"Very Dark Brown":@"1d0200", @"Very Dark Green":@"062e03", @"Very Dark Purple":@"2a0134", @"Very Light Blue":@"d5ffff", @"Very Light Brown":@"d3b683", @"Very Light Green":@"d1ffbd", @"Very Light Pink":@"fff4f2", @"Very Light Purple":@"f6cefc", @"Very Pale Blue":@"d6fffe", @"Very Pale Green":@"cffdbc", @"Vibrant Blue":@"0339f8", @"Vibrant Green":@"0add08", @"Vibrant Purple":@"ad03de", @"Violet":@"9a0eea", @"Violet Blue":@"510ac9", @"Violet Pink":@"fb5ffc", @"Violet Red":@"a50055", @"Viridian":@"1e9167", @"Vivid Blue":@"152eff", @"Vivid Green":@"2fef10", @"Vivid Purple":@"9900fa", @"Vomit":@"a2a415", @"Vomit Green":@"89a203", @"Vomit Yellow":@"c7c10c", @"Warm Blue":@"4b57db", @"Warm Brown":@"964e02", @"Warm Gray":@"978a84", @"Warm Pink":@"fb5581", @"Warm Purple":@"952e8f", @"Washed Out Green":@"bcf5a6", @"Water Blue":@"0e87cc", @"Watermelon":@"fd4659", @"Weird Green":@"3ae57f", @"Wheat":@"fbdd7e", @"White":@"ffffff", @"Windows Blue":@"3778bf", @"Wine":@"80013f", @"Wine Red":@"7b0323", @"Wintergreen":@"20f986", @"Wisteria":@"a87dc2", @"Yellow":@"ffff14", @"Yellow Brown":@"b79400", @"Yellow Green":@"bbf90f", @"Yellow Ochre":@"cb9d06", @"Yellow Orange":@"fcb001", @"Yellow Tan":@"ffe36e", @"Yellow/Green":@"c8fd3d", @"Yellowish":@"faee66", @"Yellowish Brown":@"9b7a01", @"Yellowish Green":@"b0dd16", @"Yellowish Orange":@"ffab0f", @"Yellowish Tan":@"fcfc81", @"Yellowy Brown":@"ae8b0c", @"Yellowy Green":@"bff128", };
    
#define PSEUDOPAN    1
    
#if PSEUDOPAN == 0
    // http://www.ackerdesign.com/acker-design-pantone-chart.html
    NSDictionary *pseudoPantone = @{@"100":@"#F4ED7C", @"101":@"#F4ED47", @"102":@"#F9E814", @"103":@"#C6AD0F", @"104":@"#AD9B0C", @"105":@"#82750F", @"106":@"#F7E859", @"107":@"#F9E526", @"108":@"#F9DD16", @"109":@"#F9D616", @"110":@"#D8B511", @"111":@"#AA930A", @"112":@"#99840A", @"113":@"#F9E55B", @"114":@"#F9E24C", @"115":@"#F9E04C", @"116":@"#FCD116", @"116_2X":@"#F7B50C", @"117":@"#C6A00C", @"118":@"#AA8E0A", @"119":@"#897719", @"120":@"#F9E27F", @"1205":@"#F7E8AA", @"121":@"#F9E070", @"1215":@"#F9E08C", @"122":@"#FCD856", @"1225":@"#FFCC49", @"123":@"#FFC61E", @"1235":@"#FCB514", @"124":@"#E0AA0F", @"1245":@"#BF910C", @"125":@"#B58C0A", @"1255":@"#A37F14", @"126":@"#A38205", @"1265":@"#7C6316", @"127":@"#F4E287", @"128":@"#F4DB60", @"129":@"#F2D13D", @"130":@"#EAAF0F", @"130_2X":@"#E29100", @"131":@"#C6930A", @"132":@"#9E7C0A", @"133":@"#705B0A", @"134":@"#FFD87F", @"1345":@"#FFD691", @"135":@"#FCC963", @"1355":@"#FCCE87", @"136":@"#FCBF49", @"1365":@"#FCBA5E", @"137":@"#FCA311", @"1375":@"#F99B0C", @"138":@"#D88C02", @"1385":@"#CC7A02", @"139":@"#AF7505", @"1395":@"#996007", @"140":@"#7A5B11", @"1405":@"#6B4714", @"141":@"#F2CE68", @"142":@"#F2BF49", @"143":@"#EFB22D", @"144":@"#E28C05", @"145":@"#C67F07", @"146":@"#9E6B05", @"147":@"#725E26", @"148":@"#FFD69B", @"1485":@"#FFB777", @"149":@"#FCCC93", @"1495":@"#FF993F", @"150":@"#FCAD56", @"1505":@"#F47C00", @"151":@"#F77F00", @"152":@"#DD7500", @"1525":@"#B55400", @"153":@"#BC6D0A", @"1535":@"#8C4400", @"154":@"#995905", @"1545":@"#472200", @"155":@"#F4DBAA", @"1555":@"#F9BF9E", @"156":@"#F2C68C", @"1565":@"#FCA577", @"157":@"#EDA04F", @"1575":@"#FC8744", @"158":@"#E87511", @"1585":@"#F96B07", @"159":@"#C66005", @"1595":@"#D15B05", @"160":@"#9E540A", @"1605":@"#A04F11", @"161":@"#633A11", @"1615":@"#843F0F", @"162":@"#F9C6AA", @"1625":@"#F9A58C", @"163":@"#FC9E70", @"1635":@"#F98E6D", @"164":@"#FC7F3F", @"1645":@"#F97242", @"165":@"#F96302", @"165_2X":@"#EA4F00", @"1655":@"#F95602", @"166":@"#DD5900", @"1665":@"#DD4F05", @"167":@"#BC4F07", @"1675":@"#A53F0F", @"168":@"#6D3011", @"1685":@"#843511", @"169":@"#F9BAAA", @"170":@"#F98972", @"171":@"#F9603A", @"172":@"#F74902", @"173":@"#D14414", @"174":@"#933311", @"175":@"#6D3321", @"176":@"#F9AFAD", @"1765":@"#F99EA3", @"1767":@"#F9B2B7", @"177":@"#F9827F", @"1775":@"#F9848E", @"1777":@"#FC6675", @"178":@"#F95E59", @"1785":@"#FC4F59", @"1787":@"#F43F4F", @"1788":@"#EF2B2D", @"1788_2X":@"#D62100", @"179":@"#E23D28", @"1795":@"#D62828", @"1797":@"#CC2D30", @"180":@"#C13828", @"1805":@"#AF2626", @"1807":@"#A03033", @"181":@"#7C2D23", @"1810":@"#7C211E", @"1817":@"#5B2D28", @"182":@"#F9BFC1", @"183":@"#FC8C99", @"184":@"#FC5E72", @"185":@"#E8112D", @"185_2X":@"#D11600", @"186":@"#CE1126", @"187":@"#AF1E2D", @"188":@"#7C2128", @"189":@"#FFA3B2", @"1895":@"#FCBFC9", @"190":@"#FC758E", @"1905":@"#FC9BB2", @"191":@"#F4476B", @"1915":@"#F4547C", @"192":@"#E5053A", @"1925":@"#E00747", @"193":@"#C40043", @"1935":@"#C10538", @"194":@"#992135", @"1945":@"#A80C35", @"1955":@"#931638", @"196":@"#FAD5E1", @"197":@"#F6A5BE", @"198":@"#EF5B84", @"199":@"#A0274B", @"200":@"#C41E3A", @"201":@"#A32638", @"202":@"#8C2633", @"203":@"#F2AFC1", @"204":@"#ED7A9E", @"205":@"#E54C7C", @"206":@"#D30547", @"207":@"#C0004E", @"208":@"#8E2344", @"209":@"#75263D", @"210":@"#FFA0BF", @"211":@"#FF77A8", @"212":@"#F94F8E", @"213":@"#EA0F6B", @"214":@"#CC0256", @"215":@"#A50544", @"216":@"#7C1E3F", @"217":@"#F4BFD1", @"218":@"#ED72AA", @"219":@"#E22882", @"220":@"#AA004F", @"221":@"#930042", @"222":@"#70193D", @"223":@"#F993C4", @"224":@"#F46BAF", @"225":@"#ED2893", @"226":@"#D60270", @"227":@"#AD005B", @"228":@"#8C004C", @"229":@"#6D213F", @"230":@"#FFA0CC", @"231":@"#FC70BA", @"232":@"#F43FA5", @"233":@"#CE007C", @"234":@"#AA0066", @"235":@"#8E0554", @"236":@"#F9AFD3", @"2365":@"#F7C4D8", @"237":@"#F484C4", @"2375":@"#EA6BBF", @"238":@"#ED4FAF", @"2385":@"#DB28A5", @"239":@"#E0219E", @"2395":@"#C4008C", @"240":@"#C40F89", @"2405":@"#A8007A", @"241":@"#AD0075", @"2415":@"#9B0070", @"242":@"#7C1C51", @"2425":@"#87005B", @"243":@"#F2BAD8", @"244":@"#EDA0D3", @"245":@"#E87FC9", @"246":@"#CC00A0", @"247":@"#B7008E", @"248":@"#A3057F", @"249":@"#7F2860", @"250":@"#EDC4DD", @"251":@"#E29ED6", @"252":@"#D36BC6", @"253":@"#AF23A5", @"254":@"#A02D96", @"255":@"#772D6B", @"256":@"#E5C4D6", @"2562":@"#D8A8D8", @"2563":@"#D1A0CC", @"2567":@"#BF93CC", @"257":@"#D3A5C9", @"2572":@"#C687D1", @"2573":@"#BA7CBC", @"2577":@"#AA72BF", @"258":@"#9B4F96", @"2582":@"#AA47BA", @"2583":@"#9E4FA5", @"2587":@"#8E47AD", @"259":@"#72166B", @"2592":@"#930FA5", @"2593":@"#872B93", @"2597":@"#66008C", @"260":@"#681E5B", @"2602":@"#820C8E", @"2603":@"#70147A", @"2607":@"#5B027A", @"261":@"#5E2154", @"2612":@"#701E72", @"2613":@"#66116D", @"2617":@"#560C70", @"262":@"#542344", @"2622":@"#602D59", @"2623":@"#5B195E", @"2627":@"#4C145E", @"263":@"#E0CEE0", @"2635":@"#C9ADD8", @"264":@"#C6AADB", @"2645":@"#B591D1", @"265":@"#9663C4", @"2655":@"#9B6DC6", @"266":@"#6D28AA", @"2665":@"#894FBF", @"267":@"#59118E", @"268":@"#4F2170", @"2685":@"#56008C", @"269":@"#442359", @"2695":@"#44235E", @"270":@"#BAAFD3", @"2705":@"#AD9ED3", @"2706":@"#D1CEDD", @"2707":@"#BFD1E5", @"2708":@"#AFBCDB", @"271":@"#9E91C6", @"2715":@"#937ACC", @"2716":@"#A5A0D6", @"2717":@"#A5BAE0", @"2718":@"#5B77CC", @"272":@"#8977BA", @"2725":@"#7251BC", @"2726":@"#6656BC", @"2727":@"#5E68C4", @"2728":@"#3044B5", @"273":@"#38197A", @"2735":@"#4F0093", @"2736":@"#4930AD", @"2738":@"#2D008E", @"274":@"#2B1166", @"2745":@"#3F0077", @"2746":@"#3F2893", @"2747":@"#1C146B", @"2748":@"#1E1C77", @"275":@"#260F54", @"2755":@"#35006D", @"2756":@"#332875", @"2757":@"#141654", @"2758":@"#192168", @"276":@"#2B2147", @"2765":@"#2B0C56", @"2766":@"#2B265B", @"2767":@"#14213D", @"2768":@"#112151", @"277":@"#B5D1E8", @"278":@"#99BADD", @"279":@"#6689CC", @"280":@"#002B7F", @"281":@"#002868", @"282":@"#002654", @"283":@"#9BC4E2", @"284":@"#75AADB", @"285":@"#3A75C4", @"286":@"#0038A8", @"287":@"#003893", @"288":@"#00337F", @"289":@"#002649", @"290":@"#C4D8E2", @"2905":@"#93C6E0", @"291":@"#A8CEE2", @"2915":@"#60AFDD", @"292":@"#75B2DD", @"2925":@"#008ED6", @"293":@"#0051BA", @"2935":@"#005BBF", @"294":@"#003F87", @"2945":@"#0054A0", @"295":@"#00386B", @"2955":@"#003D6B", @"296":@"#002D47", @"2965":@"#00334C", @"297":@"#82C6E2", @"2975":@"#BAE0E2", @"298":@"#51B5E0", @"2985":@"#51BFE2", @"299":@"#00A3DD", @"2995":@"#00A5DB", @"300":@"#0072C6", @"3005":@"#0084C9", @"301":@"#005B99", @"3015":@"#00709E", @"302":@"#004F6D", @"3025":@"#00546B", @"303":@"#003F54", @"3035":@"#004454", @"304":@"#A5DDE2", @"305":@"#70CEE2", @"306":@"#00BCE2", @"306_2X":@"#00A3D1", @"307":@"#007AA5", @"308":@"#00607C", @"309":@"#003F49", @"310":@"#72D1DD", @"3105":@"#7FD6DB", @"311":@"#28C4D8", @"3115":@"#2DC6D6", @"312":@"#00ADC6", @"3125":@"#00B7C6", @"313":@"#0099B5", @"3135":@"#009BAA", @"314":@"#00829B", @"3145":@"#00848E", @"315":@"#006B77", @"3155":@"#006D75", @"316":@"#00494F", @"3165":@"#00565B", @"317":@"#C9E8DD", @"318":@"#93DDDB", @"319":@"#4CCED1", @"320":@"#009EA0", @"320_2X":@"#007F82", @"321":@"#008789", @"322":@"#007272", @"323":@"#006663", @"324":@"#AADDD6", @"3242":@"#87DDD1", @"3245":@"#8CE0D1", @"3248":@"#7AD3C1", @"325":@"#56C9C1", @"3252":@"#56D6C9", @"3255":@"#47D6C1", @"3258":@"#35C4AF", @"326":@"#00B2AA", @"3262":@"#00C1B5", @"3265":@"#00C6B2", @"3268":@"#00AF99", @"327":@"#008C82", @"327_2X":@"#008977", @"3272":@"#00AA9E", @"3275":@"#00B2A0", @"3278":@"#009B84", @"328":@"#007770", @"3282":@"#008C82", @"3285":@"#009987", @"3288":@"#008270", @"329":@"#006D66", @"3292":@"#006056", @"3295":@"#008272", @"3298":@"#006B5B", @"330":@"#005951", @"3302":@"#00493F", @"3305":@"#004F42", @"3308":@"#004438", @"331":@"#BAEAD6", @"332":@"#A0E5CE", @"333":@"#5EDDC1", @"334":@"#00997C", @"335":@"#007C66", @"336":@"#006854", @"337":@"#9BDBC1", @"3375":@"#8EE2BC", @"338":@"#7AD1B5", @"3385":@"#54D8A8", @"339":@"#00B28C", @"3395":@"#00C993", @"340":@"#009977", @"3405":@"#00B27A", @"341":@"#007A5E", @"3415":@"#007C59", @"342":@"#006B54", @"3425":@"#006847", @"343":@"#00563F", @"3435":@"#024930", @"344":@"#B5E2BF", @"345":@"#96D8AF", @"346":@"#70CE9B", @"347":@"#009E60", @"348":@"#008751", @"349":@"#006B3F", @"350":@"#234F33", @"351":@"#B5E8BF", @"352":@"#99E5B2", @"353":@"#84E2A8", @"354":@"#00B760", @"355":@"#009E49", @"356":@"#007A3D", @"357":@"#215B33", @"358":@"#AADD96", @"359":@"#A0DB8E", @"360":@"#60C659", @"361":@"#1EB53A", @"362":@"#339E35", @"363":@"#3D8E33", @"364":@"#3A7728", @"365":@"#D3E8A3", @"366":@"#C4E58E", @"367":@"#AADD6D", @"368":@"#5BBF21", @"368_2X":@"#009E0F", @"369":@"#56AA1C", @"370":@"#568E14", @"371":@"#566B21", @"372":@"#D8ED96", @"373":@"#CEEA82", @"374":@"#BAE860", @"375":@"#8CD600", @"375_2X":@"#54BC00", @"376":@"#7FBA00", @"377":@"#709302", @"378":@"#566314", @"379":@"#E0EA68", @"380":@"#D6E542", @"381":@"#CCE226", @"382":@"#BAD80A", @"382_2X":@"#9EC400", @"383":@"#A3AF07", @"384":@"#939905", @"385":@"#707014", @"386":@"#E8ED60", @"387":@"#E0ED44", @"388":@"#D6E80F", @"389":@"#CEE007", @"390":@"#BAC405", @"391":@"#9E9E07", @"392":@"#848205", @"393":@"#F2EF87", @"3935":@"#F2ED6D", @"394":@"#EAED35", @"3945":@"#EFEA07", @"395":@"#E5E811", @"3955":@"#EDE211", @"396":@"#E0E20C", @"3965":@"#E8DD11", @"397":@"#C1BF0A", @"3975":@"#B5A80C", @"398":@"#AFA80A", @"3985":@"#998C0A", @"399":@"#998E07", @"3995":@"#6D6002", @"400":@"#D1C6B5", @"401":@"#C1B5A5", @"402":@"#AFA593", @"403":@"#998C7C", @"404":@"#827566", @"405":@"#6B5E4F", @"406":@"#CEC1B5", @"408":@"#A8998C", @"409":@"#99897C", @"410":@"#7C6D63", @"411":@"#66594C", @"412":@"#3D3028", @"413":@"#C6C1B2", @"414":@"#B5AFA0", @"415":@"#A39E8C", @"416":@"#8E8C7A", @"417":@"#777263", @"418":@"#605E4F", @"419":@"#282821", @"420":@"#D1CCBF", @"421":@"#BFBAAF", @"422":@"#AFAAA3", @"423":@"#96938E", @"424":@"#827F77", @"425":@"#60605B", @"426":@"#2B2B28", @"427":@"#DDDBD1", @"428":@"#D1CEC6", @"429":@"#ADAFAA", @"430":@"#919693", @"431":@"#666D70", @"432":@"#444F51", @"433":@"#30383A", @"433_2X":@"#0A0C11", @"434":@"#E0D1C6", @"435":@"#D3BFB7", @"436":@"#BCA59E", @"437":@"#8C706B", @"438":@"#593F3D", @"439":@"#493533", @"440":@"#3F302B", @"441":@"#D1D1C6", @"442":@"#BABFB7", @"443":@"#A3A8A3", @"444":@"#898E8C", @"445":@"#565959", @"446":@"#494C49", @"447":@"#3F3F38", @"448":@"#54472D", @"4485":@"#604C11", @"449":@"#544726", @"4495":@"#877530", @"450":@"#60542B", @"4505":@"#A09151", @"451":@"#ADA07A", @"4515":@"#BCAD75", @"452":@"#C4B796", @"4525":@"#CCBF8E", @"453":@"#D6CCAF", @"4535":@"#DBCEA5", @"454":@"#E2D8BF", @"4545":@"#E5DBBA", @"455":@"#665614", @"456":@"#998714", @"457":@"#B59B0C", @"458":@"#DDCC6B", @"459":@"#E2D67C", @"460":@"#EADD96", @"461":@"#EDE5AD", @"462":@"#5B4723", @"4625":@"#472311", @"463":@"#755426", @"4635":@"#8C5933", @"464":@"#876028", @"464_2X":@"#704214", @"4645":@"#B28260", @"465":@"#C1A875", @"4655":@"#C49977", @"466":@"#D1BF91", @"4665":@"#D8B596", @"467":@"#DDCCA5", @"4675":@"#E5C6AA", @"468":@"#E2D6B5", @"4685":@"#EDD3BC", @"469":@"#603311", @"4695":@"#51261C", @"470":@"#9B4F19", @"4705":@"#7C513D", @"471":@"#BC5E1E", @"471_2X":@"#A34402", @"4715":@"#99705B", @"472":@"#EAAA7A", @"4725":@"#B5917C", @"473":@"#F4C4A0", @"4735":@"#CCAF9B", @"474":@"#F4CCAA", @"4745":@"#D8BFAA", @"475":@"#F7D3B5", @"4755":@"#E2CCBA", @"476":@"#593D2B", @"477":@"#633826", @"478":@"#7A3F28", @"479":@"#AF8970", @"480":@"#D3B7A3", @"481":@"#E0CCBA", @"482":@"#E5D3C1", @"483":@"#6B3021", @"484":@"#9B301C", @"485":@"#D81E05", @"485_2X":@"#CC0C00", @"486":@"#ED9E84", @"487":@"#EFB5A0", @"488":@"#F2C4AF", @"489":@"#F2D1BF", @"490":@"#5B2626", @"491":@"#752828", @"492":@"#913338", @"494":@"#F2ADB2", @"495":@"#F4BCBF", @"496":@"#F7C9C6", @"497":@"#512826", @"4975":@"#441E1C", @"498":@"#6D332B", @"4985":@"#844949", @"499":@"#7A382D", @"4995":@"#A56B6D", @"500":@"#CE898C", @"5005":@"#BC8787", @"501":@"#EAB2B2", @"5015":@"#D8ADA8", @"502":@"#F2C6C4", @"5025":@"#E2BCB7", @"503":@"#F4D1CC", @"5035":@"#EDCEC6", @"504":@"#511E26", @"505":@"#661E2B", @"506":@"#7A2638", @"507":@"#D8899B", @"508":@"#E8A5AF", @"509":@"#F2BABF", @"510":@"#F4C6C9", @"511":@"#602144", @"5115":@"#4F213A", @"512":@"#84216B", @"5125":@"#754760", @"513":@"#9E2387", @"5135":@"#936B7F", @"514":@"#D884BC", @"5145":@"#AD8799", @"515":@"#E8A3C9", @"5155":@"#CCAFB7", @"516":@"#F2BAD3", @"5165":@"#E0C9CC", @"517":@"#F4CCD8", @"5175":@"#E8D6D1", @"518":@"#512D44", @"5185":@"#472835", @"519":@"#63305E", @"5195":@"#593344", @"520":@"#703572", @"5205":@"#8E6877", @"521":@"#B58CB2", @"5215":@"#B5939B", @"522":@"#C6A3C1", @"5225":@"#CCADAF", @"523":@"#D3B7CC", @"5235":@"#DDC6C4", @"524":@"#E2CCD3", @"5245":@"#E5D3CC", @"525":@"#512654", @"5255":@"#35264F", @"526":@"#68217A", @"5265":@"#493D63", @"527":@"#7A1E99", @"5275":@"#605677", @"528":@"#AF72C1", @"5285":@"#8C8299", @"529":@"#CEA3D3", @"5295":@"#B2A8B5", @"530":@"#D6AFD6", @"5305":@"#CCC1C6", @"531":@"#E5C6DB", @"5315":@"#DBD3D3", @"532":@"#353842", @"533":@"#353F5B", @"534":@"#3A4972", @"535":@"#9BA3B7", @"536":@"#ADB2C1", @"537":@"#C4C6CE", @"538":@"#D6D3D6", @"539":@"#003049", @"5395":@"#02283A", @"540":@"#00335B", @"5405":@"#3F6075", @"541":@"#003F77", @"5415":@"#607C8C", @"542":@"#6693BC", @"5425":@"#8499A5", @"543":@"#93B7D1", @"5435":@"#AFBCBF", @"544":@"#B7CCDB", @"5445":@"#C4CCCC", @"545":@"#C4D3DD", @"5455":@"#D6D8D3", @"546":@"#0C3844", @"5463":@"#00353A", @"5467":@"#193833", @"547":@"#003F54", @"5473":@"#26686D", @"5477":@"#3A564F", @"548":@"#004459", @"5483":@"#609191", @"5487":@"#667C72", @"549":@"#5E99AA", @"5493":@"#8CAFAD", @"5497":@"#91A399", @"550":@"#87AFBF", @"5503":@"#AAC4BF", @"5507":@"#AFBAB2", @"551":@"#A3C1C9", @"5513":@"#CED8D1", @"5517":@"#C9CEC4", @"552":@"#C4D6D6", @"5523":@"#D6DDD6", @"5527":@"#CED1C6", @"553":@"#234435", @"5535":@"#213D30", @"554":@"#195E47", @"5545":@"#4F6D5E", @"555":@"#076D54", @"5555":@"#779182", @"556":@"#7AA891", @"5565":@"#96AA99", @"557":@"#A3C1AD", @"5575":@"#AFBFAD", @"558":@"#B7CEBC", @"5585":@"#C4CEBF", @"559":@"#C6D6C4", @"5595":@"#D8DBCC", @"560":@"#2B4C3F", @"5605":@"#233A2D", @"561":@"#266659", @"5615":@"#546856", @"562":@"#1E7A6D", @"5625":@"#728470", @"563":@"#7FBCAA", @"5635":@"#9EAA99", @"564":@"#05705E", @"5645":@"#BCC1B2", @"565":@"#BCDBCC", @"5655":@"#C6CCBA", @"566":@"#D1E2D3", @"5665":@"#D6D6C6", @"567":@"#265142", @"568":@"#007263", @"569":@"#008772", @"570":@"#7FC6B2", @"571":@"#AADBC6", @"572":@"#BCE2CE", @"573":@"#CCE5D6", @"574":@"#495928", @"5743":@"#3F4926", @"5747":@"#424716", @"575":@"#547730", @"5753":@"#5E663A", @"5757":@"#6B702B", @"576":@"#608E3A", @"5763":@"#777C4F", @"5767":@"#8C914F", @"577":@"#B5CC8E", @"5773":@"#9B9E72", @"5777":@"#AAAD75", @"578":@"#C6D6A0", @"5783":@"#B5B58E", @"5787":@"#C6C699", @"579":@"#C9D6A3", @"5793":@"#C6C6A5", @"5797":@"#D3D1AA", @"580":@"#D8DDB5", @"5803":@"#D8D6B7", @"5807":@"#E0DDBC", @"581":@"#605E11", @"5815":@"#494411", @"582":@"#878905", @"5825":@"#75702B", @"583":@"#AABA0A", @"5835":@"#9E9959", @"584":@"#CED649", @"5845":@"#B2AA70", @"585":@"#DBE06B", @"5855":@"#CCC693", @"586":@"#E2E584", @"5865":@"#D6CEA3", @"587":@"#E8E89B", @"5875":@"#E0DBB5", @"600":@"#F4EDAF", @"601":@"#F2ED9E", @"602":@"#F2EA87", @"603":@"#EDE85B", @"604":@"#E8DD21", @"605":@"#DDCE11", @"606":@"#D3BF11", @"607":@"#F2EABC", @"608":@"#EFE8AD", @"609":@"#EAE596", @"610":@"#E2DB72", @"611":@"#D6CE49", @"612":@"#C4BA00", @"613":@"#AFA00C", @"614":@"#EAE2B7", @"615":@"#E2DBAA", @"616":@"#DDD69B", @"617":@"#CCC47C", @"618":@"#B5AA59", @"619":@"#968C28", @"620":@"#847711", @"621":@"#D8DDCE", @"622":@"#C1D1BF", @"623":@"#A5BFAA", @"624":@"#7FA08C", @"625":@"#5B8772", @"626":@"#21543F", @"627":@"#0C3026", @"628":@"#CCE2DD", @"629":@"#B2D8D8", @"630":@"#8CCCD3", @"631":@"#54B7C6", @"632":@"#00A0BA", @"633":@"#007F99", @"634":@"#00667F", @"635":@"#BAE0E0", @"636":@"#99D6DD", @"637":@"#6BC9DB", @"638":@"#00B5D6", @"639":@"#00A0C4", @"640":@"#008CB2", @"641":@"#007AA5", @"642":@"#D1D8D8", @"643":@"#C6D1D6", @"644":@"#9BAFC4", @"645":@"#7796B2", @"646":@"#5E82A3", @"647":@"#26547C", @"648":@"#00305E", @"649":@"#D6D6D8", @"650":@"#BFC6D1", @"651":@"#9BAABF", @"652":@"#6D87A8", @"653":@"#335687", @"654":@"#0F2B5B", @"655":@"#0C1C47", @"656":@"#D6DBE0", @"657":@"#C1C9DD", @"658":@"#A5AFD6", @"659":@"#7F8CBF", @"660":@"#5960A8", @"661":@"#2D338E", @"662":@"#0C1975", @"663":@"#E2D3D6", @"664":@"#D8CCD1", @"665":@"#C6B5C4", @"666":@"#A893AD", @"667":@"#7F6689", @"668":@"#664975", @"669":@"#472B59", @"670":@"#F2D6D8", @"671":@"#EFC6D3", @"672":@"#EAAAC4", @"673":@"#E08CB2", @"674":@"#D36B9E", @"675":@"#BC3877", @"676":@"#A00054", @"677":@"#EDD6D6", @"678":@"#EACCCE", @"679":@"#E5BFC6", @"680":@"#D39EAF", @"681":@"#B7728E", @"682":@"#A05175", @"683":@"#7F284F", @"684":@"#EFCCCE", @"685":@"#EABFC4", @"686":@"#E0AABA", @"687":@"#C9899E", @"688":@"#B26684", @"689":@"#934266", @"690":@"#702342", @"691":@"#EFD1C9", @"692":@"#E8BFBA", @"693":@"#DBA8A5", @"694":@"#C98C8C", @"695":@"#B26B70", @"696":@"#8E4749", @"697":@"#7F383A", @"698":@"#F7D1CC", @"699":@"#F7BFBF", @"700":@"#F2A5AA", @"701":@"#E8878E", @"702":@"#D6606D", @"703":@"#B73844", @"704":@"#9E2828", @"705":@"#F9DDD6", @"706":@"#FCC9C6", @"707":@"#FCADAF", @"708":@"#F98E99", @"709":@"#F26877", @"710":@"#E04251", @"711":@"#D12D33", @"712":@"#FFD3AA", @"713":@"#F9C9A3", @"714":@"#F9BA82", @"715":@"#FC9E49", @"716":@"#F28411", @"717":@"#D36D00", @"718":@"#BF5B00", @"719":@"#F4D1AF", @"720":@"#EFC49E", @"721":@"#E8B282", @"722":@"#D18E54", @"723":@"#BA7530", @"724":@"#8E4905", @"725":@"#753802", @"726":@"#EDD3B5", @"727":@"#E2BF9B", @"728":@"#D3A87C", @"729":@"#C18E60", @"730":@"#AA753F", @"731":@"#723F0A", @"732":@"#60330A", @"801":@"#00AACC", @"801_2X":@"#0089AF", @"802":@"#60DD49", @"802_2X":@"#1CCE28", @"803":@"#FFED38", @"803_2X":@"#FFD816", @"804":@"#FF9338", @"804_2X":@"#FF7F1E", @"805":@"#F95951", @"805_2X":@"#F93A2B", @"806":@"#FF0093", @"806_2X":@"#F7027C", @"807":@"#D6009E", @"807_2X":@"#BF008C", @"808":@"#00B59B", @"808_2X":@"#00A087", @"809":@"#DDE00F", @"809_2X":@"#D6D60C", @"810":@"#FFCC1E", @"810_2X":@"#FFBC21", @"811":@"#FF7247", @"811_2X":@"#FF5416", @"812":@"#FC2366", @"812_2X":@"#FC074F", @"813":@"#E50099", @"813_2X":@"#D10084", @"814":@"#8C60C1", @"814_2X":@"#703FAF"};
#else
    // http://www.umsiko.co.za/links/color.html
    NSDictionary *pseudoPantone = @{@"100C":@"#F3ED86", @"101C":@"#F5EC62", @"102C":@"#FAE600", @"103C":@"#CAAD00", @"104C":@"#AC9600", @"105C":@"#817214", @"106C":@"#F6E761", @"107C":@"#FAE22F", @"108C":@"#FEDB00", @"109C":@"#FFD100", @"110C":@"#DBAE00", @"111C":@"#AF8F00", @"112C":@"#998000", @"113C":@"#FAE15A", @"114C":@"#FAE051", @"115C":@"#FBDE4A", @"116C":@"#FFCE00", @"117C":@"#CE9D00", @"118C":@"#B38A00", @"119C":@"#8A761A", @"120C":@"#F9DF79", @"1205C":@"#F3E2A7", @"121C":@"#FBDB6E", @"1215C":@"#F5DD92", @"122C":@"#FDD44F", @"1225C":@"#FDC745", @"123C":@"#FFC726", @"1235C":@"#FFB300", @"124C":@"#EBAB00", @"1245C":@"#C69200", @"125C":@"#BB8900", @"1255C":@"#AA800E", @"126C":@"#A17C00", @"1265C":@"#836514", @"127C":@"#EFDF85", @"128C":@"#F2D65E", @"129C":@"#F1CD44", @"130C":@"#F1AB00", @"131C":@"#D49100", @"132C":@"#A67A00", @"133C":@"#715913", @"134C":@"#F8D583", @"1345C":@"#FBCF8D", @"135C":@"#FEC85A", @"1355C":@"#FDC87D", @"136C":@"#FFBC3A", @"1365C":@"#FFB754", @"137C":@"#FF9F00", @"1375C":@"#FF9A00", @"138C":@"#E47F00", @"1385C":@"#D67500", @"139C":@"#B67100", @"1395C":@"#9E6209", @"140C":@"#7A560F", @"1405C":@"#6C4713", @"141C":@"#EFC868", @"142C":@"#F1BB46", @"143C":@"#EFAA23", @"144C":@"#ED8000", @"145C":@"#CF7600", @"146C":@"#9F6000", @"147C":@"#715821", @"148C":@"#FBD09D", @"1485C":@"#FFB57B", @"149C":@"#FEC688", @"1495C":@"#FF963B", @"150C":@"#FFA94F", @"1505C":@"#FF7200", @"151C":@"#FF7300", @"152C":@"#E76F00", @"1525C":@"#CA4E00", @"153C":@"#C06600", @"1535C":@"#933F00", @"154C":@"#995409", @"1545C":@"#51260B", @"155C":@"#ECD6AF", @"1555C":@"#FFBFA0", @"156C":@"#EFC18A", @"1565C":@"#FFA97D", @"157C":@"#ED9B4F", @"1575C":@"#FF8642", @"158C":@"#E96B10", @"1585C":@"#FF6900", @"159C":@"#CD5806", @"1595C":@"#DA5C05", @"160C":@"#A24E12", @"1605C":@"#A24A13", @"161C":@"#613517", @"1615C":@"#853C10", @"162C":@"#FDC3AA", @"1625C":@"#FFA28B", @"163C":@"#FF9C71", @"1635C":@"#FF8E70", @"164C":@"#FF7E43", @"1645C":@"#FF6C3B", @"165C":@"#FF5F00", @"1655C":@"#FF5200", @"166C":@"#E55300", @"1665C":@"#E54800", @"167C":@"#C2510F", @"1675C":@"#A83C0F", @"168C":@"#6F3014", @"1685C":@"#863514", @"169C":@"#FFB6B1", @"170C":@"#FF897B", @"171C":@"#FF6141", @"172C":@"#FD4703", @"173C":@"#D84519", @"174C":@"#9A3416", @"175C":@"#703222", @"176C":@"#FFACB9", @"1765C":@"#FE9DB0", @"1767C":@"#FAAFC2", @"177C":@"#FF818C", @"1775C":@"#FF859A", @"1777C":@"#FB6581", @"178C":@"#FF5B60", @"1785C":@"#F9455B", @"1787C":@"#F9425F", @"1788C":@"#F02233", @"179C":@"#E23828", @"1795C":@"#D81F2A", @"1797C":@"#D02433", @"180C":@"#C0362C", @"1805C":@"#B0232A", @"1807C":@"#A12830", @"181C":@"#792720", @"1815C":@"#7C211E", @"1817C":@"#5E2728", @"182C":@"#F8B8CB", @"183C":@"#FC8DA9", @"184C":@"#F85D7E", @"185C":@"#EA0437", @"186C":@"#D21034", @"187C":@"#B31B34", @"188C":@"#7C2230", @"189C":@"#F8A1BE", @"1895C":@"#F3BCD4", @"190C":@"#F8779E", @"1905C":@"#F59BBD", @"191C":@"#F23F72", @"1915C":@"#F2558A", @"192C":@"#E90649", @"1925C":@"#E40050", @"193C":@"#C30C3E", @"1935C":@"#CB0447", @"194C":@"#9C1E3D", @"1945C":@"#AA113F", @"1955C":@"#93173B", @"196C":@"#EBC6D3", @"197C":@"#EB9BB2", @"198C":@"#E44D6F", @"199C":@"#DB0C41", @"200C":@"#C10435", @"201C":@"#9E1B34", @"202C":@"#892034", @"203C":@"#EBADCD", @"204C":@"#E87BAC", @"205C":@"#E34585", @"206C":@"#D7004D", @"207C":@"#B10042", @"208C":@"#902147", @"209C":@"#752641", @"210C":@"#FA9FCC", @"211C":@"#F97DB8", @"212C":@"#F34E9A", @"213C":@"#E61577", @"214C":@"#D00063", @"215C":@"#AA1054", @"216C":@"#7A1D42", @"217C":@"#ECBBDD", @"218C":@"#E86FB8", @"219C":@"#E0218A", @"220C":@"#AE0055", @"221C":@"#96004B", @"222C":@"#6C193F", @"223C":@"#F293D1", @"224C":@"#EF6ABF", @"225C":@"#E5239D", @"226C":@"#D60077", @"227C":@"#AE005F", @"228C":@"#8A0753", @"229C":@"#6A1D44", @"230C":@"#F7A7DB", @"231C":@"#F575C9", @"232C":@"#EF40B0", @"233C":@"#C90081", @"234C":@"#A6006B", @"235C":@"#890857", @"236C":@"#F2B0DF", @"2365C":@"#EFC3E4", @"237C":@"#EE86D3", @"2375C":@"#E270CD", @"238C":@"#E653BC", @"2385C":@"#D733B4", @"239C":@"#E032AF", @"2395C":@"#C40098", @"240C":@"#C41E99", @"2405C":@"#A70084", @"241C":@"#AC0481", @"2415C":@"#970076", @"242C":@"#7A1A57", @"2425C":@"#820063", @"243C":@"#E8B7E5", @"244C":@"#E6A2E0", @"245C":@"#DF81D6", @"246C":@"#C70BAC", @"247C":@"#B3009D", @"248C":@"#9E0389", @"249C":@"#7B2266", @"250C":@"#E3C0E6", @"251C":@"#D99CE1", @"252C":@"#CA65D1", @"253C":@"#A91BB0", @"254C":@"#962399", @"255C":@"#70266C", @"256C":@"#D9BFE0", @"2562C":@"#CFA5E4", @"2563C":@"#C79DD8", @"2567C":@"#BB99DA", @"257C":@"#CBA4D4", @"2572C":@"#C084DC", @"2573C":@"#B279C8", @"2577C":@"#A276CC", @"258C":@"#92499E", @"2582C":@"#A24CC8", @"2583C":@"#9950B2", @"2587C":@"#8348B5", @"259C":@"#6C1B72", @"2592C":@"#9016B2", @"2593C":@"#7E2B97", @"2597C":@"#59058D", @"260C":@"#5F1D5F", @"2602C":@"#7D0996", @"2603C":@"#68177F", @"2607C":@"#4F027C", @"261C":@"#591E55", @"2612C":@"#6A1A7A", @"2613C":@"#611774", @"2617C":@"#4B0B71", @"262C":@"#4F2248", @"2622C":@"#572458", @"2623C":@"#581963", @"2627C":@"#43125F", @"263C":@"#D8CBEB", @"2635C":@"#BFAFE4", @"264C":@"#BCA8E6", @"2645C":@"#AA94DE", @"265C":@"#8D65D2", @"2655C":@"#9173D3", @"266C":@"#6732BA", @"2665C":@"#7A52C7", @"267C":@"#4F1F91", @"268C":@"#4A217E", @"2685C":@"#3B0084", @"269C":@"#452663", @"2695C":@"#381D59", @"270C":@"#ADACDC", @"2705C":@"#A29FE0", @"2706C":@"#C4CBEA", @"2707C":@"#BDD0EE", @"2708C":@"#B1C5EA", @"271C":@"#9490D2", @"2715C":@"#8580D8", @"2716C":@"#94A1E2", @"2717C":@"#A1BDEA", @"2718C":@"#547ED9", @"272C":@"#7973C2", @"2725C":@"#5E53C7", @"2726C":@"#4555C7", @"2727C":@"#3878DB", @"2728C":@"#0047BE", @"273C":@"#25177A", @"2735C":@"#280092", @"2736C":@"#1E22AE", @"2738C":@"#00129D", @"274C":@"#211265", @"2745C":@"#22007A", @"2746C":@"#1A1C96", @"2747C":@"#00237E", @"2748C":@"#001A7B", @"275C":@"#1D1157", @"2755C":@"#1B0069", @"2756C":@"#151D71", @"2757C":@"#002065", @"2758C":@"#001D68", @"276C":@"#241A44", @"2765C":@"#1B0C55", @"2766C":@"#151C55", @"2767C":@"#0B2345", @"2768C":@"#031E51", @"277C":@"A9C7EC", @"278C":@"#8CB4E8", @"279C":@"#4189DD", @"280C":@"#00267F", @"281C":@"#002569", @"282C":@"#00204E", @"283C":@"#93BFEB", @"284C":@"#6CABE7", @"285C":@"#0077D4", @"286C":@"#0035AD", @"287C":@"#003798", @"288C":@"#003082", @"289C":@"#00234C", @"290C":@"#BED9ED", @"2905C":@"#92C9EB", @"291C":@"#A4CEEC", @"2915C":@"#62B4E8", @"292C":@"#6AB2E7", @"2925C":@"#0092DD", @"293C":@"#0047B6", @"2935C":@"#005BC3", @"294C":@"#003580", @"2945C":@"#0053A5", @"295C":@"#002D62", @"2955C":@"#003B6F", @"296C":@"#002740", @"2965C":@"#003151", @"297C":@"#78C7EB", @"2975C":@"#A5D9EC", @"298C":@"#42B4E6", @"2985C":@"#40BDE8", @"299C":@"#00A0E2", @"2995C":@"#00A2E1", @"300C":@"#0067C6", @"3005C":@"#0076CC", @"301C":@"#00529B", @"3015C":@"#0060A1", @"302C":@"#00436E", @"3025C":@"#00496E", @"303C":@"#00344D", @"3035C":@"#003A4F", @"304C":@"#A2DBEB", @"305C":@"#53CAEB", @"306C":@"#00B5E6", @"307C":@"#0070B2", @"308C":@"#005883", @"309C":@"#003947", @"310C":@"#66CFE6", @"3105C":@"#6FD2E4", @"311C":@"#00C2E3", @"3115C":@"#00C4DC", @"312C":@"#00A7D4", @"3125C":@"#00AECE", @"313C":@"#0092C7", @"3135C":@"#0092BA", @"314C":@"#007FAC", @"3145C":@"#007A97", @"315C":@"#006685", @"3155C":@"#00667C", @"316C":@"#004650", @"3165C":@"#004F5D", @"317C":@"#BFE5EA", @"318C":@"#8EDBE5", @"319C":@"#36CCDA", @"320C":@"#0097AC", @"321C":@"#008193", @"322C":@"#006F7A", @"323C":@"#006068", @"324C":@"#98D9DB", @"3242C":@"#75D9D8", @"3245C":@"#7BDDD8", @"3248C":@"#7BD2C8", @"325C":@"#47C7C7", @"3252C":@"#41D2D2", @"3255C":@"#32D4CB", @"3258C":@"#43C4B7", @"326C":@"#00AFAD", @"3262C":@"#00BAB9", @"3265C":@"#00C2B6", @"3268C":@"#00A994", @"327C":@"#008579", @"3272C":@"#00A19C", @"3275C":@"#00B09D", @"3278C":@"#00997A", @"328C":@"#007168", @"3282C":@"#008480", @"3285C":@"#009384", @"3288C":@"#007E64", @"329C":@"#00625A", @"3292C":@"#005A53", @"3295C":@"#007C6F", @"3298C":@"#006752", @"330C":@"#00524D", @"3302C":@"#00423C", @"3305C":@"#004A41", @"3308C":@"#004236", @"331C":@"#B2E7DF", @"332C":@"#9FE4DB", @"333C":@"#43D9C7", @"334C":@"#009878", @"335C":@"#007B63", @"336C":@"#006651", @"337C":@"#94D8C8", @"3375C":@"#81E0C7", @"338C":@"#76D1BD", @"3385C":@"#3BD6B2", @"339C":@"#00B08B", @"3395C":@"#00C590", @"340C":@"#009460", @"3405C":@"#00AE68", @"341C":@"#007856", @"3415C":@"#00774B", @"342C":@"#006A4E", @"3425C":@"#006644", @"343C":@"#00533E", @"3435C":@"#004731", @"344C":@"#A6DEC1", @"345C":@"#89D5AF", @"346C":@"#5EC998", @"347C":@"#009543", @"348C":@"#007E3A", @"349C":@"#006233", @"350C":@"#18472C", @"351C":@"#A7E6C4", @"352C":@"#87E0B0", @"353C":@"#6ADCA2", @"354C":@"#00AB39", @"355C":@"#009530", @"356C":@"#007229", @"357C":@"#0F4D2A", @"358C":@"#A5DB92", @"359C":@"#9FD98B", @"360C":@"#55BE47", @"361C":@"#12AD2B", @"362C":@"#289728", @"363C":@"#2F8927", @"364C":@"#317023", @"365C":@"#CCE5A2", @"366C":@"#BCE18D", @"367C":@"#A4D867", @"368C":@"#62BD19", @"369C":@"#4FA600", @"370C":@"#4F8A10", @"371C":@"#4A601C", @"372C":@"#D7E9A1", @"373C":@"#CDE985", @"374C":@"#BAE55F", @"375C":@"#87D300", @"376C":@"#76B900", @"377C":@"#679000", @"378C":@"#4D5A12", @"379C":@"#DDE56C", @"380C":@"#D3E13C", @"381C":@"#C8DB00", @"382C":@"#B9D300", @"383C":@"#9FAA00", @"384C":@"#8B9000", @"385C":@"#6E6A12", @"386C":@"#E5E96E", @"387C":@"#DEE63A", @"388C":@"#D7E300", @"389C":@"#C6DB00", @"390C":@"#B2BC00", @"391C":@"#959200", @"392C":@"#7F7800", @"393C":@"#EDEB8F", @"3935C":@"#F0EB7A", @"394C":@"#E9E73F", @"3945C":@"#EFE600", @"395C":@"#E4E400", @"3955C":@"#ECE100", @"396C":@"#DDDF00", @"3965C":@"#E9DC00", @"397C":@"#BEB800", @"3975C":@"#BBA800", @"398C":@"#ABA200", @"3985C":@"#9B8900", @"399C":@"#998D00", @"3995C":@"#6A5B07", @"400C":@"#CDC9C4", @"401C":@"#BDB8B1", @"402C":@"#ADA59D", @"403C":@"#988F86", @"404C":@"#7C7369", @"405C":@"#645A50", @"406C":@"#CAC4C2", @"408C":@"#A59997", @"409C":@"#948683", @"410C":@"#7B6E6A", @"411C":@"#62524E", @"412C":@"#372B27", @"413C":@"#C8C9C3", @"414C":@"#B5B6B0", @"415C":@"#9D9D96", @"416C":@"#87887F", @"417C":@"#6E6F64", @"418C":@"#5A5B51", @"419C":@"#1F211C", @"420C":@"#CCCCCC", @"421C":@"#BABBBC", @"422C":@"#A9AAAB", @"423C":@"#939495", @"424C":@"#767A7D", @"425C":@"#56595C", @"426C":@"#212424", @"427C":@"#D2D6D9", @"428C":@"#C3C8CD", @"429C":@"#A8ADB4", @"430C":@"#868F98", @"431C":@"#616A74", @"432C":@"#414B56", @"433C":@"#212930", @"434C":@"#D3C9CE", @"435C":@"#C8BAC0", @"436C":@"#B7A6AD", @"437C":@"#846E74", @"438C":@"#513E3E", @"439C":@"#443535", @"440C":@"#392E2C", @"441C":@"#CBD1D4", @"442C":@"#B3BCC0", @"443C":@"#99A3A6", @"444C":@"#7B858A", @"445C":@"#4F5559", @"446C":@"#3D4242", @"447C":@"#323532", @"448C":@"#473E26", @"4485C":@"#5D4718", @"449C":@"#4D4325", @"4495C":@"#836E2C", @"450C":@"#514826", @"4505C":@"#9B8948", @"451C":@"#9F9B74", @"4515C":@"#B5A570", @"452C":@"#B5B292", @"4525C":@"#C5BA8E", @"453C":@"#C8C5AC", @"4535C":@"#D4CCAA", @"454C":@"#D5D3BF", @"4545C":@"#DED9C2", @"455C":@"#655415", @"456C":@"#977F09", @"457C":@"#B29200", @"458C":@"#DBCA67", @"459C":@"#DFD27C", @"460C":@"#E5DB97", @"461C":@"#E7E3B5", @"462C":@"#563F23", @"4625C":@"#4E2614", @"463C":@"#6D4921", @"4635C":@"#905A33", @"464C":@"#855723", @"4645C":@"#B17F5C", @"465C":@"#B99C6B", @"4655C":@"#C09477", @"466C":@"#CAB388", @"4665C":@"#D1AE97", @"467C":@"#D5C4A1", @"4675C":@"#DDC2B0", @"468C":@"#E0D4BB", @"4685C":@"#E4D2C5", @"469C":@"#613418", @"4695C":@"#532821", @"470C":@"#9B4D1B", @"4705C":@"#7F4C3E", @"471C":@"#B75312", @"4715C":@"#9B6E5F", @"472C":@"#E49969", @"4725C":@"#B28D7F", @"473C":@"#EDB996", @"4735C":@"#C5AAA0", @"474C":@"#EEC5A9", @"4745C":@"#D4BEB6", @"475C":@"#F0D0BB", @"4755C":@"#DDCDC7", @"476C":@"#513127", @"477C":@"#5E2F24", @"478C":@"#723629", @"479C":@"#AD806C", @"480C":@"#C8A99A", @"481C":@"#D5BDB0", @"482C":@"#DDCEC4", @"483C":@"#6A2E22", @"484C":@"#9F2D20", @"485C":@"#DC241F", @"486C":@"#EC9384", @"487C":@"#ECAB9D", @"488C":@"#ECBBAF", @"489C":@"#EBCDC3", @"490C":@"#5A272A", @"491C":@"#772B2F", @"492C":@"#91353B", @"494C":@"#E7A7B6", @"495C":@"#EDB8C5", @"496C":@"#EFC4CE", @"497C":@"#4E2A28", @"4975C":@"#441E1F", @"498C":@"#68322E", @"4985C":@"#854A50", @"499C":@"#763931", @"4995C":@"#A16971", @"500C":@"#C88691", @"5005C":@"#B7848C", @"501C":@"#DEACB7", @"5015C":@"#D1A9B0", @"502C":@"#E5BFC7", @"5025C":@"#DBBCC1", @"503C":@"#E9CCD2", @"5035C":@"#E3CBD0", @"504C":@"#4E2029", @"505C":@"#6E2639", @"506C":@"#7E2B42", @"507C":@"#D38DA6", @"508C":@"#E2ABBF", @"509C":@"#E7B9CA", @"510C":@"#E9C2D1", @"511C":@"#60244E", @"5115C":@"#4B253E", @"512C":@"#7E2271", @"5125C":@"#704165", @"513C":@"#95288F", @"5135C":@"#885E80", @"514C":@"#D385C8", @"5145C":@"#A17E9A", @"515C":@"#DFA5D6", @"5155C":@"#C0A6BD", @"516C":@"#E7BADF", @"5165C":@"#D6C5D3", @"517C":@"#EBCAE3", @"5175C":@"#E0D5DE", @"518C":@"#4B2A46", @"5185C":@"#45293B", @"519C":@"#5A2D5F", @"5195C":@"#5E3A51", @"520C":@"#682F73", @"5205C":@"#8B687D", @"521C":@"#AD85BA", @"5215C":@"#B195A6", @"522C":@"#BD9ECA", @"5225C":@"#C6B0BE", @"523C":@"#CBB2D5", @"5235C":@"#D4C4CE", @"524C":@"#DACCE1", @"5245C":@"#DFD4DB", @"525C":@"#51265A", @"5255C":@"#2A254B", @"526C":@"#61207F", @"5265C":@"#433B67", @"527C":@"#6E20A0", @"5275C":@"#57527E", @"528C":@"#A774CD", @"5285C":@"#8581A4", @"529C":@"#C6A4E1", @"5295C":@"#AAA7C1", @"530C":@"#CFB1E3", @"5305C":@"#C1BED1", @"531C":@"#D7C4E7", @"5315C":@"#D4D4E0", @"532C":@"#262A39", @"533C":@"#253355", @"534C":@"#293F6F", @"535C":@"#95A1C3", @"536C":@"#A4B1CD", @"537C":@"#BDC6DA", @"538C":@"#D2D7E4", @"539C":@"#002A46", @"5395C":@"#02253A", @"540C":@"#002F5D", @"5405C":@"#3E647E", @"541C":@"#003C79", @"5415C":@"#587993", @"542C":@"#5998C9", @"5425C":@"#7C98AE", @"543C":@"#93B9DC", @"5435C":@"#A5B8C9", @"544C":@"#B1CBE5", @"5445C":@"#BCCAD6", @"545C":@"#BFD3E6", @"5455C":@"#CCD6E0", @"546C":@"#003440", @"5463C":@"#002830", @"5467C":@"#183533", @"547C":@"#003E51", @"5473C":@"#00626E", @"5477C":@"#3C5B59", @"548C":@"#004159", @"5483C":@"#4F8D97", @"5487C":@"#627D7C", @"549C":@"#5B97B1", @"5493C":@"#81ADB5", @"5497C":@"#8DA09F", @"550C":@"#85B0C6", @"5503C":@"#A1C3C9", @"5507C":@"#AAB8B9", @"551C":@"#9FC1D3", @"5513C":@"#BED5D9", @"5517C":@"#BFCBCC", @"552C":@"#B9D0DC", @"5523C":@"#CFDEE1", @"5527C":@"#CCD4D4", @"553C":@"#214232", @"5535C":@"#1B3930", @"554C":@"#24604A", @"5545C":@"#4A6D62", @"555C":@"#13694E", @"5555C":@"#6E8D82", @"556C":@"#74A18E", @"5565C":@"#8FA8A0", @"557C":@"#98BAAC", @"5575C":@"#A9BDB6", @"558C":@"#ACC7BD", @"5585C":@"#C0CFCB", @"559C":@"#C0D4CD", @"5595C":@"#D3DEDB", @"560C":@"#22483F", @"5605C":@"#193025", @"561C":@"#0F6259", @"5615C":@"#5A7060", @"562C":@"#007770", @"5625C":@"#6C8072", @"563C":@"#72B8B4", @"5635C":@"#97A69B", @"564C":@"#98CCC9", @"5645C":@"#B1BCB5", @"565C":@"#B9DCDA", @"5655C":@"#BDC5BF", @"566C":@"#CDE3E2", @"5665C":@"#CDD3CD", @"567C":@"#18453B", @"569C":@"#008478", @"570C":@"#76C6BE", @"571C":@"#9DD6CF", @"572C":@"#B4DEDB", @"573C":@"#C1E2DE", @"574C":@"#404F24", @"5743C":@"#3E4723", @"5747C":@"#404616", @"575C":@"#56732E", @"5753C":@"#5E6639", @"5757C":@"#6F732D", @"576C":@"#668E3C", @"5763C":@"#6E7649", @"5767C":@"#8D9150", @"577C":@"#B2C891", @"5773C":@"#939871", @"5777C":@"#A7AB74", @"578C":@"#BDD0A0", @"5783C":@"#ADB291", @"5787C":@"#C1C49A", @"579C":@"#C5D5A9", @"5793C":@"#BDC2A9", @"5797C":@"#CED1B3", @"580C":@"#CFDDBB", @"5803C":@"#CED2BF", @"5807C":@"#D9DCC5", @"581C":@"#605A12", @"5815C":@"#4B4516", @"582C":@"#888600", @"5825C":@"#7D762F", @"583C":@"#ABB400", @"5835C":@"#9D9754", @"584C":@"#CBD34C", @"5845C":@"#ADA86B", @"585C":@"#D8DB6F", @"5855C":@"#C7C397", @"586C":@"#DDE18A", @"5865C":@"#D3CFAC", @"587C":@"#E2E59F", @"5875C":@"#D9D7B9", @"600C":@"#EEEBB6", @"601C":@"#EEEAA5", @"602C":@"#EEE88D", @"603C":@"#EDE25E", @"604C":@"#EADB1B", @"605C":@"#E0CA00", @"606C":@"#D8BD00", @"607C":@"#EBE9C3", @"608C":@"#E9E6B4", @"609C":@"#E7E29A", @"610C":@"#E2D973", @"611C":@"#D8CC46", @"612C":@"#C4B300", @"613C":@"#B39D00", @"614C":@"#E3E1C1", @"615C":@"#DDDBB1", @"616C":@"#D7D29D", @"617C":@"#C9C37F", @"618C":@"#B4A851", @"619C":@"#9C8E2A", @"620C":@"#887811", @"621C":@"#D2DFDC", @"622C":@"#BDD2CC", @"623C":@"#9EBCB3", @"624C":@"#78A095", @"625C":@"#518274", @"626C":@"#1F5647", @"627C":@"#032D23", @"628C":@"#C8E2E8", @"629C":@"#AADAE5", @"630C":@"#82CBDD", @"631C":@"#48B8D2", @"632C":@"#009EC0", @"633C":@"#007CA4", @"634C":@"#00628C", @"635C":@"#ADDDEB", @"636C":@"#8DD4E9", @"637C":@"#5BC8E7", @"638C":@"#00B2DE", @"639C":@"#009ACF", @"640C":@"#0085C2", @"641C":@"#0070B2", @"642C":@"#CED9E7", @"643C":@"#C5D2E3", @"644C":@"#97B1D0", @"645C":@"#7498C0", @"646C":@"#5781AE", @"647C":@"#11568C", @"648C":@"#002B5F", @"649C":@"#D4DCE8", @"650C":@"#C2CDE0", @"651C":@"#99AECE", @"652C":@"#6F8DB9", @"653C":@"#2A568F", @"654C":@"#003066", @"655C":@"#002252", @"656C":@"#D4DDED", @"657C":@"#BFD0EA", @"658C":@"#A1BBE4", @"659C":@"#6E96D5", @"660C":@"#296DC1", @"661C":@"#003596", @"662C":@"#002280", @"663C":@"#DED8E6", @"664C":@"#D7D0E0", @"665C":@"#C5BBD3", @"666C":@"#A392B7", @"667C":@"#7C6495", @"668C":@"#624A7E", @"669C":@"#432C5F", @"670C":@"#EAD4E4", @"671C":@"#E6C1DB", @"672C":@"#E1A7CF", @"673C":@"#DA89BE", @"674C":@"#CE62A4", @"675C":@"#B62A79", @"676C":@"#A30059", @"677C":@"#E5D1DF", @"678C":@"#E2C9DA", @"679C":@"#DEBDD4", @"680C":@"#CB97B7", @"681C":@"#B8749E", @"682C":@"#9C4878", @"683C":@"#7C2250", @"684C":@"#E5CAD9", @"685C":@"#E1BCD0", @"686C":@"#DBAEC6", @"687C":@"#C686A9", @"688C":@"#B46B93", @"689C":@"#95416F", @"690C":@"#6D2348", @"691C":@"#E7CDD2", @"692C":@"#E2C1C8", @"693C":@"#D9A7B1", @"694C":@"#CA909C", @"695C":@"#B06876", @"696C":@"#944554", @"697C":@"#81333D", @"698C":@"#EDCFD7", @"699C":@"#F0C2CD", @"700C":@"#ECA9B9", @"701C":@"#E58DA2", @"702C":@"#D5647C", @"703C":@"#BA394E", @"704C":@"#A22630", @"705C":@"#F2D6DE", @"706C":@"#F5C7D4", @"707C":@"#F5B0C1", @"708C":@"#F590A6", @"709C":@"#EF6782", @"710C":@"#E54661", @"711C":@"#D32939", @"712C":@"#FACDAE", @"713C":@"#FBC399", @"714C":@"#FDB179", @"715C":@"#F9964A", @"716C":@"#F17C0E", @"717C":@"#DE6100", @"718C":@"#CF5200", @"719C":@"#EFCFB8", @"720C":@"#ECC3A5", @"721C":@"#E5AE86", @"722C":@"#D58F59", @"723C":@"#C0722F", @"724C":@"#9A4B00", @"725C":@"#843B00", @"726C":@"#E8CEBB", @"727C":@"#E1BEA4", @"728C":@"#D5AA88", @"729C":@"#C38E63", @"730C":@"#AC703D", @"731C":@"#793F0D", @"732C":@"#64300A", @"801C":@"#00A7D8", @"802C":@"#5BDD45", @"803C":@"#FFE805", @"804C":@"#FFA243", @"805C":@"#FF585E", @"806C":@"#FF1CAC", @"807C":@"#D708B2", @"808C":@"#00AE97", @"809C":@"#E1E400", @"810C":@"#FFCE09", @"811C":@"#FF7750", @"812C":@"#FF3485", @"813C":@"#EA12AF", @"814C":@"#7E60CE",};
#endif
    
    colorNameDictionaries = @{
                              @"Base" : baseDictionary,
                              @"Crayon" : crayonDictionary,
                              @"CSS" : cssDictionary,
                              @"System" : systemColorDictionary,
                              @"Wikipedia" : wikipediaColorDictionary,
                              @"Moroney": moroneyDictionary,
                              @"xkcd" : xkcdDictionary,
                              @"PseudoPantone" : pseudoPantone,
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
        // Do not match to PseudoPantone
        if ([dictionaryName isEqualToString:@"PseudoPantone"]) continue;
        
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

- (NSString *) closestPseudoPantoneName
{
    return [self closestColorNameUsingDictionary:@"PseudoPantone"];
}

- (UIColor *) closestMensColor
{   
    // Even more limited
    // NSArray *baseColors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor yellowColor], [UIColor orangeColor], [UIColor purpleColor]];
    
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

@implementation UIImage (UIColor_Expanded)
- (CGColorSpaceRef) colorSpace
{
    return CGImageGetColorSpace(self.CGImage);
}

- (CGColorSpaceModel) colorSpaceModel
{
    return  CGColorSpaceGetModel(self.colorSpace);
}

- (NSString *) colorSpaceString
{
    return [UIColor colorSpaceString:self.colorSpaceModel];
}
@end