/*
 
 Erica Sadun, http://ericasadun.com

 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIColor-Expanded.h"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
{
    UIImageView *imageView;
}

- (void) doPicture
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
//        s = [NSString stringWithFormat:@"  %0.2f\n  %0.2f\n  %0.2f", color.hue, color.saturation, color.brightness];
//        [s drawInRect:CGRectOffset(CGRectInset(rect, 0, -12), 3, 10) withFont:[UIFont systemFontOfSize:8]];
        s = [NSString stringWithFormat:@"  %0.2f", color.colorfulness];
        [s drawInRect:CGRectInset(rect, 0, 8) withFont:font];

        // Fetch close colors
        NSDictionary *dict = [color closestColors];
        
        // Dot 1
        NSString *targetDictionary = @"Wikipedia";
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
        [targetColorName drawInRect:CGRectMake(rect.origin.x + 40, i * 40 + 10, w, 30) withFont:font];
        
        // Dot 2
        targetDictionary = @"Base";
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
        [targetColorName drawInRect:CGRectMake(rect.origin.x + 40, i * 40 + 10, w, 30) withFont:font];
        
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Go" style:UIBarButtonItemStylePlain target:self action:@selector(doPicture)];
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