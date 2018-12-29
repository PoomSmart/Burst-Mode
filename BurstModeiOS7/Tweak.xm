#define TWEAK
#import "../BurstMode.h"
#import "../Prefs.h"

BOOL hook7;

%group iOS70

%hook PLCameraView

- (void)_updateHDR:(NSInteger)mode {
    %orig(hook7 && [self HDRIsOn] && AllowHDR ? 1 : mode);
}

%end

%end

%group Common

%hook PLCameraView

- (void)cameraControllerWillTakePhoto:(id)arg1 {
    MSHookIvar<BOOL>(self, "__needToStartAvalancheSound") = !noCaptureSound;
    %orig;
}

- (void)_finishTimedCapture {
    noSound = noCaptureSound;
    %orig;
    noSound = NO;
}

- (void)_captureTimerFired {
    NSUInteger orig = self._avalancheSession.numberOfPhotos;
    if (limitedPhotosCount > 0) {
        if (orig == limitedPhotosCount)
            return;
    }
    hook7 = YES;
    if (expFormat) {
        if (orig > 997)
            [self._avalancheSession fakeSetNum:1];
        %orig;
        if (orig > 997)
            [self._avalancheSession fakeSetNum:orig];
    } else
        %orig;
    hook7 = NO;
}

- (void)_completeTimedCapture {
    hook7 = YES;
    %orig;
    hook7 = NO;
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

%hook CAMAvalancheSession

%new
- (void)fakeSetNum:(NSUInteger)fake {
    MSHookIvar<NSUInteger>(self, "_numberOfPhotos") = fake;
}

%end

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

%hook CAMPadApplicationSpec

%new
- (BOOL)shouldCreateAvalancheIndicator {
    return YES;
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
            openCamera7();
            if (isiOS70) {
                %init(iOS70);
            }
            %init(Common);
            if (IS_IPAD) {
                dlopen("/System/Library/PrivateFrameworks/PhotosUI.framework/PhotosUI", RTLD_LAZY);
                %init(iPadFix);
            }
            %init(AudioHook);
        }
        %init(MG);
    }
}
