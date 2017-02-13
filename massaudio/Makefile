THEOS_DEVICE_IP = 192.168.22.110

TARGET = iphone:latest:7.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MassAudio
MassAudio_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
