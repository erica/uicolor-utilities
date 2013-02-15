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
        CGRect rect = CGRectMake(0, 0, 30, 30);
        UIBezierPath *path;
        
        rect.origin.y = i * 40;
        path = [UIBezierPath bezierPathWithOvalInRect:rect];
        [color set];
        [path fill];
        
        rect.origin.x = 40;
        path = [UIBezierPath bezierPathWithOvalInRect:rect];
        NSString *colorName = color.closestWikipediaColorName;
        UIColor *closeColor = [UIColor colorWithName:colorName inDictionary:@"Wikipedia"];
        [closeColor set];
        [path fill];
        
        [[UIColor blackColor] set];
        NSString *s = [NSString stringWithFormat:@"%0.2f %@", [color distanceFrom:closeColor], colorName];
        [s drawInRect:CGRectMake(rect.origin.x + 40, i * 40 + 10, w, 30) withFont:[UIFont systemFontOfSize:10]];

        
        rect.origin.x = 80 + w;
        path = [UIBezierPath bezierPathWithOvalInRect:rect];
        NSString *cssName = color.closestCSSName;
        UIColor *cssColor = [UIColor colorWithName:cssName inDictionary:@"CSS"];
        [cssColor set];
        [path fill];
        
        [[UIColor blackColor] set];
        s = [NSString stringWithFormat:@"%0.2f %@", [color distanceFrom:cssColor], cssName];
        [s drawInRect:CGRectMake(rect.origin.x + 40, i * 40 + 10, w, 30) withFont:[UIFont systemFontOfSize:10]];
        
        UIColor *mensColor = color.closestMensColor;
        rect.origin.x = size.width - 40;
        path = [UIBezierPath bezierPathWithOvalInRect:rect];
        [mensColor set];
        [path fill];
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