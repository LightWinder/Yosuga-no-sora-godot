# Yosuga no Sora Remake · Godot Title Migration

**English** | [简体中文](README.zh-CN.md)

This project ports the startup sequence and HD Title/gallery screens from `yosuga-no-sora-remake` to Godot 4.7.1. The runtime uses typed GDScript and native Godot Control/Resource types only—no C#—so the same codebase can target Windows, macOS, Android, and iOS.

## Current scope

The startup flow follows the original project:

1. Play the five-second Sphere brand movie and trigger a random brand voice line at 1.5 seconds.
2. Fade in the content warning for one second, hold for eight seconds, then leave through a one-second white transition.
3. Reveal the Title screen from white over one second while fading the menu in over 0.5 seconds, then play a random title voice and looping BGM. Continue appears when an autosave exists. Load scrolls through 900 manual slots, nine quick-save records, and the separate autosave; occupied thumbnails offer a load action. Copy, move, locking, comments, and confirmed deletion are supported. Settings persist the complete Audio/Display/System model; volume changes preview live and commit when dragging ends or after a short debounce.

The Title Bonus section reproduces the source HD information architecture instead of using a placeholder text list:

- Album: the first six source `CgModeList` groups, with 79 cards and 214 variants; the source 4×2 layout uses 430×250 frames and one row of six character tabs. Locked slots keep the fixed grid but never load or reveal their CG, title, or variant data. Unlocked cards use real `event_1920` PNGs, a fullscreen viewer, and previous/next variant navigation.
- Music: 21 tracks from the source manifest in a three-column grid, with real OGG playback, stop and track switching. BGM03–BGM21 use their `.sli` loop points.
- Memories: 24 entries—18 scenario recollections, the opening movie, and five Staff Rolls—using the same source 4×2 card shell and lock behavior as Album. Project-local OGV files support playback and stopping; scenario recollections enter the shared ADV route at each script's recollect label.
- Voice: four columns with 12 favorite cards per page. The collection starts empty and can later be populated by the ADV layer through `VoiceCollectionService.add_favorite()`. Favorites have independent persistence, deduplication, playback, deletion, and a typed save-jump seam.

All four appreciation pages share the source bottom navigation and the neutral code-drawn `PageTitle` scene already used by Settings. The landscape artwork no longer bakes the heading into its pixels, so the title frame, typography, and localization stay component-owned. Album and Memories page arrows preserve the source irregular atlas cells through one CanvasItem draw path, and only the 320 px card grid participates in the 240 ms page slide.

Completing any route sets the shared Bonus flag and that route's Title-character flag before returning to Title. Starting its Staff Roll also unlocks the matching Memories video. These relationships live in the neutral `RouteProgress` contract used by both ADV and Title. Global unlocks merge monotonically into `ProfileData`, so loading an older save can recover missing progress without revoking content earned on another route.

New Game, Continue, Load, recollections, and voice save-jumps use the same ScenarioLaunchRequest contract. StartupFlow routes those requests to the scene-owned ADV screen, which restores save anchors and presentation snapshots.

Route hand-offs retain the source timing instead of deleting one screen and exposing the next in the same frame. New Game keeps Title alive for its three-second fade to the black window base while BGM07 fades for five seconds. ADV starts on that same black backing, crossfades to the first CG over 0.5 seconds, and reveals the first dialogue/menu over 0.3 seconds without a slide. The opening animation does not store partial opacity in the first autosave. Continue and Title-side Load use a separate source `BeginLoad`/`EndLoad` hand-off: the blue `FRM_0501` artwork enters over 0.3 seconds, the saved ADV presentation is restored while fully covered, and the ready scene is revealed over 0.5 seconds; Title BGM stops immediately on this load path. Returning from ADV ends choices, dismisses dialogue chrome over 0.3 seconds, fades ADV audio over one second, and reaches black after two seconds before Title is constructed and performs its white-cover reveal.

The ADV runtime imports all 306 source `.ks` files as normalized UTF-8 text and deliberately parses UTF-8 only. `tools/import_krkr_scenarios.sh` is the reproducible UTF-16LE-to-UTF-8 import boundary; runtime code never carries a second encoding path. The parser preserves tags, quoted arguments, flags, labels, text, and source line numbers. Its state machine handles dialogue/Hitret anchors, script changes, choices, local/global flags, conditionals, waits, recollection labels, and external movie pauses. The fixed background/character/menu/choice/history/movie/audio layers live in `adv_screen.tscn`, which normally instances `components/adv_dialogue_view.tscn` for dialogue; scripts create only data-dependent character and choice nodes.

`tools/import_krkr_adv_assets.sh` imports the complete media subset referenced by all 306 converted scripts: backgrounds, character drawings and dialogue portraits, voices, effects, transition rules, and fixed ADV chrome. It still avoids blindly copying unrelated source directories. The resolver is case-insensitive and reuses existing event CG, BGM, movie, Save/Load, Settings, Theme, input, and persistence components. Verification fails if any referenced media is absent.

During the movie, keyboard, primary mouse, controller-confirm, or touch input advances to the warning. The first input on the warning completes its fade and shortens the remaining wait to four seconds; the second starts the white transition immediately. The Title menu uses semantic `vn_advance`, `vn_cancel`, and `vn_confirm` actions. Godot's default touch-to-mouse emulation keeps Controls on one GUI path; the project verifier permits the editor to omit that default setting but rejects an explicit `false`. `StartupInput` filters synthetic `DEVICE_ID_EMULATION` mouse events to prevent a touch from advancing twice. Mouse wheel and secondary-button events do not advance accidentally. Title menu buttons are native Buttons drawn with Xiaolai text, slightly tilted per-character blue squares, and restored English subtitles. Theme resources define colors and typography; hover/focus highlighting, press/release feedback and enlarged touch hit areas remain. Main and Bonus menus no longer slice baked button images.

Settings now reproduce the source `ConfigWindowHD2` information architecture:

- A fullscreen 1920×1080 settings overlay keeps and live-blurs the Title route underneath it. The three top-right tabs—Display, System, and Audio—are native scene-owned Buttons using one ButtonGroup and semantic Theme variations.
- Display is the high-DPI reference implementation: fullscreen/windowed modes, 1080p/900p/720p, window-opacity slider, six font choices, Simplified Chinese/Japanese choices (Japanese remains disabled as in the source), and a lightweight `AdvSettingsPreview`. StartupFlow injects the same fixed train CG, speaker, portrait and sample message from both Title and gameplay; no current story state is captured. The preview contains only fixed artwork, the real `AdvDialogueView` scene and a replay Timer—no scenario runtime, stage director, audio, persistence, choices or gameplay menu. The original 1920×1080 SubViewport, 10 px padding and rounded clip remain unchanged; the viewport and dialogue reject mouse/key/focus input. Frame opacity, read color and portrait visibility update without replacing the sample. Panels, headings, choices and sliders remain Theme/CanvasItem-driven. Standalone editor scenes retain scenic fallback artwork until the app supplies the renderer.
- System contains five YES/NO choices, message-speed and auto-play-delay sliders, and 11 confirmation preferences. Its checkbox visuals are drawn with Canvas primitives rather than sliced image-state assets.
- Audio contains nine character voice selectors—sora, nao, akira, kazuha, motoka, ryohei, yahiro, kozue, and npc—with portrait switching. Per-character volume uses the source trapezoid slider, with its knob scaling from 115% to 155% across the value range. Six global channel sliders start at 100%. Ending a character-volume drag plays the source `個別音声` sample at Master × Voice × character-detail volume through the equivalent Godot buses.
- The footer provides Reset Settings, Reset Read Text, Shortcuts, and Return to Title as Godot text buttons. Shortcut and confirmation dialogs share `SettingsModal` for localized background blur, mask fades, and centered scale transitions. Only the covered dialog region is blurred; content remains native panels, labels, and table controls. Right-click or Escape plays the closing transition before dismissing a dialog.
- Reset follows the source `CallConfirm` behavior. The confirmation window uses the source `ui_1920/confirm` bg/yes/no/ask_always artwork. Y/Enter confirms; N/Escape/right-click cancels. “Always ask” writes directly to the associated `confirmations` setting, and disabling it skips future confirmation for that reset. Reset Settings preserves window mode and width, matching source `fullScreen`/`windowZoom` behavior. Reset Read Text emits a typed seam pending the ADV storage migration.
- Settings schema 3 migrates the prototype's nine voice-detail slots into the source VCID_TO_INDEX layout with 11 slots—SR/AK/NO/KA/MT/RH/YH/KO/YM/SH/NP—and reorders legacy values automatically. `window_opacity` migrates to the source-compatible `window_depth` range of 0–100, while `message_speed` migrates to the source 0–100 scale. Sliders preview live and persist at drag end or after a 250 ms debounce without rereading disk on every preview.

The ADV preview is visually hosted by Display, but its settings source is the complete `SettingsPage` state. StartupFlow connects the preview once on creation; SettingsScreen independently forwards the same signal to SettingsRepository. The fixed sample reveals using `message_speed`, waits `auto_speed` milliseconds after completion, then repeats. Live message-speed edits preserve reveal progress; auto-speed edits during a wait apply to the next wait. Display forwards host visibility across the SubViewport boundary: hidden tabs/prepared Settings stop the reveal and replay timer; showing Display restarts from zero. Reconfiguration and failed-write rollback publish restored settings without another commit. `AdvDialogueAppearance` shares gameplay/preview colors and font resolution. **Existing font limitation:** the six source font families are not imported; all font IDs still use the bundled Xiaolai fallback in both consumers, not preview-specific substitute fonts.

## Running

Open the directory with Godot 4.7.1 or a compatible 4.7 maintenance release, or run:

```bash
godot --path .
```

Desktop and mobile targets use Godot's Mobile renderer.

The design resolution is 1920×1080. Godot's built-in `application/run/max_fps` setting caps the project at 60 FPS. The animated Title background and cloud field render directly in the main Viewport at that rate. The current development window starts at 2560×1440 and scales at a fixed 16:9 aspect ratio. The Title background independently covers the viewport. A PSD-derived canopy weight mask applies a smooth ten-second, roughly nine-pixel sway to the tree tips while anchoring their roots and leaving the mountains and ground still. Its cloud overlay radially maps the complete transparent `title_cloud_radial_atlas.png` around a convergence position at design coordinate (1280, 950.4): left, centre, and right clouds retain their authored shapes while moving down-right, down, and down-left. They gradually fade over the final route segment and pass behind the mountain ridge. A separate slow, 1.4-pixel UV drift adds subtle internal shape movement without changing the routes. A single scene-owned CanvasItem renders the clouds; there are no individual cloud instances or respawns. Normalized scene-local phase clocks avoid hourly shader-time resets, and an artwork-space sky mask provides the mountain/tree occlusion. Projection follows the background's cover crop. The content root preserves its aspect ratio in ultrawide, 4:3, and portrait windows. Desktop 16:9 is not reduced unnecessarily; mobile layouts additionally respect the system safe area, with a conservative fallback when unavailable.

## Verification

Title now uses the whole-texture radial cloud implementation. `tests/cloud_test.tscn` retains ordinary vertical-loop inspection, while `tests/cloud_radial_test.tscn` previews the same cloud field used by Title. Both use `title_cloud_radial_atlas.png`. See [cloud validation and tuning](docs/cloud_loop_validation.md).

```bash
GODOT_EXECUTABLE=/path/to/godot ./tools/verify_project.sh
```

The verification script first checks InputMap, UTF-8 scenario assets, save contracts, all four export presets, architecture boundaries, and required resources. When a Godot executable is available, it also imports resources, parses GDScript, runs startup/Title contracts, and parses the complete 306-script KRKR corpus.

To generate visual-regression baselines, run `tests/visual_capture.gd` in GUI mode:

```bash
godot --path . --script res://tests/visual_capture.gd -- title /tmp/title.png 1.25
godot --path . --script res://tests/visual_capture.gd -- adv /tmp/yosuga-adv.png 1.2
# Optional fourth settings argument: 0=Display, 1=System, 2=Audio
godot --path . --script res://tests/visual_capture.gd -- settings /tmp/yosuga-settings-final.png 1.0 0
godot --path . --script res://tests/visual_capture.gd -- settings /tmp/yosuga-settings-keys.png 1.0 0 key_popup
godot --path . --script res://tests/visual_capture.gd -- settings /tmp/yosuga-settings-confirm.png 1.0 0 reset_confirm
# Closing-transition frames: key_popup_closing / reset_confirm_closing
godot --path . --script res://tests/visual_capture.gd -- load /tmp/yosuga-load.png 1.0
godot --path . --script res://tests/visual_capture.gd -- load /tmp/yosuga-load-delete.png 1.0 delete_confirm
godot --path . --script res://tests/visual_capture.gd -- save /tmp/yosuga-save.png 1.0
godot --path . --script res://tests/visual_capture.gd -- save /tmp/yosuga-save-overwrite.png 1.0 overwrite_confirm
```

## Project structure

See [`docs/architecture.md`](docs/architecture.md) for the complete dependency direction, Scene/script responsibilities, and feature-placement rules (currently in Chinese).

- `src/app/`: startup state transitions and route-level composition. Settings remain an overlay over the active route and blur the live scene behind them through `BackBufferCopy + SCREEN_TEXTURE`. Title departure/return transitions and Settings UI share the main Viewport.
- `src/intro/`: brand movie and content-warning screens, each owning its input and timing.
- `src/title/`: the Title route and reusable menu components. `title_screen.tscn` directly owns the animated tree background and projected cloud field in the main Viewport, followed by the character variants, primary/bonus menu buttons, and footer chrome. Both animated layers update with the 60 FPS main loop. The cloud field remains one scene-owned fullscreen Control; its CanvasItem shader maps a single repeating cloud texture by angle and logarithmic radius, with a static sky mask. The Title controller only synchronizes visibility, focus, signals, save state, and transitions. The Load route uses a lightweight feature host, and Title reaches Settings only through the `settings` route.
- `src/adv/`: the scene-owned ADV route, case-insensitive media resolver, history, choices, auto/skip, movie/audio playback, and in-game adapters for shared Save/Load and Settings. `components/adv_dialogue_view` owns the unchanged dialogue layout, appearance, reveal and frame animations; it receives resolved textures/values and has no gameplay or settings dependencies. Permanent frame-position/type/restoration APIs update stable resting state; slide offsets never become saved rest coordinates. `preview/adv_settings_preview` reuses this dialogue view for the isolated, looping Settings demo.
- `src/save_load/`: a Title-independent Save/Load page with scene-owned preview, actions, confirmation overlay, and native ScrollContainer. A bounded pool of reusable card scenes renders only the visible rows of the 900-slot list. Title configures Load; ADV supplies its live snapshot for Save/Load.
- `src/title/content/`: manifest-backed Album, Music, Memories, and Voice pages, each with its own `.tscn` boundary. Paginated data cards are generated at runtime; fixed structures such as the fullscreen Album viewer and notice overlays are reusable scenes.
- `src/title/title_catalog.gd` and `title_catalog_entry.gd`: gallery entry definitions, profile unlock state, and content-runner data contracts.
- `src/settings/`: independent settings route, editor, schema-3 model, and display adapter. `SettingsPage` coordinates snapshots, preview/commit, and reset rules; static `SettingsChrome` owns tabs, footer, status, and dialogs. `pages/` contains separate Display/System/Audio scenes. Audio owns its voice preview player, while Display's two-column containers, nine cards, and title are serialized in `.tscn`. Tabs use native Buttons, a shared ButtonGroup, and the `SettingsTabButton` Theme variation. `ui/` contains interactive/custom-drawn controls, while typography, colors, outlines, and StyleBoxes come from semantic project Theme variations.
- `src/title/voice/`: user voice-favorite Resource/service, intentionally independent from autosave.
- `src/scenario/`: the shared launch request plus the UTF-8 KRKR parser, intermediate document/instruction model, and route-independent scenario state machine.
- `src/core/audio/`: startup random voices, BGM playback, loop points, and the runtime settings adapter. `default_bus_layout.tres` declares Master/BGM/SystemVoice/Voice/EnvSE/SE/Movie buses.
- `src/core/input/`: semantic actions and shared startup advance/skip input handling.
- `src/core/save/`: `SaveData`, cross-save `ProfileData`, and `SaveService`. Settings persistence belongs to `src/settings/persistence/SettingsRepository`; both use `src/core/persistence/AtomicJsonStore` for atomic writes and reversible backups.
- `src/ui/`: shared UI with no feature semantics, including 1920×1080 artwork-canvas scaling, mobile-safe-area conversion, and the focus-restoring `ConfirmationOverlay` used by both Title and Save/Load.
- `assets/manifests/title_content_manifest.json`: an auditable contract derived from the source manifest. Contract tests lock group, card, variant, music, memory, and media-path counts.
- `assets/content/event_1920/`: source event artwork, including the 214 variants required by the manifest and other peer assets from the source directory.
- `assets/content/settings/`: source `ui_1920/settings` HD assets, including Display option artwork, Voice portraits, `slider_knob.png`, and `key_popup.png`. Fixed System/Audio chrome is expressed through scenes, Theme resources, and Canvas primitives.
- `assets/content/confirm/`: source `ui_1920/confirm` confirmation artwork—bg, yes, no, and ask_always.
- `assets/audio/voice_samples/`: 11 source `個別音声：ボリューム` samples from `data/audio_ogg`, used for character-volume previews.
- `assets/audio/bgm/`: Title/gallery OGG music. The manifest exposes 21 tracks, with `BGM07_title.ogg` retained separately for startup.
- `assets/scenario/`: all 306 source scripts converted to UTF-8/LF for runtime parsing and export.
- `assets/content/adv/` and `assets/audio/adv/`: the complete script-referenced ADV background, character/portrait, voice, effect, transition-rule, and dialogue-chrome subset.
- `assets/video/`: OGV files supported by the Godot core. `yosugacn` and five Staff Rolls were converted from source MP4 to 1280×720/30 fps Theora; the playback manifest does not reference MP4.
- `assets/content/thumb/`: 24 memory thumbnails. Remaining assets contain startup, Title UI, and font resources.
- `assets/fonts/` and `assets/themes/`: the project-wide CJK Theme, semantic feature variations, and separate `FontVariation` weights for choices and headings. Feature-specific Settings and Save/Load resources are split by responsibility under their own directories; neutral glass-panel and action-button styles live under `assets/themes/ui/` for shared components. The main Theme only maps these resources. The base font is a standalone Godot `FontFile` derivative generated from the source `Xiaolai-Regular.ttf`, with SIL OFL 1.1 attribution/license in `Xiaolai-Regular-OFL-1.1.txt`, so cold starts do not depend on `.godot` import cache.
- `tests/`: framework-free headless smoke, input, save, Title, export, and migration contract tests.

Large PNG, audio, video, and font files are configured for Git LFS on future additions or modifications. Existing Git history is not rewritten automatically. Install and enable Git LFS before cloning or committing assets.

Route boundaries, fixed Title layers/menus, reusable dialogs, and complex fixed Display-page columns live in `.tscn` files. Repeated content cards remain data-driven but receive stable business names immediately after creation. Scripts own dependency injection, signals, and state synchronization; services are created lazily only by routes that need them. Runtime list refreshes detach old children before `queue_free()` to prevent automatic `@Node@...` names when a same-named item is created in the same frame. The Remote scene tree should therefore contain meaningful node names only.

## Multi-platform export

`export_presets.cfg` includes Windows Desktop, macOS, Android, and iOS presets. Apple and Android use the shared bundle ID `com.lightwinder.yosuganosora.hdremake`. Android/iOS presets carry the `mobile` feature, which hides Exit Game; desktop keeps exit confirmation. Presets contain no signing certificates, passwords, or provisioning profiles. Inject signing material through local or CI Godot export configuration for production. iOS export requires macOS and Xcode; Android requires the matching Godot SDK/JDK toolchain.

Saves always write to `user://`, never read-only `res://`. `SaveData` keeps schema/content version, scenario anchor, local flags, read-text IDs, presentation snapshots, and the source-compatible previous-choice navigation stack. `ProfileData` independently stores cross-save global flags and gallery unlocks. Every overwrite first preserves a `.bak` file, recoverable through `SaveService.restore_*_backup()`.

`BGM07_title.ogg` is trimmed according to the original `BGM07.ogg.sli` jump point and loops from 161922 / 44100 seconds. `sphere.ogv` is the Ogg Theora conversion of source `sphere.mp4` for playback through Godot's core video decoder. Game assets retain the rights status of their source project; this repository does not relicense them.

Save/Load retains the current Settings-based visual language: fixed-height content, flexible header/footer spacing, shared 25 px panel padding, 18 px outer margins/gap, and a 12 px footer bottom margin. The viewport shows four columns and three rows; native continuous scrolling supports wheel, dragging, touch and keyboard navigation. Quick shortcuts reach manual, quick and automatic saves. The scrollbar sits inside the right panel with a 14 px gutter; thumbnails share the existing 10 px rounded mask.

The original contract is 10 books × 10 pages × 9 manual slots (900), followed by nine newest-first quick saves. The port also exposes its separate Continue autosave after quick history. Existing `slot_00.json` filenames remain compatible. Quick saves use nine rotating atomic files with persisted sequence numbers, independently of autosave. Copy preserves story state, time and image; move commits the destination before deleting the source. Locked manual slots resist overwrite/delete/move, and notes are editable. Transfers and destructive actions use the shared confirmation overlay.

SaveData schema 6 uses the source-compatible `comment` as the single displayed save text and `comment_edit` as its manual-replacement marker. New snapshots initialize it from the visible speaker and current dialogue; editing replaces that text directly (up to 128 characters). Schema 5 `autosave_meta.label` data migrates without losing an existing user annotation. Optional locking and base64 WebP thumbnails remain compatible with earlier saves. ADV renders only its background camera into a 960×540 offscreen SubViewport, excluding GUI and separate character layers, and supplies those previews (suitable for the approximately 920 px-wide preview at 4K). Compressed image data lives in the same atomic JSON document as progress, keeping copy and `.bak` recovery consistent. Old saves without screenshots retain their empty-preview fallback. Load initially selects manual slot 001; only a selected, occupied slot exposes and enables the image-centered play action. Slot images cover their rounded frame; the left preview uses a native 16:9 AspectRatioContainer with the same rounded clipping. Copy, move, and delete live together in the footer; occupied manual cards expose their lock action at the upper right. A save button appears only in Save mode.

Title Load now opens above the existing Title instance, like Settings. Returning fades the page out and moves its content down 18 px over 0.30 s, then restores the title menu and prior focus without replaying title audio. The return button is the final footer action and uses `SettingsFooterPrimaryButton`.

Save/Load opens with the same 0.30 s cubic ease-out fade and 18 px upward motion as Settings. Entering Settings or Load hides the title logo and menu immediately; the original departure animation API remains available for other routes. Returning still uses the existing menu restore animation.
