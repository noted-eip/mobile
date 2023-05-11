# Run this command upon cloning the repository or when wanting to
# fetch the latest version of the protorepo.
update-submodules:
	git submodule update --init --remote

build-runner:
	flutter pub get
	flutter pub upgrade
	flutter pub upgrade --major-versions
	flutter pub run build_runner build --delete-conflicting-outputs