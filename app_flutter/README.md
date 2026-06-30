# Platform Console (Flutter)

Generic UI shell that renders object types discovered at runtime.
No domain knowledge is compiled into the application.

## Run

```bash
flutter run -d macos
```

## Test

```bash
flutter test
flutter test -d macos integration_test/
```

## Data Source

Select backend at runtime:
- `flutter run` — SQLite (default)
- `flutter run --dart-define=DATA_SOURCE=firebase` — Firebase

## Dependencies

- `provider` — state management
- `sqflite_common_ffi` — SQLite
- `firebase_core` + `cloud_firestore` — Firebase
- `flex_color_scheme` — theming
