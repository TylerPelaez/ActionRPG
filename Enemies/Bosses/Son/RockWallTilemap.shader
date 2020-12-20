shader_type canvas_item;

uniform mat4 global_transform;

uniform float time = 0.0;
uniform float initialOffset = 10.0;
varying vec2 wrld_vertex;


void vertex() {
	float new_y = (VERTEX.y - initialOffset) + (time * initialOffset);
	VERTEX.y = clamp(new_y, VERTEX.y, VERTEX.y - initialOffset);
	wrld_vertex = (global_transform * vec4(VERTEX, 0.0, 1.0)).xy; 
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (wrld_vertex.y > 0.0) {
		COLOR.a = 0.0;
	}
}