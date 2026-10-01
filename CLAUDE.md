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
- There are no automated tests. To check changes headlessly, use the console binary: `Godot_v4.7.2-stable_win64_console.exe --headless --path . <scene.tscn> --quit-after <frames>` runs a scene and prints script errors. Run `--headless --import` first after adding a `class_name`, so it is registered.
- Driving the fight end to end needs a throwaway `extends SceneTree` script run with `-s` and `--fixed-fps 60`, which makes runs deterministic. Inject `ui_accept` from a `process_frame` handler with `Input.parse_input_event` followed by `Input.flush_buffered_events()`. That is how real input arrives, at the start of a frame, and it reaches both polling code and `_unhandled_input`.
- `Assets/PracAnim/ShaderTester.tscn` references a missing `boyz.png`. This was already broken in Godot 3, and the scene is scratch.

## Scene flow

`Src/CutScenes/Intro.tscn` (main scene) → `Src/Interface/Menus/MainMenu.tscn` → `Src/CutScenes/IntroMitch.tscn` → `Src/Interface/Main.tscn` (the fight) → `DeathMenu.tscn` on player death, or `ToBeContinued.tscn` after Mitch's third stage.

Scenes switch with `get_tree().change_scene_to_file(...)` and hard-coded `res://` paths. Moving or renaming a scene file means updating those string literals.

## Boss fight architecture

`Src/Interface/Main.gd` runs the fight as a few coroutines; `Src/Actors/Mitch/Mitch.gd` owns the boss's health and his active stage.

1. **Stages.** `Mitch.start_stage(index)` instances `Phases/Stage{1,2,3}.tscn` as his child, resets his health and forwards the stage's `attacks_finished` signal. Every stage extends `Phases/BossStage.gd` (`class_name BossStage`):
   - `start()` is the opening and `resume()` is one round of attacks. Both are linear coroutines that use `await wait(seconds)` and end with `attacks_finished.emit()`.
   - Use `wait()`, not `get_tree().create_timer()`. Its Timer is a child of the stage, so a freed stage drops the sequence cleanly.
   - Spawn with `spawn_boomerang`, `spawn_boomerang_row`, `spawn_boomerang_sweep` and `spawn_leg_attack`. Projectiles are configured before `add_child` and live in Mitch's coordinate space, because the stage is his child.
2. **Player's turn.** `Main._player_turn()` hides the `"defense"` group and calls `stage.on_player_turn_started()`. It then spawns `AttackBar` and awaits its `struck(damage)` signal, awaits `mitch.play_hit()`, and applies the damage.
3. **After the turn.** If Mitch survives, Main calls `stage.on_player_turn_ended(health)` and then `stage.resume()`. Stage 3 uses `on_player_turn_ended` to make Malocchio fire faster at 50 health or less.
4. **Stage beaten.** `_end_stage()` plays the dialogue from `STAGE_END_DIALOGUES`. Then `_next_stage()` runs the curtain transition and the next stage, or `_mitch_dies()` plays the ending.

**Node groups:**
- `"defense"` (Player, BattleSquare): hidden and shown with the built-in `hide`/`show` around the player's turn.
- `"environment"`: freed when the player dies.
- `"player"`: lets Malocchio find the player without node paths.

**Damage:** `Player.take_hit(damage)` is the only way to hurt the player, and it respects the invincibility timer.
- Projectiles extend `Src/objects/Projectile.gd` (`class_name Projectile`, with a `damage` export) and sit on the "Projectiles" layer, which `ProjectileDetector` watches.
- Malocchio's laser calls `take_hit` on whatever its RayCast2D touches.
- The player emits `hit(health)`, which Main uses for camera shake and the HUD, and `died`.

## Dialogue and cutscenes

- **Dialogue:** `Src/Interface/DialogueBox.tscn` (`class_name DialogueBox` on the root). Set `dialogue_path`, `add_child` it, and `await dialogue.finished`. It frees itself afterwards. The JSON is an array of `{"name", "image", "text", "time"}` entries:
  - `text` may contain BBCode;
  - `time` is the per-letter delay in seconds, stored as a string;
  - `image` is unused.

  `ui_accept` finishes the current line, or advances to the next one.
- **Intro crawl:** `Intro.gd` feeds its `PAGES` table to the bundled `addons/GodotTIE` text engine, and awaits `buff_end` after each page.
- **Mitch's entrance:** `IntroMitch.tscn` is animation-driven. The `MitchEnter` animation calls `_start_dialogue()` at its end.

## Misc

- `export_presets.cfg` defines Windows Desktop and HTML5 exports. The HTML5 export goes into the author's GitHub Pages repo, using a relative path outside this repo.
- `Assets/PracAnim/` and `scripts/ReflectCurve.py` are scratch or experimental files, not part of the game.
