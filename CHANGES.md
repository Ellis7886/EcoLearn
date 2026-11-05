# EcoLearn – green software review fixes (branch `green-fixes`)

Based on commit `6c509b5` ("Improve some part for prototype").

## 1. Fair comparison (measurement validity)

| Change | Files |
|---|---|
| Normal Mode no longer ALSO copies lessons, chapters, materials and quizzes into SQLite (it downloaded the same data twice) | `lessons_page.dart`, `lessons_content_page.dart`, `quiz_page.dart` |
| Firestore streams/queries created once, not inside `build()` | lessons, chapters, chapter card, quiz, profile pages |
| Take Quiz no longer re-downloads the quiz on every answer tap | `take_quiz_page.dart` |
| Both modes timed the same way ("screen opened → data shown"); Normal logs whether data came from Firestore cache or server | `lessons_page.dart`, `lessons_content_page.dart` |
| `debugPrint` switched off in profile/release builds | `main.dart`, `performance_logger.dart` |
| Profile lesson count uses a server-side `count()` | `profile_page.dart` |

## 2. Eco Mode and learning continuity

| Change | Files |
|---|---|
| NEW offline cache: optimised file downloaded once, stored, then opened from the phone (also offline); icon shows "available offline" | `material_cache_service.dart`, `material_card_sqlite.dart` |
| Material sync keeps downloaded files and deletes outdated ones; all chapters synced with `whereIn` (≤30 ids per query) | `material_controller.dart` |
| Eco Mode syncs once automatically if SQLite is empty (lessons, chapters + materials, quizzes) | lessons, lessons content, quiz pages |
| Quizzes taken from SQLite in Eco Mode (offline) | `take_quiz_page.dart` |
| Quiz result saves the mode (`Eco`/`Normal`) and tries to upload right away | `take_quiz_page.dart` |
| Batched SQLite writes for lessons and chapters | `lesson_controller.dart`, `chapter_controller.dart` |
| Eco Mode dark theme now applies to every screen (before only MaterialApp switched); dark-theme switch locked while Eco Mode is on | `app_settings.dart`, `main.dart`, `home_page.dart`, `profile_page.dart` |
| Eco images decoded at screen width | `image_viewer_page.dart` |

## 3. Bugs

| Change | Files |
|---|---|
| PDFs from a URL could never open (`SfPdfViewer.file` was used for web URLs) | `pdf_viewer_page.dart` |
| Video errors handled instead of crashing; no extra HEAD request | `video_player_page.dart` |
| Normal material card had an unused Eco branch that passed `'Normal'` | `material_card.dart` |

## 4. Measurement tools

| Change | Files |
|---|---|
| In-app log now records execution time, network bytes (TrafficStats, per app) and memory (RSS) per operation, in `performance_log_v2.csv` (copyable with `adb pull`) | `performance_logger.dart`, `MainActivity.kt` |
| NEW repeated-run script: warm-up + N runs, CPU every second, memory PSS every 5 s, fixed brightness, copies the in-app log | `ecolearn_measure.ps1` |

## Not changed (do yourself)

- `android/app/google-services.json` and `lib/firebase_options.dart` are public on GitHub:
  restrict the Android API key (package name + SHA-1) in Google Cloud console, and check
  Firestore/Storage security rules are not open.
- Add the Cloud Function that creates the optimised files (or document its settings:
  image resolution/quality, video resolution/bitrate, PDF compression).
- Unused files can be deleted later: `connectivity_service.dart`, `download_service.dart`,
  `file_service.dart`, `firestore_service.dart` (check nothing imports them first).
