# EcoLearn

EcoLearn is a Flutter + Firebase mobile learning app built for a Master's research
project on Green Software Engineering. It has two modes, so their resource use
(CPU, memory, network traffic, execution time) can be compared.

| | Normal Mode | Eco Mode |
|---|---|---|
| Lessons, chapters, quizzes | Live Firestore listeners | Stored in SQLite; synced once, then on pull-to-refresh |
| Learning materials | Original file, streamed every time | Optimised file, downloaded once, then opened from the phone (offline) |
| Taking a quiz | Loaded from Firestore | Loaded from SQLite (works offline) |
| Quiz result upload | On any connection | Automatically on Wi-Fi only (pull-to-refresh uploads on any connection) |
| Video | Autoplay | No autoplay |
| Images | Full-resolution decode | Decoded at screen width |
| Theme | User choice | Always dark (less power on OLED screens) |
| Page transitions | Animated | None |

Tech stack: Flutter, Firebase (Auth, Firestore, Storage), SQLite (`sqflite`), Provider.

## Run

```bash
flutter pub get
flutter run --profile     # use profile/release builds for all measurements
```

## Measuring Eco vs Normal Mode

1. **In-app log** – every measured operation (load lessons/chapters/quizzes, open quiz,
   open PDF/image/video, download material, video session) writes one row to
   `performance_log_v2.csv` with execution time, network bytes received/sent by the
   app (Android TrafficStats) and app memory (RSS).
   Copy it to the PC with:
   ```bash
   adb pull /sdcard/Android/data/com.ecolearn.ecolearn_app/files/performance_log_v2.csv
   ```
2. **Automated repeated test** – `ecolearn_measure.ps1` runs the video scenario N times
   and records CPU % (every second) and memory PSS (every 5 seconds), then copies the
   in-app log:
   ```powershell
   .\ecolearn_measure.ps1 -Mode Normal -Runs 10 -Duration 60 -Device Phone
   .\ecolearn_measure.ps1 -Mode Eco    -Runs 10 -Duration 60 -Device Phone
   ```
   Results are saved in `automated_results/`.

The older scripts `ecolearn_automated_test.ps1` and `ecolearn_automated_vitual_test.ps1`
are kept for reference.

## Project structure

```
lib/
  controllers/   Firestore -> SQLite synchronisation (batched writes)
  services/      SQLite access, Eco offline file cache, quiz result sync, performance log
  screens/       App pages (lessons, quiz, viewers, profile, login)
  widgets/       Cards (ChapterCard/MaterialCard = Normal, *Sqlite = Eco)
  provider/      App settings (Eco Mode, theme)
```

The optimised files used by Eco Mode (`eco_file_path` in Firestore) are created by a
Firebase Cloud Function that is not in this repository.
