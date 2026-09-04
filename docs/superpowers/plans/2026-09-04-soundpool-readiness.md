# SoundPool Readiness and Custom Sample Latency Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Android pad playback more responsive by ensuring native SoundPool samples are loaded before play, including custom samples in preload, and avoiding unnecessary Flutter audio preload work on Android.

**Architecture:** Keep `AudioEngine` unchanged. The Flutter page passes the complete current pad sample list inside the existing `Preset` value. `NativeAudioEngine` sends that list to the Android `MethodChannel`; Kotlin holds the preload result until every requested SoundPool sample reports loaded or failed. Android remains native-first, while Flutter audio remains the fallback path.

**Tech Stack:** Flutter/Dart, Kotlin Android embedding, Android `SoundPool`, Flutter `MethodChannel`, Flutter unit tests.

## Global Constraints

- Preserve the existing 16-voice playback contract and 12-pad DSX mapping.
- Preserve non-Android fallback behavior for iOS and other platforms.
- Do not weaken or delete existing tests.
- Do not use `any`, ignore directives, or broad source refactors.
- Verify with focused tests, full Flutter tests, `flutter analyze`, and release APK build.

---

### Task 1: Lock complete-sample preload behavior in Flutter

**Files:**
- Modify: `lib/features/drum_pad/drum_pad_page.dart:100,157`
- Test: `test/native_audio_engine_test.dart`

**Interfaces:**
- `AudioEngine.preload(Preset preset)` remains unchanged.
- The `Preset.samples` passed to preload must represent the current pad sources, including custom file sources.

- [x] **Step 1: Write the failing test**

Add a test asserting that the native preload payload contains a custom `SampleRef` path when a preset is preloaded.

- [x] **Step 2: Run the focused test and confirm it fails for the missing custom path**

Run: `flutter test test/native_audio_engine_test.dart`

- [x] **Step 3: Implement the minimum Flutter-side change**

Pass a `Preset` built from the current `_samples` list at initial load and after preset selection, so custom samples are included without changing the interface.

- [x] **Step 4: Run the focused test and confirm it passes**

Run: `flutter test test/native_audio_engine_test.dart`

### Task 2: Make Android preload wait for SoundPool readiness

**Files:**
- Modify: `android/app/src/main/kotlin/com/example/dsx_drum_kendang/MainActivity.kt`
- Test: `test/native_audio_engine_test.dart`

**Interfaces:**
- Method `preload` receives `paths: List<String>` and returns `true` only after requested sounds are loaded; it returns `false` when a requested sound fails.
- Method `play` must not synchronously load an unknown sample on the first tap; it returns `false` for a sample that is not ready.

- [x] **Step 1: Write the failing readiness test**

Add a test that expects `NativeAudioEngine.preload` to be the only native operation before play and that native play does not fall back when the sample was preloaded successfully.

- [x] **Step 2: Run the focused test and confirm the test harness fails before the implementation is updated**

Run: `flutter test test/native_audio_engine_test.dart`

- [x] **Step 3: Implement readiness tracking in Kotlin**

Track loading IDs and pending preload results from `setOnLoadCompleteListener`. Complete the pending preload result only after every requested path has reported success; reject failed loads. In `play`, use only IDs already marked loaded and return `false` otherwise.

- [x] **Step 4: Avoid Android fallback preload overhead**

In `NativeAudioEngine.preload`, invoke the Flutter fallback preload only for non-Android. Native Android preload remains authoritative; fallback is used only if native playback fails.

- [x] **Step 5: Run focused and full tests**

Run: `flutter test test/native_audio_engine_test.dart`

Run: `flutter test`

### Task 3: Static and release verification

**Files:**
- No additional source files.
- Build artifact: `build/app/outputs/flutter-apk/release/app-release.apk`, renamed to `MGR-Kendang.apk`.

- [x] **Step 1: Run formatting and analysis**

Run: `dart format lib test`

Run: `flutter analyze`

- [x] **Step 2: Build the Android release APK**

Run: `flutter build apk --release`

- [x] **Step 3: Verify and rename the artifact**

Confirm the release APK exists and is non-empty, then move it within the project output area to `MGR-Kendang.apk`.

- [ ] **Step 4: Commit and push**

Run:

```text
git add .
git commit -m "perf(audio): wait for native sample readiness"
git push origin main
```

- [ ] **Step 5: Send the verified APK through WhatsApp Web**

Open Chrome, select the existing WhatsApp Web tab, search for group `bopat`, attach `MGR-Kendang.apk`, and send it with a concise Indonesian caption describing the native SoundPool readiness, custom-sample preload, latency improvements, and release build.
