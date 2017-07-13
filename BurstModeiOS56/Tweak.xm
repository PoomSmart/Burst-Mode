#import "../BurstMode.h"
#define TWEAK
#import "../Prefs.h"

NSTimer *BMPressTimer;
NSTimer *BMHoldTimer;

UIView *counterBG;
UILabel *counter;

CGFloat kCounterBGAlpha = 0.4f;

void hideCounter(){
    if (burst) {
        counterAnimate = YES;
        [UIView animateWithDuration:0.8f delay:0.0f options:0
                         animations:^{
            counterBG.alpha = 0.0f;
            counter.alpha = 0.0f;
        }
                         completion:^(BOOL finished) {
            counterBG.hidden = YES;
            counter.text = singleCounter ? @"0" : @"000";
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3*NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            burst = NO;
        });
        photoCount = 0;
        counterAnimate = NO;
    }
}

void invalidateTimer(){
    if (BMHoldTimer != nil) {
        [BMHoldTimer invalidate];
        BMHoldTimer = nil;
    }
    if (BMPressTimer != nil) {
        [BMPressTimer invalidate];
        BMPressTimer = nil;
    }
}

PLCameraController *cameraController(){
    return (PLCameraController *)[%c(PLCameraController) sharedInstance];
}

void cleanup(){
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2*NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        PLCameraController *controller = cameraController();
        PLCameraView *cameraView = [controller delegate];
        [cameraView _setBottomBarEnabled:YES];
        [cameraView _setOverlayControlsEnabled:YES];
        [cameraView setCameraButtonsEnabled:YES];
        [controller setFocusDisabled:NO];
        if ([controller isFocusLockSupported] && noAutofocus)
            [controller _lockFocus:NO lockExposure:NO lockWhiteBalance:NO];
        [cameraView _setShouldShowFocus:YES];
        if ([controller respondsToSelector:@selector(setFaceDetectionEnabled:)])
            [controller setFaceDetectionEnabled:YES];
    });
    noAutofocus = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35*NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        disableIris = NO;
    });
}

BOOL isPhotoCamera(){
    return cameraController().cameraMode == 0;
}

BOOL isBackCamera(){
    return cameraController().cameraDevice == 0;
}

BOOL isCapturingVideo(){
    return [cameraController() isCapturingVideo];
}

%hook PLCameraButton

- (id)initWithDefaultSize
{
    self = %orig;
    if (self) {
        [self addTarget:self action:@selector(sendPressed) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(sendReleased) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
    }
    return self;
}

%new
- (void)sendPressed
{
    if (isPhotoCamera()) {
        BMHoldTimer = [NSTimer scheduledTimerWithTimeInterval:HoldTime target:self selector:@selector(burst) userInfo:nil repeats:NO];
        [BMHoldTimer retain];
    }
}

%new
- (void)takePhoto
{
    PLCameraView *cameraView = [cameraController() delegate];
    if (BurstModeSafe) {
        if (![cameraView hasInFlightCaptures])
            [cameraView performSelectorOnMainThread:@selector(_shutterButtonClicked) withObject:nil waitUntilDone:YES];
    } else
        [cameraView performSelectorOnMainThread:@selector(_shutterButtonClicked) withObject:nil waitUntilDone:NO];
}

%new
- (void)burst
{
    if (isPhotoCamera()) {
        if (counterAnimate)
            return;
        PLCameraController *controller = cameraController();
        PLCameraView *cameraView = [controller delegate];
        noAutofocus = YES;
        burst = YES;
        counter.hidden = NO;
        counterBG.hidden = NO;
        counter.alpha = 1;
        counterBG.alpha = kCounterBGAlpha;
        disableIris = DisableIris;
        [%c(PLCameraView) cancelPreviousPerformRequestsWithTarget: self selector: @selector(autofocus) object:nil];
        if ([controller isFocusLockSupported] && noAutofocus)
            [controller _lockFocus:YES lockExposure:NO lockWhiteBalance:NO];
        [controller setFocusDisabled:YES];
        [cameraView _setShouldShowFocus:NO];
        if (isBackCamera())
            [cameraView _setFlashMode:-1];
        if (!AllowHDR)
            [cameraView setHDRIsOn:NO];
        if ([controller respondsToSelector:@selector(setFaceDetectionEnabled:)])
            [controller setFaceDetectionEnabled:NO];
        [self takePhoto];
        BMPressTimer = [NSTimer scheduledTimerWithTimeInterval:Interval target:self selector:@selector(takePhoto) userInfo:nil repeats:YES];
        [BMPressTimer retain];
    }
}

%new
- (void)sendReleased
{
    if (isPhotoCamera()) {
        invalidateTimer();
        ignoreCapture = burst;
        cleanup();
        hideCounter();
    }
}

%end

%hook PLCameraView

- (void)_handleVolumeButtonUp
{
    %orig;
    if (isPhotoCamera())
        [(PLCameraButton *)[(PLCameraButtonBar *) self.bottomButtonBar cameraButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)_handleVolumeButtonDown {
    if (isPhotoCamera())
        [(PLCameraButton *)[(PLCameraButtonBar *) self.bottomButtonBar cameraButton] sendActionsForControlEvents:UIControlEventTouchDown];
    else
        %orig;
}

- (void)_shutterButtonClicked {
    if (isPhotoCamera()) {
        if (ignoreCapture) {
            ignoreCapture = NO;
            return;
        }
    }
    %orig;
}

- (void)dealloc {
    invalidateTimer();
    if (counter != nil) {
        [counter removeFromSuperview];
        [counter release];
        counter = nil;
    }
    if (counterBG != nil) {
        [counterBG removeFromSuperview];
        [counterBG release];
        counterBG = nil;
    }
    %orig;
}

- (void)viewDidAppear {
    %orig;
    if (counter == nil) {
        counter = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 20.0f)];
        counter.text = singleCounter ? @"0" : @"000";
        counter.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
        counter.textColor = [UIColor whiteColor];
        counter.backgroundColor = [UIColor clearColor];
        counter.autoresizingMask = 2;
        counter.hidden = YES;
    }
    if (counterBG == nil) {
        counterBG = [[UIView alloc] initWithFrame:CGRectMake(-28.0f, -48.0f, 56.0f, 56.0f)];
        counterBG.alpha = kCounterBGAlpha;
        counterBG.backgroundColor = [UIColor blackColor];
        counterBG.layer.cornerRadius = 28.0f;
        counterBG.hidden = YES;
    }
    UIView *textOverlayView = MSHookIvar<UIView *>(self, "_textOverlayView");
    [counterBG addSubview:counter];
    counter.center = CGPointMake(28.0f, 28.0f);
    counter.textAlignment = NSTextAlignmentCenter;
    [textOverlayView addSubview:counterBG];
}

- (void)_setupAnimatePreviewDown:(id)down flipImage:(BOOL)image panoImage:(BOOL)image3 snapshotFrame:(CGRect)frame {
    if (isPhotoCamera() && !isCapturingVideo() && burst) {
        if (DisableAnim)
            return;
    }
    %orig;
}

- (void)openIrisWithDidFinishSelector:(SEL)openIrisWith withDuration:(float)duration {
    if (isPhotoCamera() && DisableIris && disableIris && burst && !isCapturingVideo()) {
        [self hideStaticClosedIris];
        [self takePictureOpenIrisAnimationFinished];
        return;
    }
    %orig;
}

- (void)closeIrisWithDidFinishSelector:(SEL)closeIrisWith withDuration:(float)duration {
    if (isPhotoCamera() && DisableIris && disableIris && burst && !isCapturingVideo()) {
        [self _clearFocusViews];
        [self resumePreview];
        return;
    }
    %orig;
}

%end

%hook PLCameraController

- (BOOL)isHDREnabled
{
    BOOL enabled = %orig;
    if (isPhotoCamera())
        counterBG.frame = enabled ? CGRectMake(0.0f, -63.0f, 56.0f, 56.0f) : CGRectMake(-28.0f, -48.0f, 56.0f, 56.0f);
    return enabled;
}

- (void)capturePhoto {
    if (isPhotoCamera()) {
        if (burst) {
            photoCount++;
            if (limitedPhotosCount > 0) {
                if (photoCount == limitedPhotosCount)
                    invalidateTimer();
            }
            char cString[4];
            sprintf(cString, "%d", photoCount);
            NSString *s = [[[NSString alloc] initWithUTF8String:cString] autorelease];
            if (singleCounter || photoCount >= 100)
                counter.text = s;
            else
                counter.text = [NSString stringWithFormat:@"%03u", photoCount];
            if (DisableIris) {
                if (LiveWell) {
                    NSMutableArray *imgArray = MSHookIvar<NSMutableArray *>([self delegate], "_previewWellImages");
                    if (imgArray.count > 0)
                        [self.delegate _updatePreviewWellImage:(UIImage *)[imgArray lastObject]];
                }
            }
        }
    }
    %orig;
}

- (void)autofocus {
    if (isPhotoCamera()) {
        if (noAutofocus && burst)
            return;
    }
    %orig;
}

- (void)_autofocus:(BOOL)focus autoExpose:(BOOL)expose {
    if (isPhotoCamera()) {
        if (noAutofocus && burst)
            return;
    }
    %orig;
}

%end

extern "C" void AudioServicesPlaySystemSound(SystemSoundID sound);
%hookf(void, AudioServicesPlaySystemSound, SystemSoundID sound){
    if (sound == 1108 && noCaptureSound && BMPressTimer != nil)
        return;
    %orig(sound);
}

%ctor
{
    HaveObserver()
    callback();
    if (BurstMode) {
        %init;
    }
}
