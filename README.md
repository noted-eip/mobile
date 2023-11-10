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

### check secu

name : entre 4 et 20
password : min 4 et 20
email: valid

code confirmation : 4 chiffres -> forgot pass et validation account

204 : no content
500: error server
400 : user error -> argument pass no good
403: user non identifé

db :
404 : 'not found'
'invalid token'
'already exist'
'invalid argument'
'internal error'
