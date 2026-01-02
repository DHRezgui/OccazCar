# mobile

OccazCar doit inclure des fonctionnalités de gestion de l'offre et de la demande comme la publication d'annonces, le suivi des véhicules, et la gestion des acheteurs potentiels, en plus de caractéristiques spécifiques à l'automobile telles que la géolocalisation, l'historique du véhicule, et la communication directe entre les utilisateurs.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Project-specific setup

- This repo uses Riverpod for DI/state management, Hive for local cache, and Firebase for auth, messaging and Firestore.
- Before running the app, ensure dependencies are installed:

```bash
flutter pub get
```

- Firebase: generate `firebase_options.dart` using FlutterFire CLI and place it in `lib/` (or provide manual configuration). Then call `FirebaseService.init()` early in `main()` (before UI) or in an initialization flow.

- API backend: set the real backend base URL in `lib/data/datasources/remote/api_service.dart` replacing `https://api.example.com`.

- Hive adapters: if you register Hive TypeAdapters for models, register them in `HiveService.init()` (see TODO in `lib/data/datasources/local/hive_service.dart`).

## Running tests

```bash
flutter test
```

## Notes for maintainers

- Add Firebase credentials (do NOT commit secrets). The project expects either a generated `firebase_options.dart` or environment-based configuration.
- The `lib/core/di/injection.dart` file centralizes providers — register new services/repositories there.

