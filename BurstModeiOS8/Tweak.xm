#define TWEAK
#import "../BurstMode.h"
#import "../Prefs.h"

%hook CAMCameraView

- (void)captureController:(id)controller willCaptureStillImageForRequest:(id)request {
    MSHookIvar<BOOL>(self, "__needToStartAvalancheSound") = !noCaptureSound;
    %orig;
}

- (void)_finishAvalancheCapture {
    noSound = noCaptureSound;
    %orig;
    noSound = NO;
}

- (void)_avalancheCaptureTimerFired {
    CAMAvalancheCaptureService *service = [(CAMCaptureController *)[%c(CAMCaptureController) sharedInstance] _avalancheCaptureService];
    CAMAvalancheSession *session = [service _activeAvalancheSession];
    NSUInteger orig = [session numberOfPhotos];
    if (limitedPhotosCount) {
        if (orig >= limitedPhotosCount - 1) {
            [self _teardownAvalancheCaptureTimer];
            return;
        }
    }
    %orig;
}

%end

%hook CAMAvalancheCaptureService

- (BOOL)canContinueAvalancheCapture {
    NSUInteger photoCount = [self _activeAvalancheSession].numberOfPhotos;
    if (limitedPhotosCount > 0) {
        if (photoCount == limitedPhotosCount)
            return NO;
    }
    if (expFormat)
        return YES;
    return %orig;
}

%end

%hook CAMAvalancheIndicatorView

- (void)_updateCountLabelWithNumberOfPhotos {
    if (singleCounter) {
        NSInteger photoCount = MSHookIvar<NSInteger>(self, "__numberOfPhotos");
        UILabel *label = MSHookIvar<UILabel *>(self, "__countLabel");
        char cString[4];
        sprintf(cString, "%ld", (long)photoCount);
        NSString *s = [[[NSString alloc] initWithUTF8String:cString] autorelease];
        label.text = s;
    } else
        %orig;
}

- (void)incrementWithCaptureAnimation:(BOOL)animated {
    %orig(animInd ? NO : animated);
}

%end

%group MG

extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
    if (CFStringEqual(key, CFSTR("RearFacingCameraBurstCapability")) || CFStringEqual(key, CFSTR("FrontFacingCameraBurstCapability")))
        return YES;
    return %orig(key);
}

%end

%group AudioHook

extern "C" void AudioServicesPlaySystemSound(SystemSoundID sound);
%hookf(void, AudioServicesPlaySystemSound, SystemSoundID sound) {
    if (sound == 1122 && noSound)
        return;
    %orig(sound);
}

%end

%group iPadFix

%hook PUPhotoBrowserControllerPadSpec

- (id)avalancheReviewControllerSpec {
    return [[[objc_getClass("PUAvalancheReviewControllerPhoneSpec") alloc] init] autorelease];
}

%end

%hook PUPhotoBrowserController

- (id)_navbarButtonForIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:@"PUPHOTOBROWSER_BUTTON_REVIEW"])
        return [self _toolbarButtonForIdentifier:identifier];
    return %orig;
}

%end

%end

%ctor {
    if (IN_SPRINGBOARD)
        return;
    HaveObserver();
    callback();
    if (BurstMode) {
        if (![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.Preferences"]) {
            if (![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.mobileslideshow"]) {
                openCamera8();
                %init;
            }
            if (IS_IPAD) {
                dlopen("/System/Library/Frameworks/PhotosUI.framework/PhotosUI", RTLD_LAZY);
                %init(iPadFix);
            }
            %init(AudioHook);
        }
        %init(MG);
    }
}
