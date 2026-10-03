# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

BasementDwellers is a small Godot game made for friends: bullet-hell style boss fights (Mitch, Mike, Gabe, Rafi and finally Alex, three stages each) framed by typewriter-text cutscenes and dialogue. All game code is GDScript under `Src/`. There is no test suite, linter, or build script. You run and export the game through the Godot editor, or launch it from VS Code with the `godot-tools` launch config in `.vscode/launch.json`.

## Engine version and checking changes

- The project targets **Godot 4.7** (editor path in `.vscode/settings.json`). It was ported from Godot 3 on the `godot4-port` branch, so write Godot 4 GDScript only: `@onready`, `await`, `Callable`, `instantiate()`, `change_scene_to_file()`.
- Godot 3 habits that broke during the port and still matter:
  - `String.right(n)` now returns the last `n` characters. Use `substr(n)` for "from position n".
  - Godot 4 refuses `add_child` while the tree is adding or removing nodes. Connect `tree_exiting`-style signals with `CONNECT_DEFERRED` if the handler spawns nodes.
  - Camera2D has no `clear_current()`. `OnHitCamera` is `enabled = false` and gets toggled on for hits.
  - `AnimationPlayer.stop()` resets the animation visually. Use `pause()` to freeze one where it is.
- Collision detection is one-way in Godot 4: a node only detects layers in its *own* mask. Godot 3 also matched when the *other* node's mask covered this node's layer, and the original scenes rely on that.
  - `Player/ProjectileDetector` mask is 5 (layer 1 + "Projectiles").
  - The `Player` body mask is 15, which includes the BattleSquare walls on layer 4 (value 8).
  - A new projectile must sit on a layer in the detector's mask and expose a `damage` property.
- Fonts in Godot 4 carry no size. Fonts are `FontVariation` resources wrapping the `.ttf`, and each Control sets `theme_override_font_sizes/*`. The GodotTIE intro text uses the plugin's `FONT_SIZE` export.
- The project-wide texture filter is Nearest (pixel art). Nodes that should be smoothed set `texture_filter = 2` (Linear). Shader samplers set filter and repeat hints on the uniform, e.g. `repeat_enable` for the scrolling fire noise.
- Godot 3 → 4 differences that changed visuals, in case more turn up:
  - **Animation tracks:** a *continuous* value track applies its first key's value even before that key's time; Godot 3 left the property alone until then. Don't animate one property with two tracks. Use one track, with transition 0 (constant) on keys that should hold.
  - **Shader screen coordinates:** `SCREEN_UV` starts at the top-left in Godot 4 and at the bottom-left in Godot 3. The summon shockwave's `center` is in Godot 4 coordinates.
  - **Shader texture sampling:** samplers have no import flags any more. Particle shaders repeat by default, so give `uniform sampler2D` explicit `repeat_disable`/`filter_*` hints.
- The black combat background comes from `default_clear_color`. Main's background ColorRect runs the shockwave shader, which samples the screen.
- Most `.tscn` files are still in the old text format (numeric `id=` values). Godot rewrites a file in the new format when you save it in the editor; both formats load fine.
- When writing a `.tscn` by hand, a node-typed export (such as a boss's `mouth`) needs `node_paths=PackedStringArray("mouth")` in the node's header. Without it the `NodePath` is silently dropped.
- Running `--import` from the command line can rewrite hundreds of `.import` files with LF line endings and no other change. Restore those with `git checkout` rather than committing them.
- `.godot/` (Godot 4 cache) and `.import/` (old Godot 3 cache) are gitignored.
- Audio uses the Music and SFX buses (`Assets/Sound/default_bus_layout.tres`); every AudioStreamPlayer belongs on one of them. The `Settings` autoload (`Src/Settings.gd`) applies the saved volumes at startup, and the options menu edits them.
  - The volumes are saved in `user://settings.cfg`.
  - Volumes are linear, 0 to 1.
- There are no automated tests. To check changes headlessly, use the console binary: `Godot_v4.7.2-stable_win64_console.exe --headless --path . <scene.tscn> --quit-after <frames>` runs a scene and prints script errors. Run `--headless --import` first after adding a `class_name`, so it is registered. Scripts run with `-s` don't get autoloads, so code that uses `Settings` has to be tested from a scene.
- Driving the fight end to end needs a throwaway `extends SceneTree` script run with `-s` and `--fixed-fps 60`, which makes runs deterministic. Inject `ui_accept` from a `process_frame` handler with `Input.parse_input_event` followed by `Input.flush_buffered_events()`. That is how real input arrives, at the start of a frame, and it reaches both polling code and `_unhandled_input`.
- `Assets/PracAnim/ShaderTester.tscn` references a missing `boyz.png`. This was already broken in Godot 3, and the scene is scratch.

## Scene flow

`Src/CutScenes/Intro.tscn` (main scene) → `Src/Interface/Menus/MainMenu.tscn` → `Src/CutScenes/IntroMitch.tscn` → `Src/Interface/Main.tscn` (Mitch's fight) → `Src/CutScenes/IntroMike.tscn` → `Src/Interface/MikeFight.tscn` → `Src/CutScenes/IntroGabe.tscn` → `Src/Interface/GabeFight.tscn` → `Src/CutScenes/IntroRafi.tscn` → `Src/Interface/RafiFight.tscn` → `Src/CutScenes/IntroAlex.tscn` → `Src/Interface/AlexFight.tscn` → `Src/Interface/Menus/TheEnd.tscn` after Alex's third stage.

- The main menu's Load button opens `Src/Interface/Menus/BossSelect.tscn`, which starts at any boss's entrance instead of at Mitch. The story carries on from there as usual. A new boss needs a line in `BossSelect.gd`'s `BOSSES` table to show up there.
- Each boss's `next_scene` export says where to go once it dies.
- Dying in a fight goes to `DeathMenu.tscn`. Its Restart button returns to that same fight: every fight stores its own path in the static `DeathMenu.fight_scene` when it starts.

Scenes switch with `get_tree().change_scene_to_file(...)` and hard-coded `res://` paths. Moving or renaming a scene file means updating those string literals.

## Boss fight architecture

`Src/Interface/Main.gd` runs a fight against any `Boss` as a few coroutines. `Main.tscn` sets its `boss_scene` export to Mitch; `MikeFight.tscn`, `GabeFight.tscn`, `RafiFight.tscn` and `AlexFight.tscn` inherit `Main.tscn` and swap in the other bosses. Main adds the boss behind the arena when the fight starts.

`Src/Actors/Boss.gd` (`class_name Boss`) owns the boss's health, banter and active stage. Everything boss-specific is an export on the boss's scene (`Mitch.tscn`, `Mike.tscn`, `Gabe.tscn`, `Rafi.tscn`, `Alex.tscn`):
- `stages`, plus `stage_end_dialogues` and `stage_music`, one entry per stage. A null music entry keeps the previous stage's music playing.
- `fight_*` and `dialogue_*` placement: where the boss stands while attacking, and while talking between stages.
- `banter`, and the `mouth` node and offset that speech bubbles point at.
- `death_texture`, `death_offset` and `death_scale` for the pixel-shatter death effect.

A boss scene also needs an `AnimationPlayer` with `idle` and `hit` animations, and a `DeathSound` player.

1. **Stages.** `boss.start_stage(index)` instances that stage as the boss's child, resets the boss's health and forwards the stage's `attacks_finished` signal. Every stage extends `Src/Actors/BossStage.gd` (`class_name BossStage`):
   - `start()` is the opening and `resume()` is one round of attacks. Both are linear coroutines that use `await wait(seconds)` and end with `attacks_finished.emit()`.
   - Use `wait()`, not `get_tree().create_timer()`. Its Timer is a child of the stage, so a freed stage drops the sequence cleanly.
   - Mitch's stages extend `MitchStage`, which has `spawn_boomerang`, `spawn_boomerang_row`, `spawn_boomerang_sweep` and `spawn_leg_attack`. Projectiles are configured before `add_child` and live in Mitch's coordinate space, because the stage is his child.
   - Mike's, Gabe's and Alex's stages extend `MikeStage`, `GabeStage` and `AlexStage`, which share `Src/Actors/ArenaStage.gd`. They spawn into `arena`, a top-level node at the arena's centre, so positions are in arena space (the inner walls are `ARENA_HALF_SIZE` away) and stay put when the boss moves.
   - Rafi's fight is a placeholder until he has a theme: his stage 1 extends `MikeStage` and his stages 2 and 3 extend `GabeStage`, reusing their attacks.
   - Alex's rounds keep time: `AlexStage.beats(n)` waits n beats at its `BPM`.
   - Their attacks are drawn in code as chunky pixels with `Src/objects/PixelArt.gd`, so they need no sprites. Rectangles that warn before they hurt (loop cuts, render tiles) extend `Src/objects/WarningZone.gd`, and projectiles that bounce round the arena (Gabe's tyres, Alex's records) extend `Src/objects/Bouncer.gd`. Pictures such as Gabe's apples and cars are drawn from strings with `PixelArt.bitmap()`.
2. **Player's turn.** `Main._player_turn()` hides the `"defense"` group and calls `stage.on_player_turn_started()`. It then spawns `AttackBar` and awaits its `struck(damage)` signal, awaits `boss.play_hit()`, and applies the damage.
   - `AttackBar.gd` draws the bar itself in pixel art and rates the hit. Its sweep (`PERIOD`, `FAST_PERIOD`) and damage bands (`BANDS`) are constants at the top; the damage falls linearly from 100 in the middle to 0 at the ends. The indicator starts at the right-hand end, so there is no free hit when the bar appears.
   - Each boss's `hit` animation drives its `Hit` node (`Src/objects/HitSpark.gd`) through frames 2 to 15, which draw the strike in white pixels: a ring with a slice through it, then a thick zigzag lightning bolt along the slice that flickers once, thins and throws off a few sparks. Its per-frame tables are at the top of the script. Mitch's is scaled to undo his 1.8x, so its pixels match the others'. The other bosses blink during the hit.
3. **After the turn.** If the boss survives, Main calls `stage.on_player_turn_ended(health)` and then `stage.resume()`. At 50 health or less, both final stages get harder:
   - Mitch's stage 3 pauses Malocchio's laser during the turn and restarts it afterwards, switching to rapid fire.
   - Mike's stage 3 hides the 3D cursor during the turn. After it, cubes come more often and three tiles render at a time instead of two.
   - Gabe's stage 3 removes the bouncing tyres during the turn and launches fresh ones after it. A third tyre joins, and the road rollers, traffic and apples all speed up.
   - Rafi's and Alex's stage 3 do the same with their tyres and records.
4. **Power-up.** `Boss.on_stage_beaten()` calls `power_up()` once the second-to-last stage is beaten, so the boss shows its final look in that dialogue. Mitch switches to `stage3_idle`. Mike gets Blender's orange selection outline (`Assets/Shaders/SelectionOutline.gdshader`). Gabe turns menacing: JoJo's purple ゴゴゴ start popping up around him (`Gabe/Menacing.gd`). Rafi gets a red outline, from the same shader as Mike's. Alex's encore sets off confetti around him (`Alex/Confetti.gd`).
5. **Stage beaten.** `_end_stage()` plays the boss's dialogue for the stage. Then `_next_stage()` runs the curtain transition and the next stage. After the last stage, `_boss_dies()` awaits `boss.die()` (the last hit and the pixel shatter) and changes to `next_scene`.

**Node groups:**
- `"defense"` (Player, BattleSquare): hidden and shown with the built-in `hide`/`show` around the player's turn.
- `"environment"`: freed when the player dies.
- `"player"`: lets Malocchio find the player without node paths.

**Damage:** `Player.take_hit(damage)` is the only way to hurt the player. It respects the invincibility timer, and a hidden player (during their turn and the dialogue between stages) can't be hit.
- Projectiles extend `Src/objects/Projectile.gd` (`class_name Projectile`, with a `damage` export) and sit on the "Projectiles" layer, which `ProjectileDetector` watches.
- Malocchio's laser calls `take_hit` on whatever its RayCast2D touches.
- The player emits `hit(health)`, which Main uses for camera shake and the HUD, and `died`.

## Dialogue and cutscenes

- **Dialogue:** `Src/Interface/DialogueBox.tscn` (`class_name DialogueBox` on the root). Set `dialogue_path`, `add_child` it, and `await dialogue.finished`. It frees itself afterwards. The JSON is an array of `{"name", "image", "text", "time"}` entries:
  - `text` may contain BBCode;
  - `time` is the per-letter delay in seconds, stored as a string;
  - `image` is unused.

  `ui_accept` finishes the current line, or advances to the next one.
- Each boss's dialogue lives in `Src/CutScenes/dialogues/<Boss>/`.
- **Mid-fight banter:** `boss.say(line)` shows a `Src/Interface/SpeechBubble.tscn` at the boss's `mouth`.
  - The bubble is top-level and follows the mouth in whole pixels. Its text is wrapped by hand, so the bubble's size is known before it is drawn.
  - While the boss is attacking, `start_talking()` picks a line from the exported `banter` array every `banter_interval` seconds. Main calls `stop_talking()` when the player's turn starts.
  - Mike's and Gabe's stages shout lines with `call_out(line)`, which uses `say(line, true)` to replace whatever bubble is already up.
- **Intro crawl:** `Intro.gd` feeds its `PAGES` table to the bundled `addons/GodotTIE` text engine, and awaits `buff_end` after each page.
- **Mitch's entrance:** `IntroMitch.tscn` is animation-driven. The `MitchEnter` animation calls `_start_dialogue()` at its end.
- **Mike's entrance:** `IntroMike.gd` tweens Mike down from above the screen to where he is placed in `IntroMike.tscn`, then starts the dialogue. Accept skips the descent.
- **Gabe's entrance:** `IntroGabe.gd` drifts Gabe in from the right to where he is placed in `IntroGabe.tscn`, starts his ゴゴゴ, then starts the dialogue. Accept skips the drift.
- **Alex's entrance:** `IntroAlex.gd` switches a spotlight on in the dark and fades Alex in under it, then starts the dialogue. Accept skips to the dialogue.
- **Rafi's entrance:** `IntroRafi.gd` fades Rafi in out of the dark, then starts the dialogue. Accept skips the fade.
- **Gabe's lines:** he quotes videogamedunkey a lot. The quotes in his dialogue and banter come from Dunkey's catchphrases as listed on All The Tropes, and are shown in orange.

## Misc

- `export_presets.cfg` defines Windows Desktop and HTML5 exports. The HTML5 export goes into the author's GitHub Pages repo, using a relative path outside this repo.
- `Assets/PracAnim/` and `scripts/ReflectCurve.py` are scratch or experimental files, not part of the game.
- `Assets/Sprites/Mike/mike.png` is the Mike layer of `mike-boss.ase`, exported at full canvas size (96×128). To re-export it, hide the Gabe layer and export the canvas. The Mike layer is set to 75 opacity in the `.ase`, so set it back to full first.
- `Assets/Sprites/Alex/alex.png` is generated by `scripts/alex_sprite.py`: cap, round glasses, hoodie, shorts and a white electric guitar. It and `rafi_sprite.py` share their shape-and-outline code in `scripts/pixel_figure.py`.
- `Assets/Sprites/Rafi/rafi.png` is generated by `scripts/rafi_sprite.py`, which draws him whole from shapes and detail pixels: arms crossed, quiff, round glasses, short beard. Rerun it after changing the drawing, and keep `Rafi.tscn`'s offsets in step if the figure moves.
- `Assets/Sprites/Gabe/gabe.png` is generated by `scripts/gabe_jojo_sprite.py`: Gabe's head (the Gabe layer of `gabe.ase`) on a body in a JoJo pose, built from shapes in that script. Rerun it after changing the head or the pose, or repaint the PNG by hand (keep the 96×128 canvas, and `Gabe.tscn`'s offsets assume the figure stays where it is).
