//
//  NSColorUtils.m
//  TestProject
//
//  Created by Erica Sadun on 4/6/13.
//  Copyright (c) 2013 Erica Sadun. All rights reserved.
//

#import "NSColorUtils.h"

//static CGFloat cgfmin(CGFloat a, CGFloat b) { return (a < b) ? a : b;}
//static CGFloat cgfmax(CGFloat a, CGFloat b) { return (a > b) ? a : b;}
//static CGFloat cgfunitclamp(CGFloat f) {return cgfmax(0.0, cgfmin(1.0, f));}

#pragma mark - Background Colors for Views, kinda
@implementation NSView (OSXBGColorExtension)
- (NSColor *) backgroundColor
{
    CGColorRef colorRef = self.layer.backgroundColor;
    NSColor *theColor = [NSColor colorWithCGColor:colorRef];
    return theColor;
}

- (void) setBackgroundColor:(NSColor *)backgroundColor
{
    [self setWantsLayer:YES];
    self.layer.backgroundColor = backgroundColor.CGColor;
}
@end

#pragma Device Space

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

@implementation NSColor (OSXColorExtensions)

#pragma mark - Color Model
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
    return [NSColor colorSpaceString:self.colorSpaceModel];
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

#pragma mark - Components

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

- (CGFloat) premultipliedRed { return self.red * self.alpha; }
- (CGFloat) premultipliedGreen { return self.green * self.alpha; }
- (CGFloat) premultipliedBlue {return self.blue * self.alpha; }

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
    [self getRed: &r green: &g blue: &b alpha:NULL];
    
    // http://en.wikipedia.org/wiki/Luma_(video)
    // Y = 0.2126 R + 0.7152 G + 0.0722 B
    return r * 0.2126f + g * 0.7152f + b * 0.0722f;
}

#pragma mark - Distance

- (CGFloat) luminanceDistanceFrom: (NSColor *) anotherColor
{
    CGFloat base = self.luminance - anotherColor.luminance;
    return sqrtf(base * base);
}

- (CGFloat) distanceFrom: (NSColor *) anotherColor
{
    CGFloat dR = self.red - anotherColor.red;
    CGFloat dG = self.green - anotherColor.green;
    CGFloat dB = self.blue - anotherColor.blue;
    
    return sqrtf(dR * dR + dG * dG + dB * dB);
}

#pragma mark - Testing

- (BOOL) isEqualToColor: (NSColor *) anotherColor
{
    CGFloat distance = [self distanceFrom:anotherColor];
    return (distance < FLT_EPSILON);
}

#pragma mark - Contrast

// Pick a color that is likely to contrast well with this color
- (NSColor *) contrastingColor
{
    return (self.luminance > 0.5f) ? [NSColor blackColor] : [NSColor whiteColor];
}

// Pick the color that is 180 degrees away in hue
- (NSColor *) complementaryColor
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
    return [NSColor colorWithDeviceHue:h saturation:s brightness:v alpha:a];
}

#pragma mark - Strings

+ (NSColor *) colorWithRGBHex: (UInt32)hex
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [NSColor colorWithDeviceRed:r / 255.0f
                                 green:g / 255.0f
                                  blue:b / 255.0f
                                 alpha:1.0f];
}

+ (NSColor *) colorWithHexString: (NSString *)stringToConvert
{
    NSString *string = stringToConvert;
    if ([string hasPrefix:@"#"])
        string = [string substringFromIndex:1];
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    unsigned hexNum;
    if (![scanner scanHexInt: &hexNum]) return nil;
    return [NSColor colorWithRGBHex:hexNum];
}

- (NSString *) hexStringValue
{
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -hexStringValue");
    NSString *result;
    switch (self.colorSpaceModel)
    {
        case kCGColorSpaceModelRGB:
            result = [NSString stringWithFormat:@"%02X%02X%02X", (int)(self.red * 255), (int)(self.green * 255), (int)(self.blue * 255)];
            break;
        case kCGColorSpaceModelMonochrome:
            result = [NSString stringWithFormat:@"%02X%02X%02X", (int)(self.white * 255), (int) (self.white * 255), (int)(self.white * 255)];
            break;
        default:
            result = nil;
    }
    return result;
}

#pragma mark - Color Names

static NSDictionary *colorNameDictionaries = nil;
static NSMutableArray *colorNames = nil;

+ (NSArray *) colorNames
{
    return colorNames;
}

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
     
     5/15 - Updated all strings to capitalized format.
     
     Known items *not* addressed are: orangeish, camo, azul, burple, purpleish, camo green, and blurple.
     */
    NSDictionary *xkcdDictionary = @{@"Acid Green":@"8ffe09", @"Adobe":@"bd6c48", @"Algae":@"54ac68", @"Algae Green":@"21c36f", @"Almost Black":@"070d0d", @"Amber":@"feb308", @"Amethyst":@"9b5fc0", @"Apple":@"6ecb3c", @"Apple Green":@"76cd26", @"Apricot":@"ffb16d", @"Aqua":@"13eac9", @"Aqua Blue":@"02d8e9", @"Aqua Green":@"12e193", @"Aqua Marine":@"2ee8bb", @"Aquamarine":@"04d8b2", @"Army Green":@"4b5d16", @"Asparagus":@"77ab56", @"Aubergine":@"3d0734", @"Auburn":@"9a3001", @"Avocado":@"90b134", @"Avocado Green":@"87a922", @"Azul":@"1d5dec", @"Azure":@"069af3", @"Baby Blue":@"a2cffe", @"Baby Green":@"8cff9e", @"Baby Pink":@"ffb7ce", @"Baby Poo":@"ab9004", @"Baby Poop":@"937c00", @"Baby Poop Brown":@"ad900d", @"Baby Poop Green":@"889717", @"Baby Puke Green":@"b6c406", @"Baby Purple":@"ca9bf7", @"Banana":@"ffff7e", @"Banana Yellow":@"fafe4b", @"Barbie Pink":@"fe46a5", @"Barf Green":@"94ac02", @"Barney":@"ac1db8", @"Barney Purple":@"a00498", @"Battleship Gray":@"6b7c85", @"Beige":@"e6daa6", @"Berry":@"990f4b", @"Bile":@"b5c306", @"Black":@"000000", @"Bland":@"afa88b", @"Blood":@"770001", @"Blood Orange":@"fe4b03", @"Blood Red":@"980002", @"Blue":@"0343df", @"Blue Blue":@"2242c7", @"Blue Gray":@"89a0b0", @"Blue Green":@"2bb179", @"Blue Purple":@"6241c7", @"Blue Violet":@"5d06e9", @"Blue With A Hint Of Purple":@"533cc6", @"Blue/Gray":@"758da3", @"Blue/Green":@"0f9b8e", @"Blue/Purple":@"5a06ef", @"Blueberry":@"464196", @"Bluish":@"2976bb", @"Bluish Gray":@"748b97", @"Bluish Green":@"10a674", @"Bluish Purple":@"703be7", @"Blurple":@"5539cc", @"Blush":@"f29e8e", @"Blush Pink":@"fe828c", @"Booger":@"9bb53c", @"Booger Green":@"96b403", @"Bordeaux":@"7b002c", @"Boring Green":@"63b365", @"Bottle Green":@"044a05", @"Brick":@"a03623", @"Brick Orange":@"c14a09", @"Brick Red":@"8f1402", @"Bright Aqua":@"0bf9ea", @"Bright Blue":@"0165fc", @"Bright Cyan":@"41fdfe", @"Bright Green":@"01ff07", @"Bright Lavender":@"c760ff", @"Bright Light Blue":@"26f7fd", @"Bright Light Green":@"2dfe54", @"Bright Lilac":@"c95efb", @"Bright Lime":@"87fd05", @"Bright Lime Green":@"65fe08", @"Bright Magenta":@"ff08e8", @"Bright Olive":@"9cbb04", @"Bright Orange":@"ff5b00", @"Bright Pink":@"fe01b1", @"Bright Purple":@"be03fd", @"Bright Red":@"ff000d", @"Bright Sea Green":@"05ffa6", @"Bright Sky Blue":@"02ccfe", @"Bright Teal":@"01f9c6", @"Bright Turquoise":@"0ffef9", @"Bright Violet":@"ad0afd", @"Bright Yellow":@"fffd01", @"Bright Yellow Green":@"9dff00", @"British Racing Green":@"05480d", @"Bronze":@"a87900", @"Brown":@"653700", @"Brown Gray":@"8d8468", @"Brown Green":@"706c11", @"Brown Orange":@"b96902", @"Brown Red":@"922b05", @"Brown Yellow":@"b29705", @"Brownish":@"9c6d57", @"Brownish Gray":@"86775f", @"Brownish Green":@"6a6e09", @"Brownish Orange":@"cb7723", @"Brownish Pink":@"c27e79", @"Brownish Purple":@"76424e", @"Brownish Red":@"9e3623", @"Brownish Yellow":@"c9b003", @"Browny Green":@"6f6c0a", @"Browny Orange":@"ca6b02", @"Bruise":@"7e4071", @"Bubble Gum Pink":@"ff69af", @"Bubblegum":@"ff6cb5", @"Bubblegum Pink":@"fe83cc", @"Buff":@"fef69e", @"Burgundy":@"610023", @"Burnt Orange":@"c04e01", @"Burnt Red":@"9f2305", @"Burnt Siena":@"b75203", @"Burnt Sienna":@"b04e0f", @"Burnt Umber":@"a0450e", @"Burnt Yellow":@"d5ab09", @"Burple":@"6832e3", @"Butter":@"ffff81", @"Butter Yellow":@"fffd74", @"Butterscotch":@"fdb147", @"Cadet Blue":@"4e7496", @"Camel":@"c69f59", @"Camo":@"7f8f4e", @"Camo Green":@"526525", @"Camouflage Green":@"4b6113", @"Canary":@"fdff63", @"Canary Yellow":@"fffe40", @"Candy Pink":@"ff63e9", @"Caramel":@"af6f09", @"Carmine":@"9d0216", @"Carnation":@"fd798f", @"Carnation Pink":@"ff7fa7", @"Carolina Blue":@"8ab8fe", @"Celadon":@"befdb7", @"Celery":@"c1fd95", @"Cement":@"a5a391", @"Cerise":@"de0c62", @"Cerulean":@"0485d1", @"Cerulean Blue":@"056eee", @"Charcoal":@"343837", @"Charcoal Gray":@"3c4142", @"Chartreuse":@"c1f80a", @"Cherry":@"cf0234", @"Cherry Red":@"f7022a", @"Chestnut":@"742802", @"Chocolate":@"3d1c02", @"Chocolate Brown":@"411900", @"Cinnamon":@"ac4f06", @"Claret":@"680018", @"Clay":@"b66a50", @"Clay Brown":@"b2713d", @"Clear Blue":@"247afd", @"Cloudy Blue":@"acc2d9", @"Cobalt":@"1e488f", @"Cobalt Blue":@"030aa7", @"Cocoa":@"875f42", @"Coffee":@"a6814c", @"Cool Blue":@"4984b8", @"Cool Gray":@"95a3a6", @"Cool Green":@"33b864", @"Copper":@"b66325", @"Coral":@"fc5a50", @"Coral Pink":@"ff6163", @"Cornflower":@"6a79f7", @"Cornflower Blue":@"5170d7", @"Cranberry":@"9e003a", @"Cream":@"ffffc2", @"Creme":@"ffffb6", @"Crimson":@"8c000f", @"Custard":@"fffd78", @"Cyan":@"00ffff", @"Dandelion":@"fedf08", @"Dark":@"1b2431", @"Dark Aqua":@"05696b", @"Dark Aquamarine":@"017371", @"Dark Beige":@"ac9362", @"Dark Blue":@"030764", @"Dark Blue Gray":@"1f3b4d", @"Dark Blue Green":@"005249", @"Dark Brown":@"341c02", @"Dark Coral":@"cf524e", @"Dark Cream":@"fff39a", @"Dark Cyan":@"0a888a", @"Dark Forest Green":@"002d04", @"Dark Fuchsia":@"9d0759", @"Dark Gold":@"b59410", @"Dark Grass Green":@"388004", @"Dark Gray":@"363737", @"Dark Gray Blue":@"29465b", @"Dark Green":@"054907", @"Dark Green Blue":@"1f6357", @"Dark Hot Pink":@"d90166", @"Dark Indigo":@"1f0954", @"Dark Khaki":@"9b8f55", @"Dark Lavender":@"856798", @"Dark Lilac":@"9c6da5", @"Dark Lime":@"84b701", @"Dark Lime Green":@"7ebd01", @"Dark Magenta":@"960056", @"Dark Maroon":@"3c0008", @"Dark Mauve":@"874c62", @"Dark Mint":@"48c072", @"Dark Mint Green":@"20c073", @"Dark Mustard":@"a88905", @"Dark Navy":@"000435", @"Dark Navy Blue":@"00022e", @"Dark Olive":@"373e02", @"Dark Olive Green":@"3c4d03", @"Dark Orange":@"c65102", @"Dark Pastel Green":@"56ae57", @"Dark Peach":@"de7e5d", @"Dark Periwinkle":@"665fd1", @"Dark Pink":@"cb416b", @"Dark Plum":@"3f012c", @"Dark Purple":@"35063e", @"Dark Red":@"840000", @"Dark Rose":@"b5485d", @"Dark Royal Blue":@"02066f", @"Dark Sage":@"598556", @"Dark Salmon":@"c85a53", @"Dark Sand":@"a88f59", @"Dark Sea Foam":@"1fb57a", @"Dark Sea Foam Green":@"3eaf76", @"Dark Sea Green":@"11875d", @"Dark Sky Blue":@"448ee4", @"Dark Slate Blue":@"214761", @"Dark Tan":@"af884a", @"Dark Taupe":@"7f684e", @"Dark Teal":@"014d4e", @"Dark Turquoise":@"045c5a", @"Dark Violet":@"34013f", @"Dark Yellow":@"d5b60a", @"Dark Yellow Green":@"728f02", @"Darkish Blue":@"014182", @"Darkish Green":@"287c37", @"Darkish Pink":@"da467d", @"Darkish Purple":@"751973", @"Darkish Red":@"a90308", @"Deep Aqua":@"08787f", @"Deep Blue":@"040273", @"Deep Brown":@"410200", @"Deep Green":@"02590f", @"Deep Lavender":@"8d5eb7", @"Deep Lilac":@"966ebd", @"Deep Magenta":@"a0025c", @"Deep Orange":@"dc4d01", @"Deep Pink":@"cb0162", @"Deep Purple":@"36013f", @"Deep Red":@"9a0200", @"Deep Rose":@"c74767", @"Deep Sea Blue":@"015482", @"Deep Sky Blue":@"0d75f8", @"Deep Teal":@"00555a", @"Deep Turquoise":@"017374", @"Deep Violet":@"490648", @"Denim":@"3b638c", @"Denim Blue":@"3b5b92", @"Desert":@"ccad60", @"Diarrhea":@"9f8303", @"Dirt":@"8a6e45", @"Dirt Brown":@"836539", @"Dirty Blue":@"3f829d", @"Dirty Green":@"667e2c", @"Dirty Orange":@"c87606", @"Dirty Pink":@"ca7b80", @"Dirty Purple":@"734a65", @"Dirty Yellow":@"cdc50a", @"Dodger Blue":@"3e82fc", @"Drab":@"828344", @"Drab Green":@"749551", @"Dried Blood":@"4b0101", @"Duck Egg Blue":@"c3fbf4", @"Dull Blue":@"49759c", @"Dull Brown":@"876e4b", @"Dull Green":@"74a662", @"Dull Orange":@"d8863b", @"Dull Pink":@"d5869d", @"Dull Purple":@"84597e", @"Dull Red":@"bb3f3f", @"Dull Teal":@"5f9e8f", @"Dull Yellow":@"eedc5b", @"Dusk":@"4e5481", @"Dusk Blue":@"26538d", @"Dusky Blue":@"475f94", @"Dusky Pink":@"cc7a8b", @"Dusky Purple":@"895b7b", @"Dusky Rose":@"ba6873", @"Dust":@"b2996e", @"Dusty Blue":@"5a86ad", @"Dusty Green":@"76a973", @"Dusty Lavender":@"ac86a8", @"Dusty Orange":@"f0833a", @"Dusty Pink":@"d58a94", @"Dusty Purple":@"825f87", @"Dusty Red":@"b9484e", @"Dusty Rose":@"c0737a", @"Dusty Teal":@"4c9085", @"Earth":@"a2653e", @"Easter Green":@"8cfd7e", @"Easter Purple":@"c071fe", @"Ecru":@"feffca", @"Egg Shell":@"fffcc4", @"Eggplant":@"380835", @"Eggplant Purple":@"430541", @"Eggshell":@"ffffd4", @"Eggshell Blue":@"c4fff7", @"Electric Blue":@"0652ff", @"Electric Green":@"21fc0d", @"Electric Lime":@"a8ff04", @"Electric Pink":@"ff0490", @"Electric Purple":@"aa23ff", @"Emerald":@"01a049", @"Emerald Green":@"028f1e", @"Evergreen":@"05472a", @"Faded Blue":@"658cbb", @"Faded Green":@"7bb274", @"Faded Orange":@"f0944d", @"Faded Pink":@"de9dac", @"Faded Purple":@"916e99", @"Faded Red":@"d3494e", @"Faded Yellow":@"feff7f", @"Fawn":@"cfaf7b", @"Fern":@"63a950", @"Fern Green":@"548d44", @"Fire Engine Red":@"fe0002", @"Flat Blue":@"3c73a8", @"Flat Green":@"699d4c", @"Fluorescent Green":@"0aff02", @"Foam Green":@"90fda9", @"Forest":@"0b5509", @"Forest Green":@"06470c", @"Forrest Green":@"154406", @"French Blue":@"436bad", @"Fresh Green":@"69d84f", @"Frog Green":@"58bc08", @"Fuchsia":@"ed0dd9", @"Gold":@"dbb40c", @"Golden":@"f5bf03", @"Golden Brown":@"b27a01", @"Golden Rod":@"f9bc08", @"Golden Yellow":@"fec615", @"Goldenrod":@"fac205", @"Grape":@"6c3461", @"Grape Purple":@"5d1451", @"Grapefruit":@"fd5956", @"Grass":@"5cac2d", @"Grass Green":@"3f9b0b", @"Grassy Green":@"419c03", @"Gray":@"929591", @"Gray Blue":@"77a1b5", @"Gray Brown":@"7a6a4f", @"Gray Green":@"82a67d", @"Gray Pink":@"c3909b", @"Gray Purple":@"826d8c", @"Gray Teal":@"5e9b8a", @"Gray/Blue":@"647d8e", @"Gray/Green":@"86a17d", @"Grayish":@"a8a495", @"Green":@"15b01a", @"Green Apple":@"5edc1f", @"Green Blue":@"23c48b", @"Green Brown":@"696006", @"Green Gray":@"7ea07a", @"Green Teal":@"0cb577", @"Green Yellow":@"c6f808", @"Green/Blue":@"01c08d", @"Green/Yellow":@"b5ce08", @"Greenish":@"40a368", @"Greenish Beige":@"c9d179", @"Greenish Blue":@"0b8b87", @"Greenish Brown":@"696112", @"Greenish Cyan":@"2afeb7", @"Greenish Gray":@"96ae8d", @"Greenish Tan":@"bccb7a", @"Greenish Teal":@"32bf84", @"Greenish Turquoise":@"00fbb0", @"Greenish Yellow":@"cdfd02", @"Gross Green":@"a0bf16", @"Gunmetal":@"536267", @"Hazel":@"8e7618", @"Heather":@"a484ac", @"Heliotrope":@"d94ff5", @"Highlighter Green":@"1bfc06", @"Hospital Green":@"9be5aa", @"Hot Green":@"25ff29", @"Hot Magenta":@"f504c9", @"Hot Pink":@"ff028d", @"Hot Purple":@"cb00f5", @"Hunter Green":@"0b4008", @"Ice":@"d6fffa", @"Ice Blue":@"d7fffe", @"Icky Green":@"8fae22", @"Indian Red":@"850e04", @"Indigo":@"380282", @"Indigo Blue":@"3a18b1", @"Iris":@"6258c4", @"Irish Green":@"019529", @"Ivory":@"ffffcb", @"Jade":@"1fa774", @"Jade Green":@"2baf6a", @"Jungle Green":@"048243", @"Kelley Green":@"009337", @"Kelly Green":@"02ab2e", @"Kermit Green":@"5cb200", @"Key Lime":@"aeff6e", @"Khaki":@"aaa662", @"Khaki Green":@"728639", @"Kiwi":@"9cef43", @"Kiwi Green":@"8ee53f", @"Lavender":@"c79fef", @"Lavender Blue":@"8b88f8", @"Lavender Pink":@"dd85d7", @"Lawn Green":@"4da409", @"Leaf":@"71aa34", @"Leaf Green":@"5ca904", @"Leafy Green":@"51b73b", @"Leather":@"ac7434", @"Lemon":@"fdff52", @"Lemon Green":@"adf802", @"Lemon Lime":@"bffe28", @"Lemon Yellow":@"fdff38", @"Lichen":@"8fb67b", @"Light Aqua":@"8cffdb", @"Light Aquamarine":@"7bfdc7", @"Light Beige":@"fffeb6", @"Light Blue":@"7bc8f6", @"Light Blue Gray":@"b7c9e2", @"Light Blue Green":@"7efbb3", @"Light Bluish Green":@"76fda8", @"Light Bright Green":@"53fe5c", @"Light Brown":@"ad8150", @"Light Burgundy":@"a8415b", @"Light Cyan":@"acfffc", @"Light Eggplant":@"894585", @"Light Forest Green":@"4f9153", @"Light Gold":@"fddc5c", @"Light Grass Green":@"9af764", @"Light Gray":@"d8dcd6", @"Light Gray Blue":@"9dbcd4", @"Light Gray Green":@"b7e1a1", @"Light Green":@"76ff7b", @"Light Green Blue":@"56fca2", @"Light Greenish Blue":@"63f7b4", @"Light Indigo":@"6d5acf", @"Light Khaki":@"e6f2a2", @"Light Lavender":@"efc0fe", @"Light Light Blue":@"cafffb", @"Light Light Green":@"c8ffb0", @"Light Lilac":@"edc8ff", @"Light Lime":@"aefd6c", @"Light Lime Green":@"b9ff66", @"Light Magenta":@"fa5ff7", @"Light Maroon":@"a24857", @"Light Mauve":@"c292a1", @"Light Mint":@"b6ffbb", @"Light Mint Green":@"a6fbb2", @"Light Moss Green":@"a6c875", @"Light Mustard":@"f7d560", @"Light Navy":@"155084", @"Light Navy Blue":@"2e5a88", @"Light Neon Green":@"4efd54", @"Light Olive":@"acbf69", @"Light Olive Green":@"a4be5c", @"Light Orange":@"fdaa48", @"Light Pastel Green":@"b2fba5", @"Light Pea Green":@"c4fe82", @"Light Peach":@"ffd8b1", @"Light Periwinkle":@"c1c6fc", @"Light Pink":@"ffd1df", @"Light Plum":@"9d5783", @"Light Purple":@"b36ff6", @"Light Red":@"ff474c", @"Light Rose":@"ffc5cb", @"Light Royal Blue":@"3a2efe", @"Light Sage":@"bcecac", @"Light Salmon":@"fea993", @"Light Sea Foam":@"a0febf", @"Light Sea Foam Green":@"a7ffb5", @"Light Sea Green":@"98f6b0", @"Light Sky Blue":@"c6fcff", @"Light Tan":@"fbeeac", @"Light Teal":@"90e4c1", @"Light Turquoise":@"7ef4cc", @"Light Violet":@"d6b4fc", @"Light Yellow":@"fffe7a", @"Light Yellow Green":@"ccfd7f", @"Light Yellowish Green":@"c2ff89", @"Lighter Green":@"75fd63", @"Lighter Purple":@"a55af4", @"Lightish Blue":@"3d7afd", @"Lightish Green":@"61e160", @"Lightish Purple":@"a552e6", @"Lightish Red":@"fe2f4a", @"Lilac":@"c48efd", @"Lime":@"aaff32", @"Lime Green":@"89fe05", @"Lime Yellow":@"d0fe1d", @"Lipstick":@"d5174e", @"Lipstick Red":@"c0022f", @"Macaroni And Cheese":@"efb435", @"Magenta":@"c20078", @"Mahogany":@"4a0100", @"Maize":@"f4d054", @"Mango":@"ffa62b", @"Manilla":@"fffa86", @"Marigold":@"fcc006", @"Marine":@"042e60", @"Marine Blue":@"01386a", @"Maroon":@"650021", @"Mauve":@"ae7181", @"Medium Blue":@"2c6fbb", @"Medium Brown":@"7f5112", @"Medium Gray":@"7d7f7c", @"Medium Green":@"39ad48", @"Medium Pink":@"f36196", @"Medium Purple":@"9e43a2", @"Melon":@"ff7855", @"Merlot":@"730039", @"Metallic Blue":@"4f738e", @"Mid Blue":@"276ab3", @"Mid Green":@"50a747", @"Midnight":@"03012d", @"Midnight Blue":@"020035", @"Midnight Purple":@"280137", @"Military Green":@"667c3e", @"Milk Chocolate":@"7f4e1e", @"Mint":@"9ffeb0", @"Mint Green":@"8fff9f", @"Minty Green":@"0bf77d", @"Mocha":@"9d7651", @"Moss":@"769958", @"Moss Green":@"658b38", @"Mossy Green":@"638b27", @"Mud":@"735c12", @"Mud Brown":@"60460f", @"Mud Green":@"606602", @"Muddy Brown":@"886806", @"Muddy Green":@"657432", @"Muddy Yellow":@"bfac05", @"Mulberry":@"920a4e", @"Murky Green":@"6c7a0e", @"Mushroom":@"ba9e88", @"Mustard":@"ceb301", @"Mustard Brown":@"ac7e04", @"Mustard Green":@"a8b504", @"Mustard Yellow":@"d2bd0a", @"Muted Blue":@"3b719f", @"Muted Green":@"5fa052", @"Muted Pink":@"d1768f", @"Muted Purple":@"805b87", @"Nasty Green":@"70b23f", @"Navy":@"01153e", @"Navy Blue":@"001146", @"Navy Green":@"35530a", @"Neon Blue":@"04d9ff", @"Neon Green":@"0cff0c", @"Neon Pink":@"fe019a", @"Neon Purple":@"bc13fe", @"Neon Red":@"ff073a", @"Neon Yellow":@"cfff04", @"Nice Blue":@"107ab0", @"Night Blue":@"040348", @"Ocean":@"017b92", @"Ocean Blue":@"03719c", @"Ocean Green":@"3d9973", @"Ocher":@"bf9b0c", @"Ochre":@"c69c04", @"Off Blue":@"5684ae", @"Off Green":@"6ba353", @"Off White":@"ffffe4", @"Off Yellow":@"f1f33f", @"Old Pink":@"c77986", @"Old Rose":@"c87f89", @"Olive":@"6e750e", @"Olive Brown":@"645403", @"Olive Drab":@"6f7632", @"Olive Green":@"677a04", @"Olive Yellow":@"c2b709", @"Orange":@"f97306", @"Orange Brown":@"be6400", @"Orange Pink":@"ff6f52", @"Orange Red":@"fe420f", @"Orange Yellow":@"ffad01", @"Orangeish":@"fd8d49", @"Orangey Brown":@"b16002", @"Orangey Red":@"fa4224", @"Orangey Yellow":@"fdb915", @"Orangish":@"fc824a", @"Orangish Brown":@"b25f03", @"Orangish Red":@"f43605", @"Orchid":@"c875c4", @"Pale":@"fff9d0", @"Pale Aqua":@"b8ffeb", @"Pale Blue":@"d0fefe", @"Pale Brown":@"b1916e", @"Pale Cyan":@"b7fffa", @"Pale Gold":@"fdde6c", @"Pale Gray":@"fdfdfe", @"Pale Green":@"c7fdb5", @"Pale Lavender":@"eecffe", @"Pale Light Green":@"b1fc99", @"Pale Lilac":@"e4cbff", @"Pale Lime":@"befd73", @"Pale Lime Green":@"b1ff65", @"Pale Magenta":@"d767ad", @"Pale Mauve":@"fed0fc", @"Pale Olive":@"b9cc81", @"Pale Olive Green":@"b1d27b", @"Pale Orange":@"ffa756", @"Pale Peach":@"ffe5ad", @"Pale Pink":@"ffcfdc", @"Pale Purple":@"b790d4", @"Pale Red":@"d9544d", @"Pale Rose":@"fdc1c5", @"Pale Salmon":@"ffb19a", @"Pale Sky Blue":@"bdf6fe", @"Pale Teal":@"82cbb2", @"Pale Turquoise":@"a5fbd5", @"Pale Violet":@"ceaefa", @"Pale Yellow":@"ffff84", @"Parchment":@"fefcaf", @"Pastel Blue":@"a2bffe", @"Pastel Green":@"b0ff9d", @"Pastel Orange":@"ff964f", @"Pastel Pink":@"ffbacd", @"Pastel Purple":@"caa0ff", @"Pastel Red":@"db5856", @"Pastel Yellow":@"fffe71", @"Pea":@"a4bf20", @"Pea Green":@"8eab12", @"Pea Soup":@"929901", @"Pea Soup Green":@"94a617", @"Peach":@"ffb07c", @"Peachy Pink":@"ff9a8a", @"Peacock Blue":@"016795", @"Pear":@"cbf85f", @"Periwinkle":@"8f8ce7", @"Periwinkle Blue":@"8f99fb", @"Petrol":@"005f6a", @"Pig Pink":@"e78ea5", @"Pine":@"2b5d34", @"Pine Green":@"0a481e", @"Pink":@"ff81c0", @"Pink Purple":@"db4bda", @"Pink Red":@"f5054f", @"Pink/Purple":@"ef1de7", @"Pinkish":@"d46a7e", @"Pinkish Brown":@"b17261", @"Pinkish Gray":@"c8aca9", @"Pinkish Orange":@"ff724c", @"Pinkish Purple":@"d648d7", @"Pinkish Red":@"f10c45", @"Pinkish Tan":@"d99b82", @"Pinky":@"fc86aa", @"Pinky Purple":@"c94cbe", @"Pinky Red":@"fc2647", @"Piss Yellow":@"ddd618", @"Pistachio":@"c0fa8b", @"Plum":@"580f41", @"Plum Purple":@"4e0550", @"Poison Green":@"40fd14", @"Poo":@"8f7303", @"Poo Brown":@"885f01", @"Poop":@"7f5f00", @"Poop Brown":@"7a5901", @"Poop Green":@"758000", @"Powder Blue":@"b1d1fc", @"Powder Pink":@"ffb2d0", @"Primary Blue":@"0804f9", @"Prussian Blue":@"004577", @"Puce":@"a57e52", @"Puke":@"a5a502", @"Puke Brown":@"947706", @"Puke Green":@"9aae07", @"Puke Yellow":@"c2be0e", @"Pumpkin":@"e17701", @"Pumpkin Orange":@"fb7d07", @"Pure Blue":@"0203e2", @"Purple":@"8756e4", @"Purple Blue":@"6140ef", @"Purple Brown":@"673a3f", @"Purple Gray":@"947e94", @"Purple Pink":@"df4ec8", @"Purple Red":@"990147", @"Purple/Blue":@"5d21d0", @"Purple/Pink":@"d725de", @"Purpleish":@"98568d", @"Purplish":@"94568c", @"Purply":@"983fb2", @"Purply Blue":@"661aee", @"Purply Pink":@"f075e6", @"Putty":@"beae8a", @"Racing Green":@"014600", @"Radioactive Green":@"2cfa1f", @"Raspberry":@"b00149", @"Raw Sienna":@"9a6200", @"Raw Umber":@"a75e09", @"Really Light Blue":@"d4ffff", @"Red":@"e50000", @"Red Brown":@"8b2e16", @"Red Orange":@"fd3c06", @"Red Pink":@"fa2a55", @"Red Purple":@"820747", @"Red Violet":@"9e0168", @"Red Wine":@"8c0034", @"Reddish":@"c44240", @"Reddish Brown":@"7f2b0a", @"Reddish Gray":@"997570", @"Reddish Orange":@"f8481c", @"Reddish Pink":@"fe2c54", @"Reddish Purple":@"910951", @"Reddy Brown":@"6e1005", @"Rich Blue":@"021bf9", @"Rich Purple":@"720058", @"Robin Egg Blue":@"8af1fe", @"Robin's Egg":@"6dedfd", @"Robin's Egg Blue":@"98eff9", @"Rosa":@"fe86a4", @"Rose":@"cf6275", @"Rose Pink":@"f7879a", @"Rose Red":@"be013c", @"Rosy Pink":@"f6688e", @"Rouge":@"ab1239", @"Royal":@"0c1793", @"Royal Blue":@"0504aa", @"Royal Purple":@"4b006e", @"Ruby":@"ca0147", @"Russet":@"a13905", @"Rust":@"a83c09", @"Rust Brown":@"8b3103", @"Rust Orange":@"c45508", @"Rust Red":@"aa2704", @"Rusty Orange":@"cd5909", @"Rusty Red":@"af2f0d", @"Saffron":@"feb209", @"Sage":@"87ae73", @"Sage Green":@"88b378", @"Salmon":@"ff796c", @"Salmon Pink":@"fe7b7c", @"Sand":@"e2ca76", @"Sand Brown":@"cba560", @"Sand Yellow":@"fce166", @"Sandstone":@"c9ae74", @"Sandy":@"f1da7a", @"Sandy Brown":@"c4a661", @"Sandy Yellow":@"fdee73", @"Sap Green":@"5c8b15", @"Sapphire":@"2138ab", @"Scarlet":@"be0119", @"Sea":@"3c9992", @"Sea Blue":@"047495", @"Sea Foam":@"80f9ad", @"Sea Foam Blue":@"78d1b6", @"Sea Foam Green":@"7af9ab", @"Sea Green":@"53fca1", @"Seaweed":@"18d17b", @"Seaweed Green":@"35ad6b", @"Sepia":@"985e2b", @"Shamrock":@"01b44c", @"Shamrock Green":@"02c14d", @"Shocking Pink":@"fe02a2", @"Sick Green":@"9db92c", @"Sickly Green":@"94b21c", @"Sickly Yellow":@"d0e429", @"Sienna":@"a9561e", @"Silver":@"c5c9c7", @"Sky":@"82cafc", @"Sky Blue":@"75bbfd", @"Slate":@"516572", @"Slate Blue":@"5b7c99", @"Slate Gray":@"59656d", @"Slate Green":@"658d6d", @"Slime Green":@"99cc04", @"Snot":@"acbb0d", @"Snot Green":@"9dc100", @"Soft Blue":@"6488ea", @"Soft Green":@"6fc276", @"Soft Pink":@"fdb0c0", @"Soft Purple":@"a66fb5", @"Spearmint":@"1ef876", @"Spring Green":@"a9f971", @"Spruce":@"0a5f38", @"Squash":@"f2ab15", @"Steel":@"738595", @"Steel Blue":@"5a7d9a", @"Steel Gray":@"6f828a", @"Stone":@"ada587", @"Stormy Blue":@"507b9c", @"Straw":@"fcf679", @"Strawberry":@"fb2943", @"Strong Blue":@"0c06f7", @"Strong Pink":@"ff0789", @"Sun Yellow":@"ffdf22", @"Sunflower":@"ffc512", @"Sunflower Yellow":@"ffda03", @"Sunny Yellow":@"fff917", @"Sunshine Yellow":@"fffd37", @"Swamp":@"698339", @"Swamp Green":@"748500", @"Tan":@"d1b26f", @"Tan Brown":@"ab7e4c", @"Tan Green":@"a9be70", @"Tangerine":@"ff9408", @"Taupe":@"c7ac7d", @"Tea":@"65ab7c", @"Tea Green":@"bdf8a3", @"Teal":@"24bca8", @"Teal Blue":@"01889f", @"Teal Green":@"0cdc73", @"Terra Cotta":@"cb6843", @"Tiffany Blue":@"7bf2da", @"Tomato":@"ef4026", @"Tomato Red":@"ec2d01", @"Topaz":@"13bbaf", @"Toxic Green":@"61de2a", @"Tree Green":@"2a7e19", @"True Blue":@"010fcc", @"True Green":@"089404", @"Turquoise":@"06c2ac", @"Turquoise Blue":@"06b1c4", @"Turquoise Green":@"04f489", @"Turtle Green":@"75b84f", @"Twilight":@"4e518b", @"Twilight Blue":@"0a437a", @"Ugly Blue":@"31668a", @"Ugly Brown":@"7d7103", @"Ugly Green":@"7a9703", @"Ugly Pink":@"cd7584", @"Ugly Purple":@"a442a0", @"Ugly Yellow":@"d0c101", @"Ultramarine":@"2000b1", @"Ultramarine Blue":@"1805db", @"Umber":@"b26400", @"Velvet":@"750851", @"Vermillion":@"f4320c", @"Very Dark Blue":@"000133", @"Very Dark Brown":@"1d0200", @"Very Dark Green":@"062e03", @"Very Dark Purple":@"2a0134", @"Very Light Blue":@"d5ffff", @"Very Light Brown":@"d3b683", @"Very Light Green":@"d1ffbd", @"Very Light Pink":@"fff4f2", @"Very Light Purple":@"f6cefc", @"Very Pale Blue":@"d6fffe", @"Very Pale Green":@"cffdbc", @"Vibrant Blue":@"0339f8", @"Vibrant Green":@"0add08", @"Vibrant Purple":@"ad03de", @"Violet":@"9a0eea", @"Violet Blue":@"510ac9", @"Violet Pink":@"fb5ffc", @"Violet Red":@"a50055", @"Viridian":@"1e9167", @"Vivid Blue":@"152eff", @"Vivid Green":@"2fef10", @"Vivid Purple":@"9900fa", @"Vomit":@"a2a415", @"Vomit Green":@"89a203", @"Vomit Yellow":@"c7c10c", @"Warm Blue":@"4b57db", @"Warm Brown":@"964e02", @"Warm Gray":@"978a84", @"Warm Pink":@"fb5581", @"Warm Purple":@"952e8f", @"Washed Out Green":@"bcf5a6", @"Water Blue":@"0e87cc", @"Watermelon":@"fd4659", @"Weird Green":@"3ae57f", @"Wheat":@"fbdd7e", @"White":@"ffffff", @"Windows Blue":@"3778bf", @"Wine":@"80013f", @"Wine Red":@"7b0323", @"Wintergreen":@"20f986", @"Wisteria":@"a87dc2", @"Yellow":@"ffff14", @"Yellow Brown":@"b79400", @"Yellow Green":@"bbf90f", @"Yellow Ochre":@"cb9d06", @"Yellow Orange":@"fcb001", @"Yellow Tan":@"ffe36e", @"Yellow/Green":@"c8fd3d", @"Yellowish":@"faee66", @"Yellowish Brown":@"9b7a01", @"Yellowish Green":@"b0dd16", @"Yellowish Orange":@"ffab0f", @"Yellowish Tan":@"fcfc81", @"Yellowy Brown":@"ae8b0c", @"Yellowy Green":@"bff128", };
    
    // See: http://i.imgur.com/HS7eK4r.png
    // Also: https://gist.github.com/erica/ca0023ef59a6ba9fbb93
    // And: http://imgur.com/FiMbMb2 and http://imgur.com/TP9gC9r
    NSDictionary *iosDictionary = @{
                                    @"Apple System Blue":@"0x007AFF",
                                    @"Apple System Green":@"0x4CD964",
                                    @"Apple System Red":@"0xFF3B30",
                                    @"Apple System Gray":@"0x8E8E93",
                                    
                                    @"Apple Messages Blue":@"0x007AFF",
                                    @"Apple Weather Gray":@"0x8E8E93",
                                    @"Apple Notes Yellow":@"0xFFCC00",
                                    @"Apple Newstand Blue":@"0x007AFF",
                                    @"Apple Compass Red":@"0xFF3B30",
                                    @"Apple Phone Blue":@"0x007AFF",
                                    @"Apple FaceTime Blue":@"0x007AFF",
                                    @"Apple Calendar Red":@"0xFF3B30",
                                    @"Apple Clock Red":@"0xFF3B30",
                                    @"Apple Reminders Orange":@"0xFF9500",
                                    
                                    @"Apple iTunes Primary Blue":@"0x34AADC",
                                    @"Apple iTunes Secondary Blue":@"0x5AC8FA",
                                    
                                    @"Apple Mail Blue":@"0x007AFF",
                                    @"Apple Photos Blue":@"0x007AFF",
                                    @"Apple Maps Blue":@"0x007AFF",
                                    @"Apple Stocks Gray":@"0x8E8E93",
                                    @"Apple App Store Blue":@"0x007AFF",
                                    @"Apple Mobile Safari Blue":@"0x007AFF",
                                    @"Apple Calculator Yellow":@"0xFF9500",
                                    @"Apple Camera Yellow":@"0xFFCC00",
                                    @"Apple Videos Primary Blue":@"0x34AADC",
                                    @"Apple Videos Secondary Blue":@"0x5AC8FA",
                                    @"Apple Game Center Purple":@"0x5856D6",
                                    @"Apple Passbook Blue":@"0x007AFF",
                                    @"Apple Music Red":@"0xFF2D55",
                                    @"Apple Contacts Blue":@"0x007AFF",
                                    
                                    @"Apple Magenta Dot":@"0xE12472",
                                    @"Apple Purple Dot":@"0xC56DE2",
                                    @"Apple Light Blue Dot":@"0x59BCEF",
                                    @"Apple Light Green Dot":@"0x88F437",
                                    @"Apple Yellow Dot":@"0xF0DD07",
                                    @"Apple Orange Dot":@"0xE9A10E",
                                    @"Apple Light Brown Dot":@"0xA58E63",
                                    
                                    @"Apple Highlight Green":@"0x6FE700",
                                    @"Apple Safari Top":@"0x3FCFFD",
                                    @"Apple Safari Bottom":@"0x1F5DEE",    
                                    @"Apple Contacts Face Gray":@"0x8F8F8F",
                                    @"Apple Contacts Light Gray":@"0xC2C1BD",
                                    @"Apple Contacts Blue":@"0x4FC1F9",
                                    @"Apple Contacts Light Green":@"0x43D459",
                                    @"Apple Contacts Orange":@"0xFF8A04",    
                                    @"Apple Game Center Bright Pink":@"0xFE2184",
                                    @"Apple Game Center Bright Yellow":@"0xF7CC05",
                                    @"Apple Game Center Bright Purple":@"0x951EEA",
                                    @"Apple Game Center Bright Blue":@"0x3B8FF3",    
                                    @"Apple Maps Yellow":@"0xFFD906",
                                    @"Apple Maps Blue":@"0x3791FF",
                                    @"Apple Maps Tan":@"0xE0D8C2",
                                    @"Apple Maps Pink":@"0xFABECB",
                                    @"Apple Maps Red":@"0xD91A21",
                                    @"Apple Maps Green":@"0x6BBE34",
                                    @"Apple Maps Orange":@"0xFEA50B",
                                    @"Apple Settings Light Gray":@"0xD7DBDA",
                                    @"Apple Settings Dark Gray":@"0x4A4A4A",
                                    @"Apple iTunes Store Primary Pink":@"0xF252C0",
                                    @"Apple iTunes Store Secondary Purple":@"0x9F3CFF",    
                                    @"Apple Messages Primary Green":@"0x7DFD65",
                                    @"Apple Messages Secondary Green":@"0x13D01A",
                                    
                                    };
    
    colorNameDictionaries = @{
                              @"Crayon" : crayonDictionary,
                              @"xkcd" : xkcdDictionary,
                              @"iOSDictionary" : iosDictionary,
                              @"Base" : baseDictionary,
                              @"CSS" : cssDictionary,
                              @"System" : systemColorDictionary,
                              @"Wikipedia" : wikipediaColorDictionary,
                              @"Moroney": moroneyDictionary,
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

+ (NSColor *) colorWithName: (NSString *) name inDictionary: (NSString *) dictionaryName
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
    
    return [NSColor colorWithHexString:hexkey];
}

+ (NSColor *) colorWithName: (NSString *) name
{
    [self initializeColorDictionaries];
    
    if (!name)
    {
        NSLog(@"Error: invalid color name");
        return nil;
    }
    
    for (NSString *dictionary in colorNameDictionaries.allKeys)
    {
        NSColor *color = [self colorWithName:name inDictionary:dictionary];
        if (color)
            return color;
    }
    
    return nil;
}

+ (void) initializeColorNames
{
    if (colorNames)
        return;
    
    if (!colorNameDictionaries)
        [self initializeColorDictionaries];
    
    // Collect all keys
    NSMutableArray *baseNames = [NSMutableArray array];
    // for (NSString *dictionaryName in colorNameDictionaries.allKeys)
    for (NSString *dictionaryName in @[@"xkcd"])
    {
        NSDictionary *dict = [NSColor colorDictionaryNamed:dictionaryName];
        [baseNames addObjectsFromArray:dict.allKeys];
    }
    
    // Sort and unique
    NSArray *sorted = [baseNames sortedArrayUsingComparator:^(id obj1, id obj2){return [obj1 compare:obj2];}];
    NSMutableArray *copiedArray = [NSMutableArray arrayWithArray:sorted];
    for (id object in sorted)
    {
        [copiedArray removeObjectIdenticalTo:object];
        [copiedArray addObject:object];
    }
    
    // Store
    colorNames = copiedArray;
}

+ (NSArray *) closeColorNamesMatchingKeys: (NSArray *) keys
{
    [self initializeColorNames];
    
    NSArray *results = colorNames;
    for (NSString *key in keys)
    {
        NSPredicate *containPred = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", key];
        NSArray *filtered = [results filteredArrayUsingPredicate:containPred];
        results = filtered;
    }
    return results;
}

- (NSString *) closestColorNameUsingDictionary: (NSString *) dictionaryName
{
    NSAssert(self.canProvideRGBComponents, @"Must be a RGB color to use closestColorName");
    if (!dictionaryName)
    {
        NSLog(@"Error: Must suply dictionary name to look up color");
        return nil;
    }
    
    [NSColor initializeColorDictionaries];
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
        NSColor *comparisonColor = [NSColor colorWithHexString:colorHex];
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
    
    for (NSString *dictionaryName in [NSColor availableColorDictionaries])
    {
        NSString *colorString = [self closestColorNameUsingDictionary:dictionaryName];
        if (!colorString)
            continue;
        
        NSColor *color = [NSColor colorWithName:colorString inDictionary:dictionaryName];
        CGFloat distance = [self distanceFrom:color];
        
        if (distance < bestScore)
        {
            bestScore = distance;
            bestKey = colorString;
        }
    }
    
    return bestKey;
}

#pragma mark - Mens Colors

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

- (CGFloat) hueDistanceFrom: (NSColor *) anotherColor
{
    CGFloat dH = self.hue - anotherColor.hue;
    
    return fabsf(dH);
}

- (NSColor *) closestMensColor
{
    // Even more limited
    // NSArray *baseColors = @[[NSColor redColor], [NSColor greenColor], [NSColor blueColor], [NSColor yellowColor], [NSColor orangeColor], [NSColor purpleColor]];
    
    NSArray *baseColors = @[[NSColor redColor], [NSColor greenColor], [NSColor blueColor], [NSColor cyanColor], [NSColor yellowColor], [NSColor magentaColor], [NSColor orangeColor], [NSColor purpleColor], [NSColor brownColor]];
    
    NSArray *grayColors = @[[NSColor blackColor], [NSColor lightGrayColor], [NSColor grayColor], [NSColor darkGrayColor]];
    
    CGFloat bestScore = MAXFLOAT;
    NSColor *winner = nil;
    BOOL evaluateAsGray = self.colorfulness < 0.45f;
    
    NSArray *colors = evaluateAsGray ? grayColors : baseColors;
    
    for (NSColor *color in colors)
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
@end