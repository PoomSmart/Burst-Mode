PACKAGE_VERSION = 1.5.7
TARGET = iphone:clang:9.0:5.0

include $(THEOS)/makefiles/common.mk

AGGREGATE_NAME = BurstMode
SUBPROJECTS = BurstModeiOS56 BurstModeiOS7 BurstModeiOS8 BurstModeiOS910

include $(THEOS_MAKE_PATH)/aggregate.mk

TWEAK_NAME = BurstMode
BurstMode_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = BurstModeSettings
BurstModeSettings_FILES = BurstModePreferenceController.m
BurstModeSettings_INSTALL_PATH = /Library/PreferenceBundles
BurstModeSettings_LDFLAGS = -fobjc-arc
BurstModeSettings_PRIVATE_FRAMEWORKS = Preferences
BurstModeSettings_FRAMEWORKS = CoreGraphics GraphicsServices Social UIKit
BurstModeSettings_EXTRA_FRAMEWORKS = CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/BurstMode.plist$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)
