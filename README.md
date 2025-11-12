# Maklaar Lek !!!

### 🧰 System Requirements

- **Flutter SDK**: Stable channel, version `3.32.2`
- **Java**: Version `22`

---

### 🚀 Run the Application

```shell
flutter run
```


📦 Update iOS Pods
```shell
cd ios
pod init
pod update
pod install
cd ..
```

🧹 Clean Pub Cache
```shell
flutter clean
flutter pub cache clean
flutter pub get
```

🔧 Repair Pub Cache
```shell
flutter clean
flutter pub cache repair
flutter pub get
```



📱 Generate Android APK
```shell
flutter build apk --split-per-abi
open  build/app/outputs/flutter-apk/
```

🛠️ Solve Common iOS Errors
```shell
flutter clean
rm -Rf ios/Pods
rm -Rf ios/.symlinks
rm -Rf ios/Flutter/Flutter.framework
rm -Rf Flutter/Flutter.podspec
rm ios/podfile.lock
cd ios 
pod deintegrate
sudo rm -rf ~/Library/Developer/Xcode/DerivedData
flutter pub cache repair
flutter pub get 
pod install 
pod update 
```
