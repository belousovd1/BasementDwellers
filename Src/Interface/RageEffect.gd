@tool
class_name RageEffect
extends RichTextEffect
## [code][rage]...[/rage][/code]: furious text. Each letter slams in oversized,
## tilted and white-hot as it is typed, then keeps shaking, twitching and
## flickering with heat for as long as it is on screen.
##
## Parameters: [code]level[/code] is how hard the letters shake, in pixels
## (default 6); [code]heat[/code] how strongly they flicker towards white, 0 to 1
## (default 0.6); [code]slam[/code] how big a letter is when it lands (default
## 2.5); [code]size[/code] the font size, to keep the letters centred as they
## scale (default 64, the dialogue's).

var bbcode := "rage"

## Seconds a letter takes to land.
const SLAM_TIME := 0.16
## How many times a second the shake kicks the letters somewhere new.
const SHAKE_RATE := 30.0
## The most a letter twitches round, in radians.
const TWITCH := 0.12
const WHITE_HOT := Color(1.0, 0.96, 0.8)


func _process_custom_fx(fx: CharFXTransform) -> bool:
	var level: float = fx.env.get("level", 6.0)
	var heat: float = fx.env.get("heat", 0.6)
	var slam: float = fx.env.get("slam", 2.5)
	var size: float = fx.env.get("size", 64.0)
	var index := fx.relative_index
	var time := fx.elapsed_time

	# When each letter was first drawn. The tag's env lasts as long as the
	# text, and a new line starts with a fresh one.
	var born: Dictionary = fx.env.get_or_add("_born", {})
	var landing := clampf((time - born.get_or_add(index, time)) / SLAM_TIME, 0.0, 1.0)
	var landed := 1.0 - pow(1.0 - landing, 3.0)

	# A fresh random kick SHAKE_RATE times a second, different for each letter,
	# and harder while the letter is still landing.
	var tick := int(time * SHAKE_RATE)
	var kick := Vector2(_noise(index, tick, 0), _noise(index, tick, 1))
	var shake := level * (1.0 + 2.0 * (1.0 - landed))
	var twitch := _noise(index, tick, 2) * TWITCH + (1.0 - landed) * 0.5 * signf(_noise(index, 0, 3))

	# Scale and twitch round the middle of the letter, dropping in from above.
	var width := TextServerManager.get_primary_interface() \
			.font_get_glyph_advance(fx.font, int(size), fx.glyph_index).x
	var middle := Vector2(width / 2, -size * 0.35)
	var scale := lerpf(slam, 1.0, landed)
	fx.transform = fx.transform * Transform2D(0.0, middle) \
			* Transform2D(twitch, Vector2(scale, scale), 0.0, Vector2.ZERO) \
			* Transform2D(0.0, -middle)
	fx.offset += kick * shake + Vector2(0, -size * 0.8 * (1.0 - landed))

	# Flicker between the letter's colour and white heat, white as it lands.
	var flicker := 0.5 + 0.5 * sin(time * 25.0 + index * 1.7)
	var hot := maxf(heat * flicker * 0.7, 1.0 - landed)
	var alpha := fx.color.a
	fx.color = fx.color.lerp(WHITE_HOT, hot)
	fx.color.a = alpha
	return true


## A repeatable random number from -1 to 1 for this letter, tick and channel.
func _noise(index: int, tick: int, channel: int) -> float:
	return posmod(hash(Vector3i(index, tick, channel)), 2001) / 1000.0 - 1.0
