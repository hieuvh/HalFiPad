ARCHS = arm64 arm64e
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

export TARGET = iphone:13.3
export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc

TWEAK_NAME = HalFiPad

HalFiPad_FILES = Tweak.xm
HalFiPad_LIBRARIES = MobileGestalt

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += HalFiPadPrefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "sbreload"