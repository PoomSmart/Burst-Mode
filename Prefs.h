#import "../PSPrefs.x"

BOOL BurstMode;
BOOL AllowHDR;
BOOL expFormat;
BOOL animInd;
BOOL noCaptureSound;
BOOL singleCounter;

BOOL BurstModeSafe;
BOOL DisableIris;
BOOL DisableAnim;
BOOL LiveWell;

BOOL disableIris = NO;
BOOL burst = NO;
BOOL counterAnimate = NO;
BOOL ignoreCapture = NO;
BOOL noAutofocus = NO;
BOOL noSound = NO;

CGFloat Interval;
CGFloat HoldTime;

NSUInteger photoCount;
NSUInteger limitedPhotosCount;

HaveCallback()
{
	GetPrefs()
	GetBool(BurstMode, BurstModeEnabledKey, YES)
	GetBool(BurstModeSafe, BurstModeSafeEnabledKey, YES)
	GetBool(DisableIris, DisableIrisEnabledKey, NO)
	GetBool(DisableAnim, DisableAnimEnabledKey, NO)
	GetBool(LiveWell, LiveWellEnabledKey, NO);
	GetBool(AllowHDR, AllowHDREnabledKey, NO)
	GetBool(expFormat, expFormatKey, NO)
	GetBool(animInd, AnimIndKey, NO)
	GetBool(noCaptureSound, noCaptureSoundKey, NO)
	GetBool(singleCounter, singleCounterKey, NO)
	GetInt(limitedPhotosCount, PhotoLimitCountKey, 0)
	GetFloat2(HoldTime, 1.0)
	GetFloat2(Interval, 0.01)
}