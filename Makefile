ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CarPlayVideoWallpaper
CarPlayVideoWallpaper_FILES = Tweak.xm
CarPlayVideoWallpaper_CFLAGS = -fobjc-arc
CarPlayVideoWallpaper_FRAMEWORKS = UIKit AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = CarPlayVideoWallpaperPrefs
CarPlayVideoWallpaperPrefs_FILES = CarPlayVideoWallpaperPrefs/RootListController.m
CarPlayVideoWallpaperPrefs_INSTALL_PATH = /Library/PreferenceBundles
CarPlayVideoWallpaperPrefs_FRAMEWORKS = UIKit AVKit
CarPlayVideoWallpaperPrefs_PRIVATE_FRAMEWORKS = Preferences
CarPlayVideoWallpaperPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
