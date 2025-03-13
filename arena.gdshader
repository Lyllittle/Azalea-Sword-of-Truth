shader_type canvas_item;

// Rectangle controls
uniform float rect_position_x : hint_range(0.0, 1.0) = 0.1;
uniform float rect_position_y : hint_range(0.0, 1.0) = 0.1;
uniform float rect_size_x : hint_range(0.0, 1.0) = 0.8;
uniform float rect_size_y : hint_range(0.0, 1.0) = 0.8;
uniform float border_thickness : hint_range(0.0, 0.1) = 0.02;
uniform vec4 border_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

// Hex Grid controls
uniform float grid_scale : hint_range(1, 50) = 20.0;
uniform vec4 grid_color : source_color = vec4(0.3, 0.3, 0.3, 1.0);
uniform float grid_line_width : hint_range(0.001, 0.1) = 0.015;
uniform vec4 grid_bg_color : source_color = vec4(0.15, 0.15, 0.15, 1.0);

// Noise controls
uniform float noise_speed = 0.5;
uniform float noise_scale = 5.0;
uniform int octaves : hint_range(1, 6) = 3;
uniform float lacunarity : hint_range(1.0, 4.0) = 2.0;
uniform float gain : hint_range(0.0, 1.0) = 0.5;
uniform float noise_amount : hint_range(0, 1) = 0.2;

// Hexagonal grid functions
vec2 hex_coord(vec2 p) {
    const vec2 sz = vec2(1.0, 1.73205);
    vec2 h = sz * 0.5;
    vec2 a = mod(p, sz) - h;
    vec2 b = mod(p - h, sz) - h;
    return dot(a, a) < dot(b, b) ? a : b;
}

float hex_grid(vec2 uv, float scale) {
    uv *= scale;
    vec2 hc = hex_coord(uv);
    return smoothstep(
        0.5 * (1.0 - grid_line_width * scale),
        0.5 * (1.0 + grid_line_width * scale),
        length(hc)
    );
}

// FBM Noise functions
float hash(float p) { return fract(sin(p * 127.1) * 43758.5453); }

float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    float u = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), u);
}

float fbm(float x, float scale) {
    float total = 0.0, amplitude = 0.5, frequency = scale;
    for(int i = 0; i < octaves; i++) {
        total += noise(x * frequency) * amplitude;
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return total;
}

void fragment() {
    vec2 uv = UV;
    
    // Calculate hex grid background
    float grid = hex_grid(uv, grid_scale);
    vec4 bg_color = mix(grid_bg_color, grid_color, grid);
    
    // Rectangle calculations
    vec2 rect_min = vec2(rect_position_x, rect_position_y);
    vec2 rect_size = vec2(rect_size_x, rect_size_y);
    vec2 rect_max = rect_min + rect_size;
    vec2 edge_dist = min(uv - rect_min, rect_max - uv);
    float min_dist = min(edge_dist.x, edge_dist.y);

    // Perimeter position calculation
    vec2 rel_pos = (uv - rect_min)/rect_size;
    float perimeter_pos = 0.0;
    
    if(edge_dist.x < edge_dist.y) {
        if(uv.x < rect_min.x + border_thickness) {
            perimeter_pos = rel_pos.y;
        } else {
            perimeter_pos = 1.0 + rect_size.y + (1.0 - rel_pos.y);
        }
    } else {
        if(uv.y < rect_min.y + border_thickness) {
            perimeter_pos = 2.0 + rect_size.y + rel_pos.x;
        } else {
            perimeter_pos = 3.0 + rect_size.y + rect_size.x + (1.0 - rel_pos.x);
        }
    }

    // Animated noise calculation
    float noise_value = fbm(perimeter_pos * noise_scale + TIME * noise_speed, noise_scale);
    float thickness_mod = 1.0 + noise_amount * (noise_value * 2.0 - 1.0);
    float dynamic_thickness = border_thickness * thickness_mod;

    // Border calculation
    float border = smoothstep(
        dynamic_thickness * 0.95,
        dynamic_thickness * 1.05,
        abs(min_dist)
    );

    // Combine elements
    COLOR = mix(bg_color, border_color, 1.0 - border);
}