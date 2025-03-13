shader_type canvas_item;

uniform float blur_amount : hint_range(0, 10) = 1.0;

void fragment() {
    vec4 blurred_color = vec4(0.0);
    vec2 pixel_size = TEXTURE_PIXEL_SIZE * blur_amount;
    
    // Gaussian kernel for 3x3 blur (weights sum to 1)
    float kernel[9] = float[](
        1.0/16.0, 2.0/16.0, 1.0/16.0,
        2.0/16.0, 4.0/16.0, 2.0/16.0,
        1.0/16.0, 2.0/16.0, 1.0/16.0
    );
    
    int index = 0;
    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
			vec2 offset = vec2(float(x), float(y)) * pixel_size;
            blurred_color += texture(TEXTURE, UV + offset) * kernel[index];
            index++;
        }
    }
    
    COLOR = blurred_color;
}