# neFaRec

**A workout app for messy routines. Paste yours in, train it, and check your form.**

Most people's routine lives in a WhatsApp chat, a note or a screenshot from their coach. Workout apps want it typed in again exercise by exercise, and nobody tells you whether your reps are any good. neFaRec takes the routine as it is: paste or screenshot it, check what it read, train it with a set table that remembers last time's numbers, and check your form live with the camera.

**[Download the Android APK](https://github.com/mofixiu/neFaRecmobile/releases/latest)** · [Watch the demo](https://github.com/mofixiu/neFaRecmobile/releases/latest) · [Tap through it in your browser](https://mofiyinebo.com)

### Try it in a minute

1. Install the APK (Android 7+; allow installs from your browser when asked).
2. Tap **Paste a routine**, then **Try the example**, or paste your own routine from WhatsApp.
3. Check the review screen, save, and start a workout. Log a few sets and finish to get the receipt.

No account, no internet needed. Everything stays on the phone.

<p>
  <img src="docs/screenshots/03-paste-filled.webp" width="180" alt="A routine pasted in as plain text" />
  <img src="docs/screenshots/04-review.webp" width="180" alt="Review screen showing what the parser read, with filled-in values highlighted" />
  <img src="docs/screenshots/12-sets-logged.webp" width="180" alt="Set table with last session's numbers beside each set" />
  <img src="docs/screenshots/14-rest-overtime.webp" width="180" alt="Rest timer counting into overtime" />
  <img src="docs/screenshots/19-history-progress.webp" width="180" alt="Progress charts for weekly volume and lifts" />
</p>

*Paste · Review · Train · Rest · Progress.* You can tap through every screen at [mofiyinebo.com](https://mofiyinebo.com).

## What it does

- **Import a routine as text.** Paste it, or pick a photo, screenshot or PDF and the app reads the text on the phone (Apple Vision on iPhone, ML Kit on Android). The parser finds days, exercises, sets, rep ranges, timed holds and rest, and the review screen highlights every value it had to fill in so you can fix it before you save.
- **Train it.** Each set shows what you did last time. Rest is a scoreboard that counts into overtime, holds like planks get their own timer, and the rest timer carries on in the Dynamic Island and on the lock screen as a Live Activity.
- **See your history.** Each session ends as a receipt. History has weekly volume, a muscle split, trend charts for each lift and a training calendar.
- **Look up any move.** 884 exercises with steps and photos, 42 looping demo videos, and swaps for the equipment you have.
- **Check your form, live or from a video.** Point the camera at yourself and neFaRec counts and measures each rep as you do it, or film a set and check it after. It tracks your joints in every frame (Apple Vision on iPhone, ML Kit pose detection on Android). It counts reps and checks what matters for the lift: depth for squats, lunges and push-ups, body line for push-ups, hinge and lockout for deadlifts, lockout and lean for overhead presses, and range and swing for curls. It says when the clip isn't clear enough to judge.
- **Works offline.** Everything is stored on the phone. An optional account backs your data up to the [neFaRec API](https://github.com/mofixiu/neFaRecbackend).

The parser is also published on its own as [workout_parser](https://pub.dev/packages/workout_parser), and you can [try it in your browser](https://workoutparse.mofiyinebo.com).

## Built with

| Area | Choice |
| --- | --- |
| App | Flutter and Dart, on iPhone and Android (the Live Activity is iPhone-only) |
| State | Riverpod |
| Storage | Drift (SQLite), with secure storage for the account token |
| Native iOS | SwiftUI and ActivityKit for the Live Activity; Vision and PDFKit for text recognition and body pose |
| Native Android | ML Kit text recognition and pose detection (bundled models), PdfRenderer and MediaCodec, in Kotlin behind the same channel |
| Look | [paper_kit](https://pub.dev/packages/paper_kit), my handmade-paper UI kit |
| Backend | [neFaRec API](https://github.com/mofixiu/neFaRecbackend): Node, TypeScript and PostgreSQL, only for accounts and backups |

Code is grouped by feature under `lib/features` (import, today, routines, workout, history, library, formcheck, account, settings), with shared services, models and the database in `lib/core`.

## Run it

```bash
flutter pub get
flutter run
```

The app works fully offline. The account and backup screens need the API: run it from the [backend repo](https://github.com/mofixiu/neFaRecbackend), which the simulator reaches at `127.0.0.1:4100`. For a real phone on your Wi-Fi:

```bash
flutter run --dart-define=NEFAREC_API=http://<your-computer-ip>:4100
```

## Tests

```bash
flutter analyze
flutter test
```

The tests cover the parser, the rest and hold timer, progression, analytics, the repositories and backups, and the form-check maths.

## Regenerating things

- **Database code**, after editing `lib/core/db/database.dart`: `dart run build_runner build --delete-conflicting-outputs`
- **App icon:** `flutter test tool/icon/render_icon_test.dart`, then `dart run flutter_launcher_icons`
- **Demo videos:** `python3 tool/videos/fetch_wger.py` (needs ffmpeg)
- **Sample history for screen recordings:** build with `--dart-define=NEFAREC_DEMO_SEED=true` on a fresh install to get a few weeks of made-up sessions. Never use it for a release build.

## Credits

The exercise library is built from [free-exercise-db](https://github.com/yuhonas/free-exercise-db) (public domain). The 42 demo clips come from [wger](https://wger.de) (CC BY-SA 4.0), trimmed to 10 seconds, and are credited in Settings → Video credits and on each video.
