APP_NAME = SoniMate
APP_VERSION = 1.1.0
BUILD_DIR = .build
APP_BUNDLE = $(APP_NAME).app

.PHONY: all build bundle dmg run clean

all: bundle

build:
	swift build -c release

bundle: build
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/release/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Info.plist $(APP_BUNDLE)/Contents/Info.plist
	cp $(APP_NAME).icns $(APP_BUNDLE)/Contents/Resources/
	touch $(APP_BUNDLE)

dmg: bundle
	rm -rf /tmp/$(APP_NAME) && mkdir -p /tmp/$(APP_NAME)
	cp -R $(APP_BUNDLE) /tmp/$(APP_NAME)/
	ln -s /Applications /tmp/$(APP_NAME)/Applications
	hdiutil create -quiet -volname "$(APP_NAME) $(APP_VERSION)" -srcfolder /tmp/$(APP_NAME) -ov "$(APP_NAME)-$(APP_VERSION).dmg"
	rm -rf /tmp/$(APP_NAME)

run: bundle
	open $(APP_BUNDLE)

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(APP_BUNDLE)
	rm -f $(APP_NAME)-*.dmg
