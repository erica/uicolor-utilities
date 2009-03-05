#import <UIKit/UIKit.h>
#import "UIColor-Expanded.h"

#define RED_SLIDER		101
#define GREEN_SLIDER	102
#define BLUE_SLIDER		103

@interface HelloController : UIViewController {
	UIColor *bgcolor;
}
@property (nonatomic, retain) UIColor *bgcolor;
@end

@implementation HelloController
@synthesize bgcolor;

- (void)getInfo {
	self.title = [self.bgcolor hexStringFromColor];
	// self.bgcolor = [UIColor colorWithString:[self.bgcolor stringFromColor]];
	// self.title = [self.bgcolor stringFromColor];
	// printf("%f\n", self.bgcolor.green);
}

- (void)update:(UISlider *)aSlider {
	float r, g, b;
	
	r = [(UISlider *)[self.view viewWithTag:RED_SLIDER] value];
	g = [(UISlider *)[self.view viewWithTag:GREEN_SLIDER] value];
	b = [(UISlider *)[self.view viewWithTag:BLUE_SLIDER] value];
	
	self.bgcolor = [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
	[self.view setBackgroundColor:bgcolor];
}

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view = contentView;
	self.bgcolor = [UIColor blackColor];
	contentView.backgroundColor = self.bgcolor;
	

	// Add a right button
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											 initWithTitle:@"Action" 
											 style:UIBarButtonItemStylePlain 
											 target:self 
											 action:@selector(getInfo)] autorelease];
	
	// Create three sliders
	UISlider *s1 = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)];
	s1.center = CGPointMake(160.0f, 80.0f);
	s1.maximumValue = 1.0f;
	s1.minimumValue = 0.0f;
	s1.tag = RED_SLIDER;
	s1.backgroundColor = [UIColor redColor];
	[s1 addTarget:self action:@selector(update:) forControlEvents:UIControlEventValueChanged];
	[contentView addSubview:s1];
	[s1 release];
	
	UISlider *s2 = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)];
	s2.center = CGPointMake(160.0f, 130.0f);
	s2.maximumValue = 1.0f;
	s2.minimumValue = 0.0f;
	s2.tag = GREEN_SLIDER;
	s2.backgroundColor = [UIColor greenColor];
	[s2 addTarget:self action:@selector(update:) forControlEvents:UIControlEventValueChanged];
	[contentView addSubview:s2];
	[s2 release];
	
	UISlider *s3 = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)];
	s3.center = CGPointMake(160.0f, 180.0f);
	s3.maximumValue = 1.0f;
	s3.minimumValue = 0.0f;
	s3.tag = BLUE_SLIDER;
	s3.backgroundColor = [UIColor blueColor];
	[s3 addTarget:self action:@selector(update:) forControlEvents:UIControlEventValueChanged];
	[contentView addSubview:s3];
	[s3 release];
	
	[contentView release];
}
@end


@interface SampleAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation SampleAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[HelloController alloc] init]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"SampleAppDelegate");
	[pool release];
	return retVal;
}
