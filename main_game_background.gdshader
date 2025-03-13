shader_type canvas_item;

uniform vec4 color1 : source_color = vec4(0.2, 0.3, 0.8, 1.0);
uniform vec4 color2 : source_color = vec4(0.8, 0.2, 0.3, 1.0);
uniform vec4 star_color : source_color = vec4(1.0, 0.98, 0.9, 1.0);
uniform vec2 mouse_pos = vec2(0.5, 0.5);
uniform float speed = 1.0;
uniform float scale = 10.0;
uniform float star_density = 0.15; // [0, 1]
uniform float star_twinkle_speed = 2.0;

float hash(float n) { 
	return fract(sin(n) * 1e4); 
	}
float hash(vec2 p) { 
	return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); 
	}

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

#define NUM_OCTAVES 5

float fbm(vec2 x) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100);
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)), vec2(-sin(0.5), cos(0.50)));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

float random_star(vec2 uv) {
    vec2 grid = floor(uv * 200.0); // Higher number = more stars
    vec2 borders = fract(uv * 200.0);
    
    float star = 0.0;
    float star_value = hash(grid);
    
    if (star_value > star_density) return 0.0;
    
    vec2 center = (grid + 0.5) / 200.0;
    float dist = distance(uv, center);
    float size = mix(0.001, 0.003, hash(grid.x));
    
    // Create twinkle effect with time
    float twinkle = (sin(TIME * star_twinkle_speed + grid.x * 10.0) * 0.5 + 0.5) * 0.5 + 0.5;
    size *= twinkle;
    
    star = smoothstep(size, 0.0, dist);
    star *= smoothstep(0.0, size * 0.5, dist);
    
    return star * mix(0.8, 1.2, hash(grid.y));
}

void fragment() {
    vec2 uv = FRAGCOORD.xy * SCREEN_PIXEL_SIZE;
    
    // Mouse interaction with stronger effect
    vec2 mouse_offset = (mouse_pos - vec2(0.5)) * 0.7;
    uv += mouse_offset;
    
    // Create pulsing scale effect
    float pulse = sin(TIME * 0.5) * 0.1 + 1.0;
    float current_scale = scale * pulse;
    
    float t = TIME * speed;
    float n1 = fbm(uv * current_scale + t);
    float n2 = fbm(uv * (current_scale * 1.5) - t);
    
    // Add third color layer
    float n3 = fbm(uv * (current_scale * 0.5) + t * 0.5);
    float n = mix(mix(n1, n2, 0.5), n3, 0.3);
    
    // Color variation
    vec3 base_color = mix(color1.rgb, color2.rgb, smoothstep(0.3, 0.7, n));
    
    // Add radial gradient from mouse position
    float mouse_dist = distance(uv, mouse_pos);
    vec3 mouse_glow = vec3(0.5, 0.6, 1.0) * (1.0 - smoothstep(0.2, 0.5, mouse_dist));
    
    // Generate stars
    float stars = random_star(uv);
    stars += random_star(uv * 1.5); // Layer of smaller stars
    
    // Combine elements
    vec3 final_color = base_color + mouse_glow;
    final_color = mix(final_color, star_color.rgb, stars);
    
    // Add vignette effect
    float vignette = 1.0 - length(uv - 0.5) * 1.5;
    vignette = smoothstep(0.0, 0.8, vignette);
    
    COLOR.rgb = final_color * vignette;
    COLOR.a = 1.0;
}