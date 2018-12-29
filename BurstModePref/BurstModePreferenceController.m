#define KILL_PROCESS
#define UIFUNCTIONS_NOT_C
#import <UIKit/UIKit.h>
#import <UIKit/UIImage+Private.h>
#import <UIKit/UIColor+Private.h>
#import <Preferences/PSControlTableCell.h>
#import <CepheiPrefs/HBListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Preferences/PSSpecifier.h>
#import <Social/Social.h>
#import <GraphicsServices/GraphicsServices.h>
#import <dlfcn.h>
#import "../BurstMode.h"
#import "../../PSPrefs.x"

DeclarePrefsTools()

extern CFStringRef kGSHDRImageCaptureCapability;
static BOOL (*MGGetBoolAnswer)(CFStringRef);

static BOOL hasCapability(CFStringRef capability) {
    if (!isiOS7Up)
        return GSSystemHasCapability(capability);
    if (!MGGetBoolAnswer) {
        void *libMobileGestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_LAZY);
        if (libMobileGestalt)
            MGGetBoolAnswer = dlsym(libMobileGestalt, "MGGetBoolAnswer");
    }
    if (MGGetBoolAnswer)
        return MGGetBoolAnswer(capability);
    return NO;
}

static BOOL hasHDR() {
    return hasCapability(kGSHDRImageCaptureCapability);
}

@interface BurstModePreferenceController : HBListController
@property (nonatomic, retain) PSSpecifier *slidersSpec;
@property (nonatomic, retain) PSSpecifier *holdTimeSliderSpec;
@property (nonatomic, retain) PSSpecifier *intervalSpec;
@property (nonatomic, retain) PSSpecifier *burstModeSafeSpec;
@property (nonatomic, retain) PSSpecifier *disableIrisSpec;
@property (nonatomic, retain) PSSpecifier *disableAnimSpec;
@property (nonatomic, retain) PSSpecifier *liveWellSpec;
@property (nonatomic, retain) PSSpecifier *allowHDRSpec;
@property (nonatomic, retain) PSSpecifier *expFormatSpec;
@property (nonatomic, retain) PSSpecifier *animIndSpec;
@property (nonatomic, retain) PSSpecifier *help56Spec;
@property (nonatomic, retain) PSSpecifier *help78Spec;
@property (nonatomic, retain) PSSpecifier *description2Spec;
@end

@interface BMSliderTableCell : PSControlTableCell
@end

@implementation BMSliderTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)spec {
    if (self == [super initWithStyle:style reuseIdentifier:identifier specifier:spec]) {
        UISlider *slider = [[[UISlider alloc] init] autorelease];
        slider.continuous = NO;
        slider.minimumValue = [[spec propertyForKey:@"min"] floatValue];
        slider.maximumValue = [[spec propertyForKey:@"max"] floatValue];
        NSString *key = [spec propertyForKey:@"key"];
        float value = floatForKey(key, [[spec propertyForKey:@"default"] floatValue]);
        slider.value = value;
        self.control = slider;
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, 14)] autorelease];
        label.text = [NSString stringWithFormat:@"%.2f", value];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        self.accessoryView = label;
        self.textLabel.text = [spec propertyForKey:@"cellName"];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)sliderValueChanged:(UISlider *)slider {
    setFloatForKey(slider.value, [self.specifier propertyForKey:@"key"]);
    UILabel *label = (UILabel *)self.accessoryView;
    label.text = [NSString stringWithFormat:@"%.2f", slider.value];
    DoPostNotification();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize textSize;
    CGFloat textWidth;
    UILabel *label = self.textLabel;
    if (isiOS7Up) {
        textSize = [label.text sizeWithAttributes:@{NSFontAttributeName:[label font]}];
        textWidth = textSize.width;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        textSize = [label.text sizeWithFont:label.font];
        textWidth = textSize.width;
#pragma clang diagnostic pop
    }
    CGFloat leftPad = textWidth + 28.0;
    CGFloat rightPad = 14.0;
    UIView *contentView = (UIView *)self.contentView;
    UISlider *slider = (UISlider *)self.control;
    slider.center = contentView.center;
    slider.frame = CGRectMake(leftPad, slider.frame.origin.y, contentView.frame.size.width - leftPad - rightPad, slider.frame.size.height);
}

@end

@implementation BurstModePreferenceController

HavePrefs()

- (void)masterSwitch:(id)value specifier:(PSSpecifier *)spec {
    [self setPreferenceValue:value specifier:spec];
    killProcess("Camera");
    if (isiOS7Up)
        killProcess("MobileSlideshow");
}

HaveBanner2(@"Burst Mode", isiOS7Up ? UIColor.systemGrayColor : UIColor.grayColor, @"Extensions for Burst, right here", UIColor.grayColor)

- (id)init {
    if (self == [super init]) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = isiOS7Up ? UIColor.systemGrayColor : UIColor.whiteColor;
        appearanceSettings.navigationBarBackgroundColor = UIColor.grayColor;
        appearanceSettings.navigationBarTitleColor = UIColor.whiteColor;
        self.hb_appearanceSettings = appearanceSettings;
        if (isiOS6Up) {
            UIButton *heart = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
            UIImage *image = [UIImage imageNamed:@"Heart" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/BurstModeSettings.bundle"]];
            if (isiOS7Up)
                image = [image _flatImageWithColor:UIColor.whiteColor];
            [heart setImage:image forState:UIControlStateNormal];
            [heart sizeToFit];
            [heart addTarget:self action:@selector(love) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:heart] autorelease];
        }
    }
    return self;
}

- (void)love {
    SLComposeViewController *twitter = [[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter] retain];
    twitter.initialText = @"#BurstMode by @PoomSmart is really awesome!";
    [self.navigationController presentViewController:twitter animated:YES completion:nil];
    [twitter release];
}

- (void)setPhotosLimit:(id)param {
    [self hideKeyboard];
}

- (void)hideKeyboard {
    [[super view] endEditing:YES];
}

- (NSArray *)specifiers {
    if (_specifiers == nil) {
        NSMutableArray *specs = [NSMutableArray arrayWithArray:[self loadSpecifiersFromPlistName:@"BurstMode" target:self]];
        for (PSSpecifier *spec in specs) {
            NSString *Id = [[spec properties] objectForKey:@"id"];
            if ([Id isEqualToString:@"Sliders"])
                self.slidersSpec = spec;
            else if ([Id isEqualToString:@"HoldTimeSlider"])
                self.holdTimeSliderSpec = spec;
            else if ([Id isEqualToString:@"Interval"])
                self.intervalSpec = spec;
            else if ([Id isEqualToString:@"BurstModeSafe"])
                self.burstModeSafeSpec = spec;
            else if ([Id isEqualToString:@"DisableIris"])
                self.disableIrisSpec = spec;
            else if ([Id isEqualToString:@"DisableAnim"])
                self.disableAnimSpec = spec;
            else if ([Id isEqualToString:@"LiveWell"])
                self.liveWellSpec = spec;
            else if ([Id isEqualToString:@"AllowHDR"])
                self.allowHDRSpec = spec;
            else if ([Id isEqualToString:@"expFormat"])
                self.expFormatSpec = spec;
            else if ([Id isEqualToString:@"AnimInd"])
                self.animIndSpec = spec;
            else if ([Id isEqualToString:@"help56"])
                self.help56Spec = spec;
            else if ([Id isEqualToString:@"help78"])
                self.help78Spec = spec;
            else if ([Id isEqualToString:@"Description2"])
                self.description2Spec = spec;
        }
        if (isiOS7Up) {
            if (!isiOS70)
                [specs removeObject:self.allowHDRSpec];
            [specs removeObject:self.slidersSpec];
            [specs removeObject:self.holdTimeSliderSpec];
            [specs removeObject:self.intervalSpec];
            [specs removeObject:self.burstModeSafeSpec];
            [specs removeObject:self.disableIrisSpec];
            [specs removeObject:self.disableAnimSpec];
            [specs removeObject:self.liveWellSpec];
            [specs removeObject:self.help56Spec];
            [specs removeObject:self.description2Spec];
            if (isiOS8Up)
                [specs removeObject:self.expFormatSpec];
        } else {
            [specs removeObject:self.expFormatSpec];
            [specs removeObject:self.animIndSpec];
            [specs removeObject:self.help78Spec];
        }
        if (!hasHDR())
            [specs removeObject:self.allowHDRSpec];
        _specifiers = [specs copy];
    }
    return _specifiers;
}

@end
