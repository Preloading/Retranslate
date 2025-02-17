TARGET := iphone:clang:latest:3.1
INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS := armv7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Retranslate

Retranslate_FILES = Tweak.x
Retranslate_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
