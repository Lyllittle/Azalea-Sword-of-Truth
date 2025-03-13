shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.5, 1.0, 1.0);
uniform vec4 electric_color : source_color = vec4(0.2, 0.8, 1.0, 1.0);
uniform float pulse_speed : hint_range(0.1, 5.0) = 1.5;
uniform float outline_width : hint_range(0.0, 0.5) = 0.04;
uniform float radius : hint_range(0.1, 1.0) = 0.35;

// Noise parameters
uniform int noise_layers : hint_range(1, 5) = 2;
uniform float noise_speed : hint_range(0.1, 5.0) = 2.0;
uniform float noise_density : hint_range(0.0, 20.0) = 12.0;
uniform float electric_power : hint_range(0.0, 10.0) = 5.0;

float random(float x) {
    return fract(sin(x) * 43758.5453);
}

float noise1D(float x) {
    float i = floor(x);
    float f = fract(x);
    return mix(random(i), random(i + 1.0), smoothstep(0.0, 1.0, f));
}

void fragment() {
    vec2 uv = (UV - 0.5) * 2.0;
    float dist = length(uv);
    vec4 final_color = vec4(0.0);
    
    // Pulsating outline setup
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
    float animated_width = outline_width * (0.8 + pulse * 0.3);
    float outer = radius;
    float inner = radius - animated_width;
    
    // Outline calculation
    float outline = smoothstep(inner - 0.01, inner, dist) 
                  - smoothstep(outer, outer + 0.01, dist);
    outline *= 1.5;

    // Shared noise properties
    float angle = atan(uv.y, uv.x);
    float pattern = 0.0;
    
    // Interior noise (inside the ring)
    if (dist < inner) {
        float radial_fade = pow(1.0 - smoothstep(0.0, inner, dist), 2.0);
        for(int i = 0; i < noise_layers; i++) {
            float layer = float(i) + 1.0;
            float speed = noise_speed * (0.8 + layer * 0.7);
            float time_offset = TIME * speed;
            
            float n = noise1D(angle * noise_density * layer + time_offset);
            float ring_wave = sin(dist * 20.0 * layer - time_offset * 2.0);
            pattern += smoothstep(0.4, 0.6, abs(n - ring_wave)) * radial_fade;
        }
    }
    
    // Exterior noise (outside the ring)
    if (dist > outer) {
        float radial_fade = 1.0 - smoothstep(outer, outer + 0.2, dist);
        for(int i = 0; i < noise_layers; i++) {
            float layer = float(i) + 1.0;
            float speed = noise_speed * (1.2 + layer * 0.5);
            float time_offset = TIME * speed * -1.0; // Reverse direction
            
            float n = noise1D(angle * noise_density * layer * 0.8 + time_offset);
            float ring_wave = cos(dist * 15.0 * layer + time_offset);
            pattern += smoothstep(0.3, 0.7, abs(n - ring_wave)) * radial_fade;
        }
    }

    // Combine effects
    float electric = clamp(pow(pattern * 2.5, 3.0) * electric_power, 0.0, 2.0);
    final_color = mix(outline_color, electric_color, electric * 0.8) * (outline + electric);
    final_color.a = clamp(outline + electric, 0.0, 1.0);
    
    COLOR = final_color;
}