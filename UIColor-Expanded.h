#import <UIKit/UIKit.h>

#define SUPPORTS_UNDOCUMENTED_API	1

@interface UIColor (UIColor_Expanded)
@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;
@property (nonatomic, readonly) BOOL canProvideRGBComponents;
@property (nonatomic, readonly) CGFloat red; // Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat green; // Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat blue; // Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat white; // Only valid if colorSpaceModel == kCGColorSpaceModelMonochrome
@property (nonatomic, readonly) CGFloat alpha;

- (NSString *) colorSpaceString;

- (NSArray *) arrayFromRGBAComponents;

- (BOOL) red:(CGFloat*)r green:(CGFloat*)g blue:(CGFloat*)b alpha:(CGFloat*)a;

- (UIColor*)colorByLuminanceMapping;

- (UIColor*)colorByMultiplyingByRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (UIColor*)colorByAddingRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (UIColor*)colorByLighteningWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (UIColor*)colorByDarkeningWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

- (UIColor*)colorByMultiplyingBy:(CGFloat)f;
- (UIColor*)colorByAdding:(CGFloat)f;
- (UIColor*)colorByLighteningWith:(CGFloat)f;
- (UIColor*)colorByDarkeningWith:(CGFloat)f;

- (UIColor*)colorByMultiplyingByColor:(UIColor*)color;
- (UIColor*)colorByAddingColor:(UIColor*)color;
- (UIColor*)colorByLighteningWithColor:(UIColor*)color;
- (UIColor*)colorByDarkeningWithColor:(UIColor*)color;

- (NSString *) stringFromColor;
- (NSString *) hexStringFromColor;

+ (UIColor *) colorWithString: (NSString *) stringToConvert;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
@end

#if SUPPORTS_UNDOCUMENTED_API
// UIColor_Undocumented_Expanded
// Methods which rely on undocumented methods of UIColor
@interface UIColor (UIColor_Undocumented_Expanded)
- (NSString *) fetchStyleString;
- (UIColor *) rgbColor; // Via Poltras
@end
#endif // SUPPORTS_UNDOCUMENTED_API
