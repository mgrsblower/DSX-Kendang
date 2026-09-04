# iOS Native Low-Latency Audio Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove iOS pad-hit delay by adding a native AVAudioEngine path that pre-decodes samples and plays them through a reusable polyphonic node pool.

**Architecture:** Keep the existing `AudioEngine` Dart interface. Extend `NativeAudioEngine` so Android and iOS use the method channel, while other platforms retain `FlutterAudioEngine` as fallback. Register an iOS method channel in `AppDelegate`, backed by a focused Swift engine that configures `AVAudioSession`, loads `AVAudioPCMBuffer` instances during preload, and schedules them immediately on a 16-node `AVAudioEngine` pool.

**Tech Stack:** Flutter/Dart, Swift, AVFoundation, Flutter MethodChannel, Flutter widget/unit tests.

## Global Constraints

- Preserve the existing `onPointerDown` pad trigger in `DrumPadButton`.
- Keep Android SoundPool behavior unchanged.
- Keep fallback playback for native load/play failures.
- Do not build or claim iOS runtime success on Windows; require a Mac/iPhone QA pass for final latency confirmation.

---

### Task 1: Lock native iOS routing with a failing Dart test

**Files:**
- Modify: `test/native_audio_engine_test.dart`
- Modify: `lib/audio/native_audio_engine.dart`

- [x] Add an iOS override test expecting `preload` and `play` to call the method channel without invoking the Flutter fallback.
- [x] Run `flutter test test/native_audio_engine_test.dart`; confirm the new test fails because only Android is currently native.
- [x] Add `isIosOverride`, derive `_isNativePlatform` from Android or iOS, and route native preload/play/release for both platforms.
- [x] Run the focused test again and then the full Dart test suite.

### Task 2: Implement the iOS AVAudioEngine bridge

**Files:**
- Create: `ios/Runner/LowLatencyAudioEngine.swift`
- Modify: `ios/Runner/AppDelegate.swift`

- [x] Add a Swift engine with one `AVAudioEngine`, one `AVAudioPlayerNode` per voice (16), a path-to-`AVAudioPCMBuffer` cache, a serial preload queue, and round-robin voice selection.
- [x] Configure `AVAudioSession` as playback with mixing, activate it once, and request a short preferred I/O buffer duration before starting the engine.
- [x] Resolve both Flutter bundle assets (`flutter_assets/<assets/...>`) and absolute custom sample paths.
- [x] Decode each requested file with `AVAudioFile` into an `AVAudioPCMBuffer` during `preload` and report completion only after all paths are loaded or one fails.
- [x] Attach/connect nodes to the main mixer; on play, set volume, interrupt the selected node, schedule the cached buffer, and start it without file I/O.
- [x] Release nodes, buffers, and the audio session cleanly.
- [x] Register `com.mgr.dsx_drum_kendang/audio` in `AppDelegate` and map `preload`, `play`, and `release` to the engine.

### Task 3: Verify Dart contracts and native source shape

**Files:**
- Modify: `test/native_audio_engine_test.dart`
- Create: `test/ios_audio_contract_test.dart`

- [x] Add a contract test covering the iOS method names, `paths` argument, `path` argument, clamped volume, and fallback on native false/error.
- [x] Run focused tests, `flutter analyze`, and `git diff --check`.
- [x] Inspect the Swift source for AVAudioEngine, AVAudioPCMBuffer, AVAudioSession, node pool, and no per-tap file read.

### Task 4: Build and device validation boundary

**Files:**
- No source changes.

- [x] Run the full Flutter tests and Android release build on Windows.
- [ ] Run `flutter build ipa --release` only where Xcode/macOS is available; blocked here because `xcodebuild` is unavailable on Windows.
- [ ] On an iPhone, compare first-hit and repeated-hit timing with the current build, verify overlapping hits, custom samples, background music mixing, interruption/resume, and preset switching.

### Task 5: Review and handoff

- [ ] Confirm only the planned files changed and no debug artifacts remain.
- [ ] Report Windows evidence separately from the required Mac/iPhone manual QA evidence.
