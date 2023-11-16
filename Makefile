# Run this command upon cloning the repository or when wanting to
# fetch the latest version of the protorepo.
update-submodules:
	git submodule update --init --remote

solve-submodules:
	git submodule update --recursive

firebase:
	flutterfire configure

update-ios:
	flutter clean
	flutter build ios
	cd ./ios/ && \
	pod install && \
	pod update && \
	pod repo update && \
	pod install --repo-update

build-runner:
	cd ./protorepo/openapi/dart-dio/ ; \
	flutter pub get; \
	flutter pub upgrade; \
	flutter pub upgrade --major-versions; \
	flutter pub run build_runner build --delete-conflicting-outputs

clean:
	flutter clean  
	rm -Rf ios/Pods
	rm -Rf ios/.symlinks
	rm -Rf ios/Flutter/Flutter.framework
	rm -Rf ios/Flutter/Flutter.podspec
	flutter pub get
	cd ./ios/ && \
	pod install && \
	arch -x86_64 pod install

active-android-debug:
	adb shell setprop debug.firebase.analytics.app noted_mobile

desactive-android-debug:
	adb shell setprop debug.firebase.analytics.app .none.

show-fix:
	dart fix --dry-run

fix:
	dart fix --apply

clean-auto: 
	@find . -name "*.g.dart" -exec rm -f {} \;