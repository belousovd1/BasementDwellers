# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

BasementDwellers is a small Godot game made for friends: a bullet-hell style boss fight (boss "Mitch", three stages) framed by typewriter-text cutscenes and dialogue. All game code is GDScript under `Src/`. There is no test suite, linter, or build script. You run and export the game through the Godot editor, or launch it from VS Code with the `godot-tools` launch config in `.vscode/launch.json`.

## Engine version: read this first

- **The committed code is Godot 3.x.** HEAD's `project.godot` has `config_version=4`, and every script uses Godot 3 APIs: `onready var`, `yield(...)`, `.instance()`, `KinematicBody2D` + `move_and_slide(velocity)`, `connect("sig", obj, "method")`, `File.new()`, `JSON.parse(...).result`, `get_tree().change_scene(...)`, and `export var`.
- **Opening the project in Godot 4.7 has dirtied the working tree.** `.vscode/settings.json` points at Godot 4.7.2, and that editor rewrote `project.godot` (now `config_version=5`) and many `*.import` files. That rewrite:
  - zeroed every keycode in the `[input]` map (`left`/`right`/`up`/`down` were W/A/S/D; `dialogue_next`/`continue_dialogue` were Space/Enter);
  - dropped `_global_script_classes` (`DialogueBox`, `Projectiles`).
- **None of the scripts have been ported to Godot 4 syntax yet.** Before changing code, confirm with the user which engine version they are targeting. Don't mix Godot 3 and Godot 4 APIs. A port to Godot 4 must cover the scripts, the `.tscn` files and the input map together.
- `.import/` is the Godot 3 import cache and is gitignored. `.godot/` is the Godot 4 cache.

## Scene flow

`Src/CutScenes/Intro.tscn` (main scene) → `Src/Interface/Menus/MainMenu.tscn` → `Src/CutScenes/IntroMitch.tscn` → `Src/Interface/Main.tscn` (the fight) → `DeathMenu.tscn` on player death, or `ToBeContinued.tscn` after Mitch's third stage.

Scenes switch with `get_tree().change_scene(...)` and hard-coded `res://` paths. Moving or renaming a scene file means updating those string literals.

## Boss fight architecture (`Src/Interface/Main.gd`)

`Main.gd` is the fight's state machine. It works together with `Src/Actors/Mitch/Mitch.gd` and the stage scripts in `Src/Actors/Mitch/Phases/Stage{1,2,3}.gd`.

1. **Starting a stage.** `Main` holds `current_stage` (the `stages` enum: 0–2, plus 3 = defeated). Mitch instances the matching `Stage*.tscn` as a child (`intiate_stage1/2/3`, spelled that way in the code).
2. **Stage attack script.** Each Stage node runs a scripted attack sequence. It spawns projectiles (paintbrush boomerangs, Malocchio, legs, lasers), chains steps with `make_timer(wait, "next_method_name")` and `yield` timers, then emits `done_attacking`. In `_ready` the stage connects that signal to `$"../../"` (Main) `attack_boss`.
3. **Player's turn.** `attack_boss()` hides the `"defense"` group and spawns the `AttackBar` minigame. Mitch's `AnimationPlayer` `animation_finished` ends up calling `Main.attack_finished`, which applies `attack_bar.get_damage()` to `mitch.health`.
4. **Back to the boss.** If Mitch survives, Main emits `attack_finished`. `stage_connect()` has wired that signal to a re-entry method on the current stage, so the attack loop resumes partway through the sequence: `Stage1.attack4`, `Stage2.attack1`, `Stage3.attack2`. Stage 3 also switches to `set_better_malocchio()` once health is at or below 50.
5. **Stage defeated.** When health reaches 0 or below, `start_dialog(stage)` instances `DialogueBox.tscn` with a JSON script. Its `finish` signal calls `manage_new_stage()`, which plays the curtain transition, calls `mitch.change_stage()`, rewires signals with `stage_connect`, and resets health to 100. After stage 3 it plays the death sequence instead.

Signal wiring is done by hand and is order-sensitive. Every `connect` has a matching `disconnect` (in `stage_connect`, in `attack_finished`, and on the curtain `AnimationPlayer` in `fade_in`). Keep those pairs balanced when you edit the flow.

**Node groups** (assigned in `Main.tscn`) are used for broadcast calls:
- `"defense"` (Player, BattleSquare): `call_group(..., "invisible"/"visible")` toggles the dodge arena between the boss turn and the player turn.
- `"environment"`: `queue_free`'d on player death.
- `"everything_but_fire"`: used by the main menu.

Any node in these groups must implement the methods that get broadcast to them.

**Player** (`Src/Actors/Player/Player.gd`): its `ProjectileDetector` area reads `area.damage` from whatever hits it. Projectiles therefore need a `damage` property; see `Src/objects/Projectiles.gd` (`class_name Projectiles`). Hits emit `player_hit` to Main, which handles screen shake via `OnHitCamera` and updates the UI.

## Dialogue and cutscenes

- **In-fight dialogue:** `Src/Interface/DialogueBox.gd` (`class_name DialogueBox`) loads a JSON array from `Src/CutScenes/dialogues/Mitch/*.json`. Each entry has the shape `{"name", "image", "text", "time"}`:
  - `text` may contain BBCode;
  - `time` is the per-character reveal delay, stored as a string.

  `ui_accept` skips the reveal or advances to the next line.
- **Intro text:** `Intro.gd` uses the bundled `addons/GodotTIE` plugin (`buff_text`/`buff_silence`, chained through the `buff_end` signal).

## Misc

- `export_presets.cfg` defines Windows Desktop and HTML5 exports. The HTML5 export goes into the author's GitHub Pages repo, using a relative path outside this repo.
- `Assets/PracAnim/` and `scripts/ReflectCurve.py` are scratch or experimental files, not part of the game.
