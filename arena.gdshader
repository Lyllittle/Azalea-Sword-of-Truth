shader_type canvas_item;

uniform vec3 outline_color : source_color = vec3(0.25, 0.45, 0.9); // Blue color
uniform float edge_sharpness = 1.0; // Adjust transition smoothness (1.0 = default)

void fragment() {
    // Get original tile color
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate luminance (how "white" the pixel is)
    float luminance = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    
    // Create smooth transition between outline and center
    float alpha = 1.0 - smoothstep(0.0, edge_sharpness, luminance);
    
    // Apply final color with gradient transparency
    COLOR = vec4(outline_color, alpha * tex_color.a);
}