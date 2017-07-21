TARGET = iphone:clang:latest:8.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = BurstModeiOS8
BurstModeiOS8_FILES = Tweak.xm
BurstModeiOS8_FRAMEWORKS = AudioToolbox UIKit
BurstModeiOS8_EXTRA_FRAMEWORKS = CydiaSubstrate
BurstModeiOS8_LIBRARIES = MobileGestalt
BurstModeiOS8_INSTALL_PATH = /Library/Application Support/BurstMode

include $(THEOS_MAKE_PATH)/library.mk
