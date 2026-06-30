# Digital Pipeline Repository

Platform-agnostic data management UI shell built with Flutter.
Discovers object types, fields, and relationships at runtime
from a swappable data source (SQLite, Firebase, or custom).

## Quick Start

```bash
git clone https://github.com/gintatkinson/digital-pipeline-repo.git
cd digital-pipeline-repo/app_flutter
flutter pub get
flutter run -d macos
```

See [Installation Guide](docs/operations/install-guide.md) for full setup.

## Project Structure

- `app_flutter/` — Flutter UI application
- `scripts/` — Build-time tools (YANG compiler, DB generator, Firebase seeder)
- `skills/` — Agent pipeline skills (spec engineering, debugging)
- `docs/` — Architecture, operations, and design documentation
