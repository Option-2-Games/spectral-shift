shader_type canvas_item;
render_mode light_only;

void light() {
	LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY, LIGHT_COLOR.a);
}
