#import <UIKit/UIKit.h>
#import "UIColor-Expanded.h"

#define INFO				100

#define RED_SLIDER			101
#define GREEN_SLIDER		102
#define BLUE_SLIDER			103

#define CLOSEST_COLOR		150
#define COMPLEMENTARY_COLOR	151
#define CONTRASTING_COLOR	152
#define TRIADICA_COLOR		153
#define TRIADICB_COLOR		154

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
	
	// Get rgb from the sliders
	r = [(UISlider *)[self.view viewWithTag:RED_SLIDER] value];
	g = [(UISlider *)[self.view viewWithTag:GREEN_SLIDER] value];
	b = [(UISlider *)[self.view viewWithTag:BLUE_SLIDER] value];
	
	UIColor* color = [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
	UIColor* contrastingColor = [color contrastingColor];
	UIColor* complementaryColor = [color complementaryColor];
	
	CGFloat h,s,v;
	[color hue:&h saturation:&s brightness:&v alpha:nil];

	CGFloat xh,xs,xv;
	[contrastingColor hue:&xh saturation:&xs brightness:&xv alpha:nil];

	CGFloat ch,cs,cv;
	[complementaryColor hue:&ch saturation:&cs brightness:&cv alpha:nil];
	
	self.bgcolor = color;
	[self.view setBackgroundColor:bgcolor];
	
	// Set the title to the hex string
	self.title = [NSString stringWithFormat:@"#%@", [color hexStringFromColor]];
	
	// Set the info area
	UILabel* l;
	l = (UILabel *)[self.view viewWithTag:INFO];
	l.text = [NSString stringWithFormat:
			  @"h=%5.1f s=%4.2f b=%4.2f (color)\n"
			  "h=%5.1f s=%4.2f b=%4.2f (xtrst)\n"
			  "h=%5.1f s=%4.2f b=%4.2f (compl)\n"
			  ,
			  h, s, v,
			  xh, xs, xv,
			  ch, cs, cv
			  ];
	
	// Set the background for each slider to the pure color selected by that slider
	int mask = 0x00ff0000;
	for (int s = RED_SLIDER; s <= BLUE_SLIDER; ++s) {
		UISlider *slider = (UISlider *)[self.view viewWithTag:s];
		UIColor *sliderColor = [UIColor colorWithRGBHex:color.rgbHex & mask];
		slider.backgroundColor = sliderColor;
		mask >>= 8;
	}
	
	// Set the closest color
	NSString* closestColorName = [color closestColorName];
	UIColor* closestColor = [UIColor colorWithName:closestColorName];
	
	l = (UILabel *)[self.view viewWithTag:CLOSEST_COLOR];
	l.text = [NSString stringWithFormat:@"%@ #%@", closestColorName, closestColor.hexStringFromColor];
	l.backgroundColor = closestColor;
	l.textColor = [closestColor contrastingColor];
	
	// Set the contrasting color
	l = (UILabel *)[self.view viewWithTag:CONTRASTING_COLOR];
	l.text = [NSString stringWithFormat:@"Contrasting #%@", contrastingColor.hexStringFromColor];
	l.backgroundColor = contrastingColor;
	l.textColor = color;

	// Set the complementary color
	l = (UILabel *)[self.view viewWithTag:COMPLEMENTARY_COLOR];
	l.text = [NSString stringWithFormat:@"Complementary #%@", complementaryColor.hexStringFromColor];
	l.backgroundColor = complementaryColor;
	l.textColor = [complementaryColor contrastingColor];
	
	// Set the triadic colorS
	NSArray* triadics = [color triadicColors];
	
	l = (UILabel *)[self.view viewWithTag:TRIADICA_COLOR];
	UIColor* t = [triadics objectAtIndex:0];
	l.text = [NSString stringWithFormat:@"Triadic #%@", t.hexStringFromColor];
	l.backgroundColor = t;
	l.textColor = t.contrastingColor;

	
	l = (UILabel *)[self.view viewWithTag:TRIADICB_COLOR];
	t = [triadics objectAtIndex:1];
	l.text = [NSString stringWithFormat:@"Triadic #%@", t.hexStringFromColor];
	l.backgroundColor = t;
	l.textColor = t.contrastingColor;
}

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view = contentView;
	

	// Add a right button
	/*
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											 initWithTitle:@"Action" 
											 style:UIBarButtonItemStylePlain 
											 target:self 
											 action:@selector(getInfo)] autorelease];
	*/
	
	
	// Create info area
	UILabel *infoArea = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 60.0f)];
	infoArea.center = CGPointMake(160.f, 30.0f);
	infoArea.tag = INFO;
	infoArea.numberOfLines = 0;
	infoArea.font = [UIFont fontWithName:@"Courier New" size:10.0f];
	[contentView addSubview:infoArea];
	[infoArea release];
	
	// Create three sliders
	UISlider *s1 = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)];
	s1.center = CGPointMake(160.0f, 80.0f);
	s1.maximumValue = 1.0f;
	s1.minimumValue = 0.0f;
	s1.value = 1.0f;
	s1.tag = RED_SLIDER;
	s1.backgroundColor = [UIColor redColor];
	[s1 addTarget:self action:@selector(update:) forControlEvents:UIControlEventValueChanged];
	[contentView addSubview:s1];
	[s1 release];
	
	UISlider *s2 = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)];
	s2.center = CGPointMake(160.0f, 110.0f);
	s2.maximumValue = 1.0f;
	s2.minimumValue = 0.0f;
	s2.value = 1.0f;
	s2.tag = GREEN_SLIDER;
	s2.backgroundColor = [UIColor greenColor];
	[s2 addTarget:self action:@selector(update:) forControlEvents:UIControlEventValueChanged];
	[contentView addSubview:s2];
	[s2 release];
	
	UISlider *s3 = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)];
	s3.center = CGPointMake(160.0f, 140.0f);
	s3.maximumValue = 1.0f;
	s3.minimumValue = 0.0f;
	s3.value = 1.0f;
	s3.tag = BLUE_SLIDER;
	s3.backgroundColor = [UIColor blueColor];
	[s3 addTarget:self action:@selector(update:) forControlEvents:UIControlEventValueChanged];
	[contentView addSubview:s3];
	[s3 release];
	
	// Create closest color well
	UILabel *closestColor = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)];
	closestColor.center = CGPointMake(160.f, 260.0f);
	closestColor.tag = CLOSEST_COLOR;
	[contentView addSubview:closestColor];
	[closestColor release];
	
	// Create contrasting color well
	UILabel *contrastingColor = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)];
	contrastingColor.center = CGPointMake(160.f, 290.0f);
	contrastingColor.tag = CONTRASTING_COLOR;
	[contentView addSubview:contrastingColor];
	[contrastingColor release];
	
	// Create complementary color well
	UILabel *complementaryColor = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)];
	complementaryColor.center = CGPointMake(160.f, 320.0f);
	complementaryColor.tag = COMPLEMENTARY_COLOR;
	[contentView addSubview:complementaryColor];
	[complementaryColor release];
	
	// Create triadic color wells
	UILabel *traidicA = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 160.0f, 30.0f)];
	traidicA.center = CGPointMake(80.0f, 360.0f);
	traidicA.tag = TRIADICA_COLOR;
	[contentView addSubview:traidicA];
	[traidicA release];
	
	UILabel *traidicB = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 160.0f, 30.0f)];
	traidicB.center = CGPointMake(240.0f, 360.0f);
	traidicB.tag = TRIADICB_COLOR;
	[contentView addSubview:traidicB];
	[traidicB release];
	
	// Update the view
	[self update:s1];
	
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
