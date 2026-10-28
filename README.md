# Flashlight

A minimal flashlight app that controls the camera LED on Android and iOS.

## Setup

Install the Flutter stable SDK, then fetch the dependencies:

```sh
flutter pub get
```

Run on a connected device:

```sh
flutter run
```

A physical Android or iOS device is required; emulators generally do not have a
camera flash. The app requests camera access when you first turn on the torch.
For iOS distribution, configure your signing team in Xcode.
