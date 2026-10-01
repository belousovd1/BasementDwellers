# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

BasementDwellers is a small Godot game made for friends: a bullet-hell style boss fight (boss "Mitch", three stages) framed by typewriter-text cutscenes and dialogue. All game code is GDScript under `Src/`. There is no test suite, linter, or build script. You run and export the game through the Godot editor, or launch it from VS Code with the `godot-tools` launch config in `.vscode/launch.json`.

## Engine version and checking changes

- The project targets **Godot 4.7** (editor path in `.vscode/settings.json`). It was ported from Godot 3 on the `godot4-port` branch, so write Godot 4 GDScript only: `@onready`, `await`, `Callable`, `instantiate()`, `change_scene_to_file()`.
- Godot 3 habits that broke during the port and still matter:
  - `String.right(n)` now returns the last `n` characters. Use `substr(n)` for "from position n".
  - Godot 4 refuses `add_child` while the tree is adding or removing nodes. Connect `tree_exiting`-style signals with `CONNECT_DEFERRED` if the handler spawns nodes.
  - Camera2D has no `clear_current()`. `OnHitCamera` is `enabled = false` and gets toggled on for hits.
  - `AnimationPlayer.stop()` resets the animation visually. The attack bar uses `pause()` to freeze the indicator where the player stopped it.
- Collision detection is one-way in Godot 4: a node only detects layers in its *own* mask. Godot 3 also matched when the *other* node's mask covered this node's layer, and the original scenes rely on that.
  - `Player/ProjectileDetector` mask is 5 (layer 1 + "Projectiles").
  - The `Player` body mask is 15, which includes the BattleSquare walls on layer 4 (value 8).
  - A new projectile must sit on a layer in the detector's mask and expose a `damage` property.
- Fonts in Godot 4 carry no size. Fonts are `FontVariation` resources wrapping the `.ttf`, and each Control sets `theme_override_font_sizes/*`. The GodotTIE intro text uses the plugin's `FONT_SIZE` export.
- The project-wide texture filter is Nearest (pixel art). Nodes that should be smoothed set `texture_filter = 2` (Linear). Shader samplers set filter and repeat hints on the uniform, e.g. `repeat_enable` for the scrolling fire noise.
- The black combat background comes from `default_clear_color`. Main's background ColorRect runs the shockwave shader, which samples the screen.
- Most `.tscn` files are still in the old text format (numeric `id=` values). Godot rewrites a file in the new format when you save it in the editor; both formats load fine.
- `.godot/` (Godot 4 cache) and `.import/` (old Godot 3 cache) are gitignored.
- There are no automated tests. To check changes headlessly, use the console binary: `Godot_v4.7.2-stable_win64_console.exe --headless --path . <scene.tscn> --quit-after <frames>` runs a scene and prints script errors. Driving the fight end to end needs a throwaway `extends SceneTree` script run with `-s`. It should press `ui_accept` (via `Input.action_press`) for the attack bar and dialogue.
- `Assets/PracAnim/ShaderTester.tscn` references a missing `boyz.png`. This was already broken in Godot 3, and the scene is scratch.

## Scene flow

`Src/CutScenes/Intro.tscn` (main scene) → `Src/Interface/Menus/MainMenu.tscn` → `Src/CutScenes/IntroMitch.tscn` → `Src/Interface/Main.tscn` (the fight) → `DeathMenu.tscn` on player death, or `ToBeContinued.tscn` after Mitch's third stage.

Scenes switch with `get_tree().change_scene_to_file(...)` and hard-coded `res://` paths. Moving or renaming a scene file means updating those string literals.

## Boss fight architecture (`Src/Interface/Main.gd`)

`Main.gd` is the fight's state machine. It works together with `Src/Actors/Mitch/Mitch.gd` and the stage scripts in `Src/Actors/Mitch/Phases/Stage{1,2,3}.gd`.

1. **Starting a stage.** `Main` holds `current_stage` (the `stages` enum: 0–2, plus 3 = defeated). Mitch instances the matching `Stage*.tscn` as a child (`intiate_stage1/2/3`, spelled that way in the code).
2. **Stage attack script.** Each Stage node runs a scripted attack sequence. It spawns projectiles (paintbrush boomerangs, Malocchio, legs, lasers), chains steps with `make_timer(wait, "next_method_name")` and `yield` timers, then emits `done_attacking`. In `_ready` the stage connects that signal to `$"../../"` (Main) `attack_boss`.
3. **Player's turn.** `attack_boss()` hides the `"defense"` group and spawns the `AttackBar` minigame. Mitch's `AnimationPlayer` `animation_finished` ends up calling `Main.attack_finished`, which applies `attack_bar.get_damage()` to `mitch.health`.
4. **Back to the boss.** If Mitch survives, Main emits the `boss_turn_resumed` signal. `stage_connect()` has wired that signal to a re-entry method on the current stage, so the attack loop resumes partway through the sequence: `Stage1.attack4`, `Stage2.attack1`, `Stage3.attack2`. Stage 3 also switches to `set_better_malocchio()` once health is at or below 50.
5. **Stage defeated.** When health reaches 0 or below, `start_dialog(stage)` instances `DialogueBox.tscn` with a JSON script. Its `finish` signal calls `manage_new_stage()`, which plays the curtain transition, calls `mitch.change_stage()`, rewires signals with `stage_connect`, and resets health to 100. After stage 3 it plays the death sequence instead.

Signal wiring is done by hand and is order-sensitive. Every `connect` has a matching `disconnect` (in `stage_connect`, in `attack_finished`, and on the curtain `AnimationPlayer` in `fade_in`). Keep those pairs balanced when you edit the flow.

**Node groups** (assigned in `Main.tscn`) are used for broadcast calls:
- `"defense"` (Player, BattleSquare): `call_group(..., "invisible"/"make_visible")` (a method named `visible()` would clash with the Godot 4 property) toggles the dodge arena between the boss turn and the player turn.
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
