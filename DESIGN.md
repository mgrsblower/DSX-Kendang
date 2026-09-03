# MGR Drum Kendang Design System

## 0. Research Log

- Static reference: supplied screenshot of the original DSX Drum Kendang app; used as the visual contract for the landscape instrument surface.
- Existing source assets: edited MGR logo, splash, panel, pad, and preset artwork extracted from the authorized local APK analysis; reused as product artwork.
- Platform constraint: Flutter mobile app; responsive fallback remains usable in portrait, while landscape is the primary composition.

## 1. Direction

MGR is a tactile digital kendang instrument: a dark, dimensional hardware surface with restrained orange edge lighting and high-contrast white controls. The signature moment is the immediate pad press feedback, with real audio playback behind every live pad rather than a screenshot-like surface.

## 2. Tokens

### Color

- `surface0`: `#111111` — app background.
- `surface1`: `#252525` — instrument body.
- `surface2`: `#353535` — sidebar and controls.
- `surface3`: `#4A4A4A` — pad face.
- `ink`: `#F4F4F0` — labels and control text.
- `mutedInk`: `#A5A5A0` — secondary labels.
- `accent`: `#F08A00` — active edge and selected state.
- `success`: `#00D978` — save action.

### Typography

- Platform sans, bold for action labels and compact navigation.
- Body minimum 14sp; instrument labels use 12–18sp depending on available width.

### Spacing and shape

- Base spacing unit: 4dp; standard gaps are 8dp and 12dp.
- Instrument corners: 18dp outer radius; pad corners: 8dp.
- Depth strategy: tonal layers plus a small black shadow; orange is reserved for focus/active affordances.

## 3. Layout Contract

- Primary breakpoint: landscape. A fixed left control rail occupies about 18% of the width; the live 3-column x 4-row pad grid occupies the remaining area.
- Pad rows use the original rhythm: shorter top and bottom rows, taller middle rows.
- Portrait fallback stacks the control rail above the pad grid without clipping or horizontal scrolling.

## 4. Components

### InstrumentSidebar

- Structure: MGR logo, six preset buttons, Edit/Save/Load actions, Main Menu.
- States: selected preset, normal, disabled/placeholder, focus.
- Accessibility: every control has a semantic label.

### InstrumentPad

- Structure: live semantic button with pad artwork and a press highlight.
- Variants: compact (top/bottom rows), standard (middle rows); left-handed order.
- States: default, pressed, focus, audio error.

### MainMenuSidebar

- Structure: volume settings, left-handed mode, Add Music, Studio Record, built-in skin selection (Original, Karakter, Kayu, Metal, Grafiti), and return-to-pad action.

## 5. Interaction and Motion

- Pad press uses a 100–150ms opacity/scale feedback only while audio starts.
- Preset selection updates immediately and persists on change.
- Main Menu owns per-pad volume controls. Edit separates built-in sound replacement from custom import: Edit Sound enters direct pad selection and then opens a built-in sound dropdown with preview; Import Sound enters direct pad selection and then opens only the custom file picker. Save and Load use the original DSX ZIP-compatible format with per-pad `.dat` WAV entries.
- No ads are included.

## 6. Accessibility and Accepted Debt

- All interactive controls use Flutter semantic button/slider/switch primitives and visible focus/pressed states.
- Accepted debt: final pixel QA on iOS Simulator requires macOS; Windows validation covers Dart/widget behavior and asset loading only.
- There is no Pro action or advertising in this build. Loaded custom samples are copied into the app documents directory and remain available to the active session/preset.
