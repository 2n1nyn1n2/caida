shader_type canvas_item;
// Do NOT include "render_mode unshaded;" here

void fragment() {
    vec4 base_color = COLOR; // This gets the ColorRect's green
    // Tiny grain effect
    float noise = fract(sin(dot(FRAGCOORD.xy, vec2(12.9898, 78.233))) * 43758.5453);
    COLOR = vec4(base_color.rgb - (noise * 0.05), base_color.a);
}