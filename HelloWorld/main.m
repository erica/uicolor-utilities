/*
 
 Erica Sadun, http://ericasadun.com

 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Expanded.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIImageView *imageView;
}

- (void) randomPic
{
    CGSize size = self.view.frame.size;
    CGFloat w = size.width / 4;
    
    UIGraphicsBeginImageContext(size);
    
    for (int i = 0; i < self.view.frame.size.height / 45; i++)
    {
        UIColor *color = [UIColor randomColor];
        CGRect rect = CGRectMake(4, 0, 30, 30);
        UIBezierPath *path;
        
        NSString *s;
        UIFont *font = [UIFont systemFontOfSize:10];
        
        // Draw random color
        rect.origin.y = i * 40;
        path = [UIBezierPath bezierPathWithOvalInRect:rect];
        [color set];
        [path fill];
        
        // Label it
        [color.contrastingColor set];
        
        // HSB
        // s = [NSString stringWithFormat:@"  %0.2f\n  %0.2f\n  %0.2f", color.hue, color.saturation, color.brightness];
        // [s drawInRect:CGRectOffset(CGRectInset(rect, 0, -12), 3, 10) withFont:[UIFont systemFontOfSize:8]];
        
        // Colorfulness
        s = [NSString stringWithFormat:@"  %0.2f", color.colorfulness];
        [s drawInRect:CGRectInset(rect, 0, 8) withFont:font];

        // Fetch close colors
        NSDictionary *dict = [color closestColors];
        
        // Dot 1
        NSString *targetDictionary = @"xkcd";
        NSString *targetColorName = dict[targetDictionary];
        UIColor *targetColor = [UIColor colorWithName:targetColorName inDictionary:targetDictionary];        

        // Draw Dot 1
        rect.origin.x = 40;
        path = [UIBezierPath bezierPathWithOvalInRect:rect];
        [targetColor set];
        [path fill];
        
        // Label it
        [targetColor.contrastingColor set];
        s = [NSString stringWithFormat:@"  %0.2f", [color distanceFrom:targetColor]];
        [s drawInRect:CGRectInset(rect, 0, 8) withFont:font];

        [[UIColor blackColor] set];
        [targetColorName.capitalizedString drawInRect:CGRectMake(rect.origin.x + 40, i * 40 + 10, w, 30) withFont:font];
        
        // Dot 2
        targetDictionary = @"Moroney";
        targetColorName = dict[targetDictionary];
        targetColor = [UIColor colorWithName:targetColorName inDictionary:targetDictionary];

        // Draw Dot 2
        rect.origin.x = 80 + w;
        path = [UIBezierPath bezierPathWithOvalInRect:rect];
        [targetColor set];
        [path fill];
        
        // Label it
        [targetColor.contrastingColor set];
        s = [NSString stringWithFormat:@"  %0.2f", [color distanceFrom:targetColor]];
        [s drawInRect:CGRectInset(rect, 0, 8) withFont:font];

        [[UIColor blackColor] set];
        [targetColorName.capitalizedString drawInRect:CGRectMake(rect.origin.x + 40, i * 40 + 10, w, 30) withFont:font];
        
        // Dot 3 - Men's Color
        UIColor *mensColor = color.closestMensColor;
        rect.origin.x = size.width - 40;
        path = [UIBezierPath bezierPathWithOvalInRect:rect];
        [mensColor set];
        [path fill];
        
        [mensColor.contrastingColor set];
        s = [NSString stringWithFormat:@"  %0.2f", [color distanceFrom:mensColor]];
        [s drawInRect:CGRectInset(rect, 0, 8) withFont:font];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    imageView.image = image;
}

- (void) loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    imageView = [[UIImageView alloc] init];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)];
    [self.view addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)];
    [self.view addConstraints:constraints];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Random" style:UIBarButtonItemStylePlain target:self action:@selector(randomPic)];
    
#define BUILD_COLOR_WHEEL   0
#if BUILD_COLOR_WHEEL
    UIImage *wheel = [UIColor colorWheelOfSize:600];
    [UIImagePNGRepresentation(wheel) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/foo.png"] atomically:YES];
#endif
    
#define BUILD_SPECTRUM 1
#if BUILD_SPECTRUM
    
    NSDictionary *dict = [UIColor colorDictionaryNamed:@"xkcd"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *colorKey in dict.allKeys)
    {
        NSString *hexValue = dict[colorKey];
        UIColor *color = [UIColor colorWithHexString:hexValue];
        [array addObject:@[colorKey, color]];
    }

    [array sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        UIColor *c1 = obj1[1];
        UIColor *c2 = obj2[1];
        // return [c1 compareSaturation:c2];
        // return [c1 compareHue:c2];
        // return [c1 compareBrightness:c2];
        // return [c1 compareWarmth:c2];
        return [c1 compareColorfulness:c2];
    }];
    
    UIGraphicsBeginImageContext(CGSizeMake(array.count * 10, 100));
    CGRect rect = CGRectMake(0, 0, 10, 100);
    for (NSArray *tuple in array)
    {
        UIColor *color = tuple[1];
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
        [color set];
        rect.origin.x += rect.size.width;
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [UIImagePNGRepresentation(image) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/foo.png"] atomically:YES];
#endif
    
#define GO_KEVIN    0
#if GO_KEVIN

    // Kevin colors -- supply 2 colors, receive a 3rd that "matches".
    // It's the complement of the average of the 2
    
    NSDictionary *dict = [UIColor colorDictionaryNamed:@"Crayons"];
    NSArray *keys = dict.allKeys;

    UIGraphicsBeginImageContext(CGSizeMake(keys.count * 30, 116));
    CGRect rect = CGRectMake(0, 0, 20, 33);

    for (NSString *colorKey in dict.allKeys)
    {        
        NSString *key2 = keys[random() % keys.count];
        
        UIColor *c1 = [UIColor colorWithHexString:dict[colorKey]];
        UIColor *c2 = [UIColor colorWithHexString:dict[key2]];
        
        CGRect b = rect;
        [c1 set];
        CGContextFillRect(UIGraphicsGetCurrentContext(), b);
        b.origin.y += 33 + 8;
        [c2 set];
        CGContextFillRect(UIGraphicsGetCurrentContext(), b);
        UIColor *c3 = [c1 kevinColorWithColor:c2];
        b.origin.y += 33 + 8;
        [c3 set];
        CGContextFillRect(UIGraphicsGetCurrentContext(), b);

        rect.origin.x += 30;
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [UIImagePNGRepresentation(image) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/foo.png"] atomically:YES];
#endif
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@property (nonatomic) UIWindow *window;
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    _window.rootViewController = nav;
	[_window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}