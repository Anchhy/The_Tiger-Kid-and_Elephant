# The Tiger, Kid, and Elephant

An offline Khmer educational mobile adventure game built with Flutter and
Flame. The project is currently at the Week 1 foundation stage: it provides a
landscape Flutter shell, a home screen, and navigation to an empty Flame game
scene.

## Requirements

- Flutter 3.50.0 (stable)
- Dart 3.14.0
- Android SDK for Android development
- Ubuntu Linux desktop tools: `clang`, `cmake`, `ninja-build`, `pkg-config`,
  `libgtk-3-dev`, and `libstdc++-12-dev`

The version constraints are also recorded in `pubspec.yaml`. If a newer
compatible Flutter stable release is used, run the validation commands below
before committing dependency changes.

## Install dependencies

From the project root:

```bash
flutter pub get
```

On Ubuntu 24.04, install the Linux desktop build requirements with:

```bash
sudo apt update
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev
```

## Run on Ubuntu

```bash
flutter run -d linux
```

To validate the code without starting a desktop window:

```bash
dart format lib test
flutter analyze
flutter test
```

## Test on Android

Check the Android toolchain and list available targets:

```bash
flutter doctor -v
flutter emulators
flutter devices
```

This development machine has an emulator named `Medium_Phone_API_37.0`. Start
it and then run the app with:

```bash
flutter emulators --launch Medium_Phone_API_37.0
flutter devices
flutter run -d emulator-5554
```

Use the device ID shown by `flutter devices` if it differs from
`emulator-5554`. A physical Android device can be used after enabling USB
debugging and authorizing the computer.

## Main dependencies

- Flutter SDK for application structure and platform integration
- `material_ui` for Material Design UI on Flutter 3.50+
- Flame `1.38.2` for the game scene

## Project structure

```text
lib/
├── main.dart                 # Startup, orientation, theme, app root
├── screens/
│   ├── home_screen.dart      # Title and Play Game action
│   └── game_screen.dart      # Flame scene and return control
├── game/                     # Future shared game components and levels
├── puzzles/                  # Future Khmer educational puzzles
├── services/                 # Future offline application services
└── ui/                       # Future shared UI widgets
```

## Week 1 functionality

- Starts in landscape orientation where the platform supports it
- Displays the title **The Tiger, Kid, and Elephant**
- Displays a **Play Game** button
- Opens a Flame `GameWidget` placeholder
- Provides a return-to-home button from the game scene
- Includes widget tests for the home screen and navigation flow

## Known limitations

- The Flame scene is intentionally empty; gameplay is not part of Week 1.
- Player movement, tiger AI, and Khmer puzzles are not implemented yet.
- No Firebase, backend, or online service is configured; the game targets
  offline use.
- Android runtime verification requires a running emulator or connected device.
- Linux desktop builds require the Ubuntu packages listed above.
