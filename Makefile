APP_NAME = SoniMate
BUILD_DIR = .build
APP_BUNDLE = $(APP_NAME).app

.PHONY: all build bundle run clean

all: bundle

build:
	swift build -c release

bundle: build
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/release/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Info.plist $(APP_BUNDLE)/Contents/Info.plist
	touch $(APP_BUNDLE)

run: bundle
	open $(APP_BUNDLE)

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(APP_BUNDLE)
