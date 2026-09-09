# Yosuga no Sora · Godot HD Remake

**English** | [简体中文](README.zh-CN.md)

An unofficial Godot remake project based on the HD assets and scenario data of *Yosuga no Sora*.

The project is rebuilding the original startup flow, Title/Bonus screens, ADV runtime, Save/Load system, and Settings UI in **Godot 4.7**, using typed GDScript and native Godot scenes, Controls, Resources, Themes, and shaders.

The original `yosuga-no-sora-remake` project is treated as reference/source material only. Runtime implementation lives entirely in this repository.

## Current status

The project currently includes:

* Startup movie, warning screen, and Title flow
* New Game, Continue, Load, and return-to-title routing
* ADV scenario runtime with dialogue, choices, flags, waits, movies, audio, history, Auto, and Skip
* Import pipeline covering all 306 source `.ks` scenarios
* Save/Load with 900 manual slots, 9 quick saves, and a separate autosave
* Save thumbnails, copy/move/delete, locking, comments, and confirmation flows
* Display, System, and Audio settings
* Lightweight live ADV preview inside Display settings
* Album, Music, Memories, and Voice Bonus galleries
* Persistent gallery progress and voice favorites
* Keyboard, mouse, touch, and controller input
* Windows, macOS, Android, and iOS export targets

The project is under active development and should not yet be treated as a complete replacement for the original game runtime.

## Technical highlights

* **Godot 4.7 / typed GDScript** — no C# runtime dependency
* **Native scene-driven UI** — fixed layouts live in `.tscn` scenes rather than being reconstructed in code
* **Theme-driven styling** — reusable typography, colors, panels, and control states use Godot Theme resources
* **KRKR import boundary** — source scripts are converted to normalized UTF-8 before runtime
* **Cross-feature routing** — Title, ADV, Save/Load, recollections, and related flows use neutral launch contracts
* **Atomic persistence** — saves, settings, profile progress, and voice favorites have explicit owners and recovery behavior
* **Responsive 1920×1080 design space** — desktop scaling and mobile safe areas share common layout infrastructure
* **Git LFS asset management** — large image, audio, video, and font assets are stored through Git LFS

## Requirements

* Godot 4.7.1 or a compatible 4.7 maintenance release
* Git
* Git LFS

The project currently uses Godot's Mobile renderer and targets Windows, macOS, Android, and iOS.

## Running

Install Git LFS once on your machine:

```bash
git lfs install
```

Clone the repository:

```bash
git clone https://github.com/LightWinder/Yosuga-no-sora-godot.git
cd Yosuga-no-sora-godot
```

If the repository was cloned before Git LFS was installed, fetch the assets with:

```bash
git lfs pull
```

Open the project in Godot 4.7.x, or run:

```bash
godot --path .
```

The authored design resolution is 1920×1080. The application is capped at 60 FPS.

## Development

Run the repository verifier before handing off substantive implementation changes:

```bash
./tools/verify_project.sh
git diff --check
```

If Godot is not available on `PATH`, provide it explicitly:

```bash
GODOT_EXECUTABLE=/path/to/godot ./tools/verify_project.sh
```

On macOS, for example:

```bash
GODOT_EXECUTABLE=/Applications/Godot.app/Contents/MacOS/Godot ./tools/verify_project.sh
```

The verifier checks project structure, important resource and persistence contracts, imported scenario data, export configuration, and other repository invariants. When Godot is available it also performs project import and runtime/script tests.

Specialized visual captures are available through `tests/visual_capture.gd`.

## Project structure

```text
src/
├── app/         Application composition, services, and routing
├── intro/       Startup movie and warning flow
├── title/       Title screen and Bonus content
├── adv/         ADV presentation and media integration
├── save_load/   Shared Save/Load feature
├── settings/    Settings UI, model, and persistence
├── scenario/    Scenario parser/runtime and cross-feature contracts
├── core/        Shared infrastructure and persistence services
└── ui/          Reusable UI and design-layout infrastructure

assets/          Runtime artwork, audio, video, fonts, themes, and manifests
tests/           Runtime, contract, and visual tests
tools/           Import and verification scripts
docs/            Architecture and specialized technical documentation
```

For dependency rules and implementation boundaries, see [docs/architecture.md](docs/architecture.md).

## Source import boundary

The runtime does not directly depend on the original KRKR project.

Source `.ks` scenarios are converted to UTF-8/LF through the import tooling before entering `assets/scenario/`. Media import tools copy the runtime-required subset of source assets and normalize source metadata where necessary.

Runtime code should consume only project-local Godot resources and normalized project data rather than adding TJS or UTF-16 compatibility paths.

## Documentation

* [Architecture](docs/architecture.md) — module ownership, dependency direction, scene responsibilities, persistence, and feature boundaries
* [Cloud validation and tuning](docs/cloud_loop_validation.md) — Title cloud rendering and visual validation
* [AGENTS.md](AGENTS.md) — concise repository instructions for coding agents

## Known limitation

The source font families used by the original settings are not all available in the Godot project yet. Font selections that do not have an imported source family currently fall back to the bundled Xiaolai font.

## Notice

This is an unofficial fan and technical remake project and is not affiliated with or endorsed by the original rights holders.

*Yosuga no Sora*, its characters, artwork, audio, video, and other original game materials remain the property of their respective rights holders. Source-derived assets included in or referenced by this project should not be assumed to be freely redistributable.
