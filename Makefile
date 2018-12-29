PACKAGE_VERSION = 1.5.8a

include $(THEOS)/makefiles/common.mk

AGGREGATE_NAME = BurstMode
SUBPROJECTS = BurstModeiOS56 BurstModeiOS7 BurstModeiOS8 BurstModeiOS910 BurstModeLoader BurstModePref

include $(THEOS_MAKE_PATH)/aggregate.mk
