#import <UIKit/UIKit.h>

#define SUPPORTS_UNDOCUMENTED_API	1

@interface UIColor (expanded)
@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;
@property (nonatomic, readonly) BOOL canProvideRGBComponents;
@property (nonatomic, readonly) CGFloat red;
@property (nonatomic, readonly) CGFloat green;
@property (nonatomic, readonly) CGFloat blue;
@property (nonatomic, readonly) CGFloat alpha;

- (NSString *) colorSpaceString;

- (NSArray *) arrayFromRGBAComponents;

- (NSString *) stringFromColor;
- (NSString *) hexStringFromColor;

#if SUPPORTS_UNDOCUMENTED_API
// Optional Undocumented API calls
- (NSString *) fetchStyleString;
- (UIColor *) rgbColor; // Via Poltras
#endif

+ (UIColor *) colorWithString: (NSString *) stringToConvert;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
@end
