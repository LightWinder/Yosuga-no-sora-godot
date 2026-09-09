# Repository Agent Guide

Godot 4.7 project using typed GDScript. Target Windows, macOS, Android, and iOS. The design canvas is 1920×1080; mobile UI must respect safe areas.

## Working rules

* Inspect `git status --short` before editing and preserve unrelated user changes.
* Do not edit generated `.godot/` data, editor caches/layouts, credentials, signing data, or local logs.
* Do not commit, push, rewrite history, or modify remotes unless explicitly requested.
* Prefer the smallest coherent change that solves the requested problem. Do not perform unrelated refactors or asset conversions.
* Treat `yosuga-no-sora-remake` as reference/source material only; runtime implementation belongs in this repository.

## Architecture

Follow existing code and scene patterns before introducing new abstractions.

Read `docs/architecture.md` when changing module boundaries, cross-feature contracts, persistence ownership, routing, or other architectural behavior. Do not load it by default for localized changes.

Important project conventions:

* `src/app/` is the composition root; feature modules communicate through neutral contracts such as `src/scenario/`.
* Keep `src/save_load/` independent of `src/title/`.
* Fixed UI structure/layout belongs in `.tscn` and Theme resources; scripts coordinate state, signals, data binding, and genuinely dynamic content.
* Reuse existing shared UI and layout abstractions instead of creating parallel implementations.
* Persistent user data belongs under `user://` and must go through its owning repository/service.

When intentionally changing a durable architectural invariant, update `docs/architecture.md` and the verifier when appropriate.

## Assets

Binary media and fonts use Git LFS. Preserve existing asset names, manifests, metadata, licenses, and attribution unless the task explicitly changes them. Do not mass-convert media as part of unrelated work.

## Verification

Use targeted checks while iterating.

Run `./tools/verify_project.sh` before handing off changes that affect runtime code, scenes, resources, project configuration, persistence, routing, or architecture. It is not required for documentation-only or trivial non-functional edits.

Do not repeatedly run the full verifier during iteration unless necessary; rerun the relevant failing test instead.

Before final handoff of substantive implementation changes:

```bash
./tools/verify_project.sh
git diff --check
```

If Godot is not on `PATH`:

```bash
GODOT_EXECUTABLE=/Applications/Godot.app/Contents/MacOS/Godot ./tools/verify_project.sh
```
