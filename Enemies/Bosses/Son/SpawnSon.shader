shader_type canvas_item;

uniform float time = 0.0;
uniform float speed = 3.0;
uniform float initialOffset = 0.5;
uniform float clipOffset = 0.75;

void fragment() {
	COLOR = texture(TEXTURE, vec2(UV.x, clamp((UV.y-initialOffset) + time, UV.y-initialOffset, UV.y)));
	if (UV.y > clipOffset)
	{
		COLOR.a = 0.0;
	}
}