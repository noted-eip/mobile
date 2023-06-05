# noted_mobile

Mobile app for Noted

## TODO / IN PROGRESS

Revoir pour tous les try catch de requete api la récupération des messages d'erreurs

## NEXT Sprint

...

## Command

when protorepo is updated :

run :
make update-submodules

in mobile project root for update sub-module

run :

flutter pub get
flutter pub upgrade
flutter pub upgrade --major-versions
flutter pub run build_runner build --delete-conflicting-outputs

in mobile/protorepo/openapi/dart-dio for re-run build runner

flutter clean  
rm -Rf ios/Pods
rm -Rf ios/.symlinks
rm -Rf ios/Flutter/Flutter.framework
rm -Rf ios/Flutter/Flutter.podspec
flutter pub get
cd ios
pod install
arch -x86_64 pod install
