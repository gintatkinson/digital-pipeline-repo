# Installation Guide

> How to set up, build, and run the platform from scratch.

## Table of Contents

1. Prerequisites
2. Clone the Repository
3. Flutter Setup
4. Python Setup (Pipeline Tools)
5. Firebase Setup (Optional)
6. Build and Run
7. Verify Installation
8. Troubleshooting

## 1. Prerequisites

- **Git** — to clone the repository
- **Flutter SDK** — version 3.12+ installed and on your PATH
- **Dart** — included with Flutter (3.12+)
- **Python 3.8+** — for pipeline scripts and YANG compiler
- **Xcode** (macOS only) — for macOS builds
- **Node.js 18+** (optional) — for Firebase emulator

Verify:

```bash
flutter --version
dart --version
python3 --version
git --version
```

## 2. Clone the Repository

```bash
git clone https://github.com/gintatkinson/digital-pipeline-repo.git
cd digital-pipeline-repo
```

## 3. Flutter Setup

```bash
cd app_flutter
flutter pub get
flutter test
```

Expected output: "All tests passed!"

## 4. Python Setup (Pipeline Tools)

```bash
pip install pyang
python3 scripts/compile_yang.py --help
```

Expected output: Shows compiler usage.

## 5. Firebase Setup (Optional)

Run the setup script from the `app_flutter` directory:

```bash
cd app_flutter
./scripts/setup-firebase-emulator.sh
```

This script:
1. Installs `firebase-tools` globally via npm (if not already present).
2. Creates `firebase.json` with the Firestore emulator on port 8080.
3. Creates `firestore.rules` (permissive rules for local development).
4. Starts the emulator in the background.
5. Seeds test data via `scripts/seed-firebase-data.py`.

See [Firebase Configuration Guide](firebase-configuration.md) for detailed setup.

## 6. Build and Run

### Development

```bash
cd app_flutter
flutter run -d macos
```

### Production Build

```bash
cd app_flutter
flutter build macos --release
```

### With Firebase

```bash
cd app_flutter
flutter run --dart-define=DATA_SOURCE=firebase
```

## 7. Verify Installation

```bash
cd app_flutter
flutter test
flutter test -d macos integration_test/
flutter analyze
```

All must pass with zero errors.

## 8. Troubleshooting

### Flutter Clean

If you encounter build issues, reset the build cache:

```bash
cd app_flutter
flutter clean
flutter pub get
```

### build.db locked

If you see `build.db locked` errors, kill stale Dart processes:

```bash
killall dart 2>/dev/null; killall flutter 2>/dev/null
flutter clean
```

### Python path issues

Ensure `pyang` is on your PATH. If installed via pip and still not found:

```bash
python3 -m pip install --user pyang
export PATH="$HOME/Library/Python/3.x/bin:$PATH"
```
