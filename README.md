# Yosuga no Sora Remake · Godot Title Migration

**English** | [简体中文](README.zh-CN.md)

This project ports the startup sequence and HD Title/gallery screens from `yosuga-no-sora-remake` to Godot 4.7.1. The runtime uses typed GDScript and native Godot Control/Resource types only—no C#—so the same codebase can target Windows, macOS, Android, and iOS.

## Current scope

The startup flow follows the original project:

1. Play the five-second Sphere brand movie and trigger a random brand voice line at 1.5 seconds.
2. Fade in the content warning for one second, hold for eight seconds, then leave through a one-second white transition.
3. Reveal the Title screen from white over one second while fading the menu in over 0.5 seconds, then play a random title voice and looping BGM. Continue appears when an autosave exists. Load lists the autosave and 20 manual slots with selection and delete confirmation. Settings persist the complete Audio/Display/System model; volume changes preview live and commit when dragging ends or after a short debounce.

The Title Bonus section reproduces the source HD information architecture instead of using a placeholder text list:

- Album: the first six source `CgModeList` groups, with 79 cards and 214 variants; six character tabs, a paginated 4×2 grid, unlock states, real `event_1920` PNGs, a fullscreen viewer, and previous/next variant navigation.
- Music: 21 tracks from the source manifest in a three-column grid, with real OGG playback, stop and track switching. BGM03–BGM21 use their `.sli` loop points.
- Memories: 24 entries—18 scenario recollections, the opening movie, and five Staff Rolls. Project-local OGV files support playback and stopping. Scenario recollections emit a real `ScenarioLaunchRequest` and clearly report that the ADV runtime is still pending instead of pretending gameplay has started.
- Voice: four columns with 12 favorite cards per page. The collection starts empty and can later be populated by the ADV layer through `VoiceCollectionService.add_favorite()`. Favorites have independent persistence, deduplication, playback, deletion, and a typed save-jump seam.

Continue and Load emit the same `ScenarioLaunchRequest` contract. The main ADV runner has not been migrated yet, so these requests currently open an explicit unavailable notice. New Game likewise exposes its integration signal without starting story content.

During the movie, keyboard, primary mouse, controller-confirm, or touch input advances to the warning. The first input on the warning completes its fade and shortens the remaining wait to four seconds; the second starts the white transition immediately. The Title menu uses semantic `vn_advance`, `vn_cancel`, and `vn_confirm` actions. Native touch-to-mouse emulation keeps Godot Controls on one GUI path, while `StartupInput` filters synthetic `DEVICE_ID_EMULATION` mouse events to prevent a touch from advancing twice. Mouse wheel and secondary-button events do not advance accidentally. Menu buttons retain two-frame highlighting, press/release feedback, controller focus, and enlarged touch hit areas.

Settings now reproduce the source `ConfigWindowHD2` information architecture:

- A fullscreen 1920×1080 settings overlay keeps and live-blurs the Title route underneath it. The three top-right tabs—Display, System, and Audio—are native scene-owned Buttons using one ButtonGroup and semantic Theme variations.
- Display is the high-DPI reference implementation: fullscreen/windowed modes, 1080p/900p/720p, window-opacity slider, six font choices, Simplified Chinese/Japanese choices (Japanese remains disabled as in the source), and a preview text box with portrait. The scene, `textbox.png`, and `avatar.png` retain source artwork; panels, headings, highlighted text choices, toggles, and sliders use Godot Theme and CanvasItem drawing instead of baking a complete page into `graphic/bg.png`. Read-text color and portrait visibility update live.
- System contains five YES/NO choices, message-speed and auto-play-delay sliders, and 11 confirmation preferences. Its checkbox visuals are drawn with Canvas primitives rather than sliced image-state assets.
- Audio contains nine character voice selectors—sora, nao, akira, kazuha, motoka, ryohei, yahiro, kozue, and npc—with portrait switching. Per-character volume uses the source trapezoid slider, with its knob scaling from 115% to 155% across the value range. Six global channel sliders start at 100%. Ending a character-volume drag plays the source `個別音声` sample at Master × Voice × character-detail volume through the equivalent Godot buses.
- The footer provides Reset Settings, Reset Read Text, Shortcuts, and Return to Title as Godot text buttons. Shortcut and confirmation dialogs share `SettingsModal` for localized background blur, mask fades, and centered scale transitions. Only the covered dialog region is blurred; content remains native panels, labels, and table controls. Right-click or Escape plays the closing transition before dismissing a dialog.
- Reset follows the source `CallConfirm` behavior. The confirmation window uses the source `ui_1920/confirm` bg/yes/no/ask_always artwork. Y/Enter confirms; N/Escape/right-click cancels. “Always ask” writes directly to the associated `confirmations` setting, and disabling it skips future confirmation for that reset. Reset Settings preserves window mode and width, matching source `fullScreen`/`windowZoom` behavior. Reset Read Text emits a typed seam pending the ADV storage migration.
- Settings schema 3 migrates the prototype's nine voice-detail slots into the source VCID_TO_INDEX layout with 11 slots—SR/AK/NO/KA/MT/RH/YH/KO/YM/SH/NP—and reorders legacy values automatically. `window_opacity` migrates to the source-compatible `window_depth` range of 0–100, while `message_speed` migrates to the source 0–100 scale. Sliders preview live and persist at drag end or after a 250 ms debounce without rereading disk on every preview.

## Running

Open the directory with Godot 4.7.1 or a compatible 4.7 maintenance release, or run:

```bash
godot --path .
```

The design resolution is 1920×1080. The current development window starts at 2560×1440 and scales at a fixed 16:9 aspect ratio. The Title background independently covers the viewport, while the content root preserves its aspect ratio in ultrawide, 4:3, and portrait windows. Desktop 16:9 is not reduced unnecessarily; mobile layouts additionally respect the system safe area, with a conservative fallback when unavailable.

## Verification

```bash
GODOT_EXECUTABLE=/path/to/godot ./tools/verify_project.sh
```

The verification script first checks InputMap, save contracts, all four export presets, architecture boundaries, and required resources. When a Godot executable is available, it also imports resources, parses GDScript, and runs the headless smoke and migration contract tests.

To generate visual-regression baselines, run `tests/visual_capture.gd` in GUI mode:

```bash
godot --path . --script res://tests/visual_capture.gd -- title /tmp/title.png 1.25
# Optional fourth settings argument: 0=Display, 1=System, 2=Audio
godot --path . --script res://tests/visual_capture.gd -- settings /tmp/yosuga-settings-final.png 1.0 0
godot --path . --script res://tests/visual_capture.gd -- settings /tmp/yosuga-settings-keys.png 1.0 0 key_popup
godot --path . --script res://tests/visual_capture.gd -- settings /tmp/yosuga-settings-confirm.png 1.0 0 reset_confirm
# Closing-transition frames: key_popup_closing / reset_confirm_closing
```

## Project structure

See [`docs/architecture.md`](docs/architecture.md) for the complete dependency direction, Scene/script responsibilities, and feature-placement rules (currently in Chinese).

- `src/app/`: startup state transitions and route-level composition. Settings remain an overlay over the active route and blur the live scene behind them through `BackBufferCopy + SCREEN_TEXTURE`. Title departure/return transitions and Settings UI share the main Viewport.
- `src/intro/`: brand movie and content-warning screens, each owning its input and timing.
- `src/title/`: the Title route and reusable menu components. `title_screen.tscn` owns the fixed background, character variants, primary/bonus menu buttons, and footer chrome. Its script only synchronizes visibility, focus, signals, save state, and transitions. The Load route uses a lightweight feature host, and Title reaches Settings only through the `settings` route.
- `src/title/content/`: manifest-backed Album, Music, Memories, and Voice pages, each with its own `.tscn` boundary. Paginated data cards are generated at runtime; fixed structures such as the fullscreen Album viewer and notice overlays are reusable scenes.
- `src/title/title_catalog.gd` and `title_catalog_entry.gd`: gallery entry definitions, profile unlock state, and content-runner data contracts.
- `src/settings/`: independent settings route, editor, schema-3 model, and display adapter. `SettingsPage` coordinates snapshots, preview/commit, and reset rules; static `SettingsChrome` owns tabs, footer, status, and dialogs. `pages/` contains separate Display/System/Audio scenes. Audio owns its voice preview player, while Display's two-column containers, nine cards, and title are serialized in `.tscn`. Tabs use native Buttons, a shared ButtonGroup, and the `SettingsTabButton` Theme variation. `ui/` contains interactive/custom-drawn controls, while typography, colors, outlines, and StyleBoxes come from semantic project Theme variations.
- `src/title/voice/`: user voice-favorite Resource/service, intentionally independent from autosave.
- `src/scenario/`: the shared typed request used by Continue, recollections, future voice jumps, and the future ADV runner. Title-only unavailable notices remain under `src/title/components/`.
- `src/core/audio/`: startup random voices, BGM playback, loop points, and the runtime settings adapter. `default_bus_layout.tres` declares Master/BGM/SystemVoice/Voice/EnvSE/SE/Movie buses.
- `src/core/input/`: semantic actions and shared startup advance/skip input handling.
- `src/core/save/`: `SaveData`, cross-save `ProfileData`, and `SaveService`. Settings persistence belongs to `src/settings/persistence/SettingsRepository`; both use `src/core/persistence/AtomicJsonStore` for atomic writes and reversible backups.
- `src/ui/`: shared UI bases and layout policies with no feature semantics, including 1920×1080 artwork-canvas scaling and mobile-safe-area conversion.
- `assets/manifests/title_content_manifest.json`: an auditable contract derived from the source manifest. Contract tests lock group, card, variant, music, memory, and media-path counts.
- `assets/content/event_1920/`: source event artwork, including the 214 variants required by the manifest and other peer assets from the source directory.
- `assets/content/settings/`: source `ui_1920/settings` HD assets, including Display option artwork, Voice portraits, `slider_knob.png`, and `key_popup.png`. Fixed System/Audio chrome is expressed through scenes, Theme resources, and Canvas primitives.
- `assets/content/confirm/`: source `ui_1920/confirm` confirmation artwork—bg, yes, no, and ask_always.
- `assets/audio/voice_samples/`: 11 source `個別音声：ボリューム` samples from `data/audio_ogg`, used for character-volume previews.
- `assets/audio/bgm/`: Title/gallery OGG music. The manifest exposes 21 tracks, with `BGM07_title.ogg` retained separately for startup.
- `assets/video/`: OGV files supported by the Godot core. `yosugacn` and five Staff Rolls were converted from source MP4 to 1280×720/30 fps Theora; the playback manifest does not reference MP4.
- `assets/content/thumb/`: 24 memory thumbnails. Remaining assets contain startup, Title UI, and font resources.
- `assets/fonts/` and `assets/themes/`: the project-wide CJK Theme, semantic Settings variations, and separate `FontVariation` weights for choices and headings. Settings StyleBoxes and gradients are split by responsibility under `assets/themes/settings/` so they remain editable in the Inspector; the main Theme only maps them. The base font is a standalone Godot `FontFile` derivative generated from the source `Xiaolai-Regular.ttf`, with SIL OFL 1.1 attribution/license in `Xiaolai-Regular-OFL-1.1.txt`, so cold starts do not depend on `.godot` import cache.
- `tests/`: framework-free headless smoke, input, save, Title, export, and migration contract tests.

Large PNG, audio, video, and font files are configured for Git LFS on future additions or modifications. Existing Git history is not rewritten automatically. Install and enable Git LFS before cloning or committing assets.

Route boundaries, fixed Title layers/menus, reusable dialogs, and complex fixed Display-page columns live in `.tscn` files. Repeated content cards remain data-driven but receive stable business names immediately after creation. Scripts own dependency injection, signals, and state synchronization; services are created lazily only by routes that need them. Runtime list refreshes detach old children before `queue_free()` to prevent automatic `@Node@...` names when a same-named item is created in the same frame. The Remote scene tree should therefore contain meaningful node names only.

## Multi-platform export

`export_presets.cfg` includes Windows Desktop, macOS, Android, and iOS presets. Apple and Android use the shared bundle ID `com.lightwinder.yosuganosora.hdremake`. Android/iOS presets carry the `mobile` feature, which hides Exit Game; desktop keeps exit confirmation. Presets contain no signing certificates, passwords, or provisioning profiles. Inject signing material through local or CI Godot export configuration for production. iOS export requires macOS and Xcode; Android requires the matching Godot SDK/JDK toolchain.

Saves always write to `user://`, never read-only `res://`. `SaveData` keeps schema/content version, scenario anchor, local flags, read-text IDs, and presentation snapshots. `ProfileData` independently stores cross-save global flags and gallery unlocks. Every overwrite first preserves a `.bak` file, recoverable through `SaveService.restore_*_backup()`.

`BGM07_title.ogg` is trimmed according to the original `BGM07.ogg.sli` jump point and loops from 161922 / 44100 seconds. `sphere.ogv` is the Ogg Theora conversion of source `sphere.mp4` for playback through Godot's core video decoder. Game assets retain the rights status of their source project; this repository does not relicense them.
