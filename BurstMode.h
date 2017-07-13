#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "../PS.h"

NSString *tweakIdentifier = @"com.PS.BurstMode";
CFStringRef PreferencesNotification = CFSTR("com.PS.BurstMode/ReloadPrefs");

@interface CAMAvalancheSession (BurstMode)
- (void)fakeSetNum:(NSUInteger)fake;
@end

@interface PLCameraButton (BurstMode)
- (void)burst;
- (void)takePhoto;
@end

#define BurstModeEnabledKey @"BurstModeEnabled"
#define BurstModeSafeEnabledKey @"BurstModeSafeEnabled"
#define DisableIrisEnabledKey @"DisableIrisEnabled"
#define DisableAnimEnabledKey @"DisableAnimEnabled"
#define LiveWellEnabledKey @"LiveWellEnabled"
#define AllowHDREnabledKey @"AllowHDREnabled"
#define expFormatKey @"expFormat"
#define AnimIndKey @"AnimInd"
#define noCaptureSoundKey @"noCaptureSound"
#define singleCounterKey @"singleCounter"
#define PhotoLimitCountKey @"PhotoLimitCount"
#define HoldTimeKey @"HoldTime"
#define IntervalKey @"Interval"