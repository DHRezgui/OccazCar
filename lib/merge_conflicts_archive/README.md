Merge conflicts / backups from the other contributor (mobile folder)

What I copied here:
- `mobile_main.dart`: backup of `mobile/lib/main.dart`
- `mobile_firebase_options.dart`: backup of `mobile/lib/firebase_options.dart`

Next steps (recommended):
1. Review the backups in this folder and decide which implementations to keep.
2. For files present in both projects, move the desired implementation into the main tree and remove the backup.
3. Run `flutter pub get` and `flutter analyze` in `OccazCar` to catch any missing imports or API differences.

If you want, I can continue automatically copying all remaining `mobile/lib` files into this folder so nothing is lost.
