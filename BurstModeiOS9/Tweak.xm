#import "../BurstMode.h"
#define TWEAK
#import "../Prefs.h"

%hook CUCaptureController

- (void)stopCapturingBurst
{
    noSound = noCaptureSound;
    %orig;
    noSound = NO;
}

- (void)intervalometerDidReachMaximumCount:(id)arg1 {
    noSound = noCaptureSound;
    %orig;
    noSound = NO;
}

- (void)startCapturingBurstWithRequest:(id)arg1 error:(id)arg2 {
    noSound = noCaptureSound;
    %orig;
    noSound = NO;
}

%end

%hook CAMViewfinderViewController

- (void)_stillImageBurstCaptureRequestWithMaximumLength: (int)len
{
    %orig(limitedPhotosCount > 0 ? limitedPhotosCount : len);
}

%end

%hook CAMBurstIndicatorView

- (void)_updateCountLabelWithNumberOfPhotos
{
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
%hookf(Boolean, MGGetBoolAnswer, CFStringRef string){
    if (k("RearFacingCameraBurstCapability") || k("FrontFacingCameraBurstCapability"))
        return YES;
    return %orig(string);
}

%end

%group AudioHook

extern "C" void AudioServicesPlaySystemSound(SystemSoundID sound);
%hookf(void, AudioServicesPlaySystemSound, SystemSoundID sound){
    if (sound == 1122 && noSound)
        return;
    %orig(sound);
}

extern "C" void AudioServicesStartSystemSound(SystemSoundID sound);
%hookf(void, AudioServicesStartSystemSound, SystemSoundID sound){
    if (sound == 1119 && noSound)
        return;
    %orig(sound);
}

%end

%ctor
{
    NSString *identifier = NSBundle.mainBundle.bundleIdentifier;
    BOOL isSpringBoard = [identifier isEqualToString:@"com.apple.springboard"];
    if (isSpringBoard)
        return;
    HaveObserver()
    callback();
    if (BurstMode) {
        BOOL isPrefApp = [identifier isEqualToString:@"com.apple.Preferences"];
        if (!isPrefApp) {
            BOOL isPhotoApp = [identifier isEqualToString:@"com.apple.mobileslideshow"];
            if (!isPhotoApp) {
                openCamera9();
                %init;
            }
            %init(AudioHook);
        }
        %init(MG);
    }
}
