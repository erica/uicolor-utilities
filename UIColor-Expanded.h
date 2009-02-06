#import <UIKit/UIKit.h>

#define SUPPORTS_UNDOCUMENTED_API	1

@interface UIColor (expanded)
- (CGColorSpaceModel) colorSpaceModel;
- (NSString *) colorSpaceString;

- (BOOL) canProvideRGBComponents;
- (NSArray *) arrayFromRGBAComponents;
- (CGFloat) red;
- (CGFloat) blue;
- (CGFloat) green;
- (CGFloat) alpha;

- (NSString *) stringFromColor;
- (NSString *) hexStringFromColor;

#if SUPPORTS_UNDOCUMENTED_API
// Optional Undocumented API calls
- (NSString *) fetchStyleString;
- (UIColor *) rgbColor; // Via Poltras
#endif

+ (UIColor *) colorWithString: (NSString *) stringToConvert;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

@property (readonly)	CGFloat red;
@property (readonly)	CGFloat green;
@property (readonly)	CGFloat blue;
@property (readonly)	CGFloat alpha;
@end
