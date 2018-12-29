TARGET = iphone:clang:11.2:5.0

include $(THEOS)/makefiles/common.mk

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