TARGET = iphone:clang:latest:5.0
ARCHS = armv7

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = BurstModeiOS56
BurstModeiOS56_FILES = Tweak.xm
BurstModeiOS56_FRAMEWORKS = AudioToolbox UIKit
BurstModeiOS56_EXTRA_FRAMEWORKS = CydiaSubstrate
BurstModeiOS56_INSTALL_PATH = /Library/Application Support/BurstMode

include $(THEOS_MAKE_PATH)/library.mk
