shader_type canvas_item;

uniform vec4 color1 : source_color = vec4(0.2, 0.3, 0.8, 1.0);
uniform vec4 color2 : source_color = vec4(0.8, 0.2, 0.3, 1.0);
uniform vec4 color3 : source_color = vec4(0.8, 0.2, 0.3, 1.0);
uniform vec4 color4 : source_color = vec4(0.8, 0.2, 0.3, 1.0);
uniform float pixel_size = 0.02;
uniform vec2 mouse_pos = vec2(0.5, 0.5); // normalized [0,1] mouse position; update this from script.
uniform float speed = 1.0;
uniform float scale = 5.0;

float hash(float n) { return fract(sin(n) * 1e4); }
float hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

float noise(vec2 x) {
	vec2 i = floor(x);
	vec2 f = fract(x);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion (fbm) for more fluid noise

#define NUM_OCTAVES 5

float fbm(vec2 x) {
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100);
	// Rotate to reduce axial bias
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)), vec2(-sin(0.5), cos(0.50)));
	for (int i = 0; i < NUM_OCTAVES; ++i) {
		v += a * noise(x);
		x = rot * x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}


void fragment() {
    // Normalize fragment coordinates
    vec2 uv = FRAGCOORD.xy * SCREEN_PIXEL_SIZE;

    // Modify UVs based on mouse position (assuming mouse_pos is normalized [0,1])
    uv += (mouse_pos - vec2(0.5)) * 0.5;

    // **Adjust for aspect ratio to ensure square pixels**
    vec2 pixel_grid = vec2(pixel_size, pixel_size * (SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x));

    // Quantize UVs to create a pixelation effect
    uv = floor(uv / pixel_grid) * pixel_grid;

    // Time factor
    float t = TIME * speed;

    // Create two layers of noise, one moving forward in time and one backwards
    float n1 = fbm(uv * scale + t);
    float n2 = fbm(uv * (scale * 1.5) - t);

    float n = mix(n1, n2, 0.5);

	if (n < 0.40) {
        COLOR = color1; // First color for lowest noise values
    } else if (n < 0.45) {
        COLOR = color2; // Second color for mid-low noise values
    } else if (n < 0.50) {
        COLOR = color3; // Third color for mid-high noise values
    } else {
        COLOR = color4; // Fourth color for highest noise values
    }
}
