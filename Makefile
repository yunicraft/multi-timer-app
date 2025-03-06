.PHONY: icon splash clean build

# 앱 아이콘 적용
icon:
	@echo "앱 아이콘 적용 중..."
	flutter pub run flutter_launcher_icons

# 스플래시 화면 변경
splash-update:
	@echo "스플래시 화면 업데이트 중..."
	flutter pub run flutter_native_splash:remove
	flutter clean
	flutter pub get
	flutter pub run flutter_native_splash:create

# 플러터 빌드 캐시 정리
clean:
	@echo "플러터 빌드 캐시 정리 중..."
	flutter clean
	flutter pub cache clean
	flutter pub get

# 안드로이드 빌드 캐시 정리
clean-android-build-cache:
	@echo "안드로이드 빌드 캐시 정리 중..."
	flutter clean
	flutter pub cache clean
	flutter pub get
	cd android && ./gradlew clean && cd ..

# iOS 빌드 캐시 정리
clean-ios-build-cache:
	@echo "iOS 빌드 캐시 정리 중..."
	cd ios && xcodebuild clean && cd ..

# 안드로이드 앱 빌드
build-android:
	@echo "Android 앱 빌드 중..."
	flutter build appbundle --release

# iOS 앱 빌드
build-ios:
	@echo "iOS 앱 빌드 중..."
	flutter build ipa


