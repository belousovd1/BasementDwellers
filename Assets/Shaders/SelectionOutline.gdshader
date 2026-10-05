shader_type canvas_item;
// Outlines a sprite's opaque pixels, one texel thick, like Blender's outline
// around the selected object. The texture needs a transparent border for the
// outline to fit in.

uniform vec4 outline_color : source_color = vec4(1.0, 0.667, 0.251, 1.0);

// The node's modulate. In fragment(), COLOR already has the texture multiplied
// in, which would hide the outline on the transparent border.
varying vec4 tint;

void vertex() {
	tint = COLOR;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.a < 0.5) {
		vec2 texel = TEXTURE_PIXEL_SIZE;
		float neighbours = texture(TEXTURE, UV + vec2(texel.x, 0.0)).a
				+ texture(TEXTURE, UV - vec2(texel.x, 0.0)).a
				+ texture(TEXTURE, UV + vec2(0.0, texel.y)).a
				+ texture(TEXTURE, UV - vec2(0.0, texel.y)).a;
		if (neighbours > 0.0) {
			color = outline_color;
		}
	}
	COLOR = color * tint;
}
