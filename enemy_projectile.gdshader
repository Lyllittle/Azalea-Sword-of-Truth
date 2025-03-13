shader_type canvas_item;

uniform float base_radius : hint_range(0.0, 1.0) = 0.3;
uniform float noise_amplitude : hint_range(0.0, 0.5) = 0.05;
uniform float noise_frequency : hint_range(0.1, 10.0) = 5.0;
uniform float speed : hint_range(0.0, 10.0) = 1.0;
uniform float outline_thickness : hint_range(0.0, 0.7) = 0.02;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform int layers : hint_range(1, 10) = 3;
uniform float layer_spread : hint_range(0.0, 0.5) = 0.02;
// New energy core uniforms
uniform vec4 core_color : source_color = vec4(0.5, 0.8, 1.0, 1.0);
uniform float core_intensity : hint_range(0.0, 5.0) = 1.5;
uniform float core_radius : hint_range(0.0, 0.5) = 0.15;
uniform float core_pulse_speed : hint_range(0.0, 5.0) = 1.0;
uniform float core_turbulence : hint_range(0.0, 1.0) = 0.2;

float hash(float seed) {
    return fract(sin(seed) * 43758.5453);
}

float generate_noise(float position, float seed) {
    float noise = sin(position * 1.0 + seed) * 0.5;
    noise += sin(position * 2.3 + seed * 2.0) * 0.25;
    noise += sin(position * 4.7 + seed * 3.0) * 0.125;
    noise += sin(position * 8.2 + seed * 4.0) * 0.0625;
    noise += sin(position * 0.7 + TIME * 2.0 + seed) * 0.3;
    return noise;
}

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    float angle = atan(uv.y, uv.x);
    
    vec4 final_color = vec4(0.0);
    
    // Calculate energy core first
    float pulse = sin(TIME * core_pulse_speed) * 0.5 + 0.5;
    float turbulent_angle = angle + TIME * 0.5;
    float core_noise = sin(turbulent_angle * 8.0 + TIME * 2.0) * core_turbulence;
    
    // Core radial gradient with pulsation
    float core_strength = smoothstep(core_radius * 1.5, 0.0, dist + core_noise);
    vec4 energy_core = core_color * core_strength * core_intensity * (1.0 + pulse * 0.5);
    
    // Inner glow effect
    float glow_falloff = 1.0 - smoothstep(0.0, core_radius * 2.0, dist);
    energy_core += core_color * glow_falloff * glow_falloff * 0.5;
    
    // Draw multiple outline layers
    for(int i = 0; i < layers; i++) {
        float layer_seed = float(i) * 10.0;
        float layer_rotation = hash(layer_seed + 0.5) * 6.28318530718;
        float layer_freq = noise_frequency * (1.0 + hash(layer_seed + 1.0) * 0.5);
        float layer_speed = speed * (1.0 + hash(layer_seed + 2.0) * 0.3);
        float layer_amp = noise_amplitude * (1.0 + hash(layer_seed + 3.0) * 0.2);
        float layer_radius = base_radius + float(i) * layer_spread;
        
        float noise_position = (angle + layer_rotation) * layer_freq + TIME * layer_speed;
        float noise = generate_noise(noise_position, layer_seed);
        float radius = layer_radius + noise * layer_amp;
        
        float outline = smoothstep(radius + outline_thickness/2.0, 
                                 radius - outline_thickness/2.0, 
                                 dist);
        outline *= 1.0 - smoothstep(radius - outline_thickness/2.0, 
                                  radius - outline_thickness/2.0 - 0.001, 
                                  dist);
        
        final_color += outline_color * outline * (1.0/float(layers));
    }
    
    // Combine core energy with outlines using additive blending
    COLOR = energy_core + final_color * (1.0 + pulse * 0.2);
    // Add final bloom effect
    COLOR *= 1.0 + length(COLOR.rgb) * 0.5;
}