TARGET := iphone:clang:latest:3.0
export TARGET=iphone:clang:3.0

INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS := armv6 armv7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Retranslate

Retranslate_FILES = Tweak.x \
    $(wildcard lib/TouchJSON/*.m) \
    $(wildcard lib/TouchJSON/JSON/*.m) \
    $(wildcard lib/TouchJSON/Extensions/*.m)

Retranslate_CFLAGS = -Wno-deprecated-declarations
Retranslate_CFLAGS += -I$(THEOS_PROJECT_DIR)/lib/TouchJSON
Retranslate_CFLAGS += -I$(THEOS_PROJECT_DIR)/lib/TouchJSON/JSON
Retranslate_CFLAGS += -I$(THEOS_PROJECT_DIR)/lib/TouchJSON/Extensions

include $(THEOS_MAKE_PATH)/tweak.mk