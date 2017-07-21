TARGET = iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = BurstModeiOS7
BurstModeiOS7_FILES = Tweak.xm
BurstModeiOS7_FRAMEWORKS = AudioToolbox UIKit
BurstModeiOS7_EXTRA_FRAMEWORKS = CydiaSubstrate
BurstModeiOS7_LIBRARIES = MobileGestalt
BurstModeiOS7_INSTALL_PATH = /Library/Application Support/BurstMode

include $(THEOS_MAKE_PATH)/library.mk
