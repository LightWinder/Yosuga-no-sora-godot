# Repository Agent Guide

This file applies to the entire repository. Follow it together with the more detailed architecture notes in `docs/architecture.md`.

## Project baseline

- Target Godot 4.7.1 or a compatible 4.7 maintenance release. The current local verifier is known to pass with Godot 4.7.2.
- Use typed GDScript and native Godot `Control`/`Resource` types. Do not introduce C#.
- Keep Windows, macOS, Android, and iOS behavior in mind. The design canvas is 1920×1080 and mobile layouts must respect safe areas.
- Treat `yosuga-no-sora-remake` as source/reference material only. Runtime work belongs in this Godot repository.

## Before changing files

- Read `README.md`, `README.zh-CN.md`, and `docs/architecture.md` when changing behavior or structure.
- Inspect `git status` first. The worktree may contain user changes; preserve unrelated edits and deleted assets.
- Do not edit or commit `.godot/`, editor layout/cache files, local logs, export signing data, or credentials.
- Do not commit, push, rewrite history, or modify remotes unless the user explicitly asks.

## Dependency direction

- `src/app/` is the composition root. It creates services, connects cross-feature signals, and owns routing.
- `src/core/` contains infrastructure and must not import `title`, `settings`, or `save_load` resources.
- Put cross-feature contracts in neutral directories such as `src/scenario/`; do not make one feature own another feature's data contract.
- Keep feature-specific code in its feature directory. Promote UI to `src/ui/` only when it has multiple real callers and no feature semantics.
- `src/save_load/` must remain independent of `src/title/`. Title may configure Save/Load as a route adapter, but Save/Load must not import Title scenes or scripts.
- Reuse `src/ui/confirmation_overlay.tscn` for ordinary confirmations. It owns modal focus trapping and restores the previous focus when closed.

## Scenes, scripts, and editor behavior

- Serialize fixed nodes, hierarchy, layout, reusable overlays, and Theme variations in `.tscn` files. Scripts should coordinate dependencies, signals, state, pagination, and data binding.
- Build nodes dynamically only when their count depends on a manifest or user data. Give every dynamic node a stable business name immediately.
- Before freeing and recreating same-named runtime children, remove the old children from their parent, then call `queue_free()` to avoid `@Node@...` names.
- Reuse `DesignCanvasPage` and `DesignViewportLayout` for 1920×1080 artwork pages. Do not duplicate scaling or safe-area calculations.
- Keep editor-preview code behind `@tool`. If an `@tool` parent calls a child scene's script API during editor `_ready()`, the child script must also be `@tool`, or the call must be guarded from editor execution.
- Prefer scene instances over `SomeControl.new()` for reusable, fixed UI.

## UI, Theme, input, and focus

- Put typography, colors, outlines, icons, and StyleBoxes in the project Theme and external `.tres` resources. Use semantic Theme variations instead of script-side style caches.
- Shared styles belong under `assets/themes/ui/`; feature-specific styles belong under their feature directory.
- Do not restore the removed baked Save/Load chrome under `assets/content/save_load_hd/`. Save/Load fixed UI is scene-owned and Theme-driven.
- Keyboard and controller navigation are required: initial focus must target the first visible, enabled control; modal dialogs must trap focus and restore it when closed.
- Use the semantic `vn_advance`, `vn_cancel`, and `vn_confirm` actions. Do not hard-code parallel input rules in individual screens.
- Godot defaults `input_devices/pointing/emulate_mouse_from_touch` to `true` and may omit the setting when saving `project.godot`. Absence is valid; never set it explicitly to `false`.
- Continue filtering `InputEvent.DEVICE_ID_EMULATION` synthetic mouse events so one touch does not trigger an action twice.

## Persistence and routes

- Saves belong under `user://`, never `res://`.
- `SaveService` owns `SaveData` and `ProfileData`; `SettingsRepository` owns settings; `VoiceCollectionService` owns voice favorites. All three reuse `AtomicJsonStore` rather than duplicating temporary/backup write logic.
- Services may be redirected to isolated storage by tests. UI and route code must use public accessors such as `autosave_path()` and `slot_path()` instead of production constants.
- Continue, Load, recollections, and future ADV integrations communicate through `ScenarioLaunchRequest`.
- Preserve schema migration and `.bak` recovery behavior when changing persisted data.

## Assets and media

- PNG, audio, video, and font files are covered by Git LFS. Verify LFS is installed before adding or replacing large assets.
- Runtime video manifest entries must use Godot-decodable OGV files, not MP4.
- Preserve source filenames, manifest counts, loop metadata, and font license/attribution unless the task explicitly changes those contracts.
- Do not rewrite asset history or mass-convert media as part of an unrelated change.

## Verification

Run before handing off implementation work:

```bash
./tools/verify_project.sh
git diff --check
```

If Godot is not on `PATH`, use the installed app directly:

```bash
GODOT_EXECUTABLE=/Applications/Godot.app/Contents/MacOS/Godot ./tools/verify_project.sh
```

The verifier performs static architecture/resource checks, imports the project, then runs `tests/startup_flow_smoke_test.gd` and `tests/title_migration_contract_test.gd`. Some contract tests intentionally feed corrupt JSON, and source OGG files can emit metadata warnings; use the command exit status and the verifier's fatal parse/script/leak checks to determine success.

For Save/Load visual captures, the overlay is the fourth user argument—do not insert a Settings tab placeholder:

```bash
godot --path . --script res://tests/visual_capture.gd -- load /tmp/yosuga-load-delete.png 1.0 delete_confirm
godot --path . --script res://tests/visual_capture.gd -- save /tmp/yosuga-save-overwrite.png 1.0 overwrite_confirm
```

## Documentation and handoff

- Keep `README.md` as the default English README and maintain behavior/structure parity in `README.zh-CN.md`.
- Update `docs/architecture.md` and `tools/verify_project.sh` when introducing a durable module boundary or structural invariant.
- Report which checks ran, whether Godot runtime tests were available, and any remaining warnings or uncommitted work.
