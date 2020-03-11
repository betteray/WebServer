THEOS_DEVICE_IP=192.168.2.5

include $(THEOS)/makefiles/common.mk

# FULL PATH of the GCDWebServer repo on your own machine
GCDWebServer_ROOT = ./vendor/GCDWebServer

# Function to convert /foo/bar to -I/foo/bar
dtoim = $(foreach d,$(1),-I$(d))

# Gather GCDWebServer sources
SOURCES  = $(shell find $(GCDWebServer_ROOT)/GCDWebServer -name '*.m')
SOURCES += $(shell find $(GCDWebServer_ROOT)/GCDWebServer -name '*.mm')
# Gather GCDWebServer headers for search paths
_IMPORTS  = $(shell /bin/ls -d $(GCDWebServer_ROOT)/GCDWebServer/*/)

# Gather GCDWebServer GCDWebUploader sources
SOURCES  += $(shell find $(GCDWebServer_ROOT)/GCDWebUploader -name '*.m')
SOURCES += $(shell find $(GCDWebServer_ROOT)/GCDWebUploader -name '*.mm')
# Gather GCDWebServer GCDWebUploader headers for search paths
_IMPORTS  += $(shell /bin/ls -d $(GCDWebServer_ROOT)/GCDWebUploader/)
IMPORTS = -I$(GCDWebServer_ROOT)/Classes/ $(call dtoim, $(_IMPORTS))

RESOURCE_DIR = ./Resources/
GCDWebServerRESOURCE_DIR = $(GCDWebServer_ROOT)/GCDWebUploader/GCDWebUploader.bundle/*

$(shell rm -rf $(RESOURCE_DIR))
$(shell mkdir $(RESOURCE_DIR))
$(shell cp -r $(GCDWebServerRESOURCE_DIR) $(RESOURCE_DIR))

BUNDLE_NAME = me.ray.webserver
me.ray.webserver_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
include $(THEOS)/makefiles/bundle.mk

TWEAK_NAME = WebServer

WebServer_FILES = Tweak.xm $(SOURCES)
WebServer_CFLAGS = -fobjc-arc -w $(IMPORTS)

include $(THEOS_MAKE_PATH)/tweak.mk
