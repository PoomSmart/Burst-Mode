TARGET = iphone:clang:latest:9.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = BurstModeiOS910
BurstModeiOS910_FILES = Tweak.xm
BurstModeiOS910_FRAMEWORKS = AudioToolbox UIKit
BurstModeiOS910_EXTRA_FRAMEWORKS = CydiaSubstrate
BurstModeiOS910_LIBRARIES = MobileGestalt
BurstModeiOS910_INSTALL_PATH = /Library/Application Support/BurstMode

include $(THEOS_MAKE_PATH)/library.mk
