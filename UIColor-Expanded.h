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

@property (nonatomic, readonly)	CGFloat red;
@property (nonatomic, readonly)	CGFloat green;
@property (nonatomic, readonly)	CGFloat blue;
@property (nonatomic, readonly)	CGFloat alpha;
@end
