## Purpose
Short, actionable guidance for AI coding agents working on this Flutter project (OccazCar).

### Big picture
- Project is a Flutter app with a feature-first / clean-architecture layout under `lib/`.
- Key folders:
  - `lib/features/<feature>/domain` and `lib/features/<feature>/presentation` — feature boundaries.
  - `lib/data/datasources/{local,remote}` — platform/IO adapters (Hive, preferences, HTTP, Firebase).
  - `lib/data/models` — DTOs and simple data classes.
  - `lib/data/repositories` — data access implementations used by features.
  - `lib/core` — app-wide utilities: `constants`, `services`, `di`, `routes`, `theme`, `utils`.

### Integration & important files
- App entry: `lib/main.dart` (standard Flutter entrypoint).
- Dependency injection bootstrap: `lib/core/di/injection.dart` (currently a scaffold; register singletons/factories here).
- Navigation: `lib/core/routes/app_router.dart` (central route registration — add new routes here).
- Remote API & Firebase adapters: `lib/data/datasources/remote/api_service.dart` and `firebase_service.dart`.
- Local persistence: `lib/data/datasources/local/hive_service.dart` and `preferences_service.dart`.
- Cross-cutting services: `lib/core/services/*` (AI, chat, location, notification, storage) — these are the expected integration points for platform features.

### Conventions and patterns (do this exactly)
- Feature creation: when adding a feature `foo` create:
  - `lib/features/foo/domain` — business logic, use-cases, repository interfaces
  - `lib/features/foo/presentation` — widgets, pages, state management
  - Add any model DTOs to `lib/data/models` and implement repository in `lib/data/repositories`.
- Keep UI code in `presentation`; keep logic in `domain` or `data` (repositories/adapters).
- Register new repository implementations and service singletons in `lib/core/di/injection.dart`.
- Expose app strings and constants through `lib/core/constants/*.dart`.

### Build / run / test (developer commands)
- Install deps and run on default device:
```bash
flutter pub get
flutter run
```
- Run unit & widget tests:
```bash
flutter test
```
- Build Android APK (Gradle Kotlin DSL used):
```bash
flutter build apk
# or from android/ on Windows:
cd android && gradlew.bat assembleDebug
```
- Run on Windows desktop:
```bash
flutter run -d windows
```

### What to look for when editing
- Prefer small, focused edits that keep public APIs stable.
- When adding features, update: DI (`lib/core/di/injection.dart`), routes (`lib/core/routes/app_router.dart`), and constants if new strings or keys are required.
- For platform features (notifications, location, storage), check `lib/core/services/*` and `lib/data/datasources/*` for the intended adapter location.

### Examples (canonical edits)
- Add feature `chat`:
  - Create `lib/features/chat/domain` and `lib/features/chat/presentation`.
  - Add `message_model.dart` to `lib/data/models` (if not present) and `message_repository.dart` to `lib/data/repositories`.
  - Register repository and `ChatService` in `lib/core/di/injection.dart` and add route to `lib/core/routes/app_router.dart`.

### Limitations / current gaps
- Many DI, router and service files are scaffolds — expect them to be the canonical registration points but confirm with the repo owner before large refactors.
- Do not assume advanced runtime behavior (background handlers, remote config) unless code exists in `lib/core/services` or `android/` / `windows/runner`.

If anything in these notes is unclear or you want me to expand examples (DI registration, a sample feature scaffold, or a CI-friendly test runner), tell me which section to iterate on.
