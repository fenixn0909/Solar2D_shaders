
--[[
    https://godotshaders.com/shader/analog-monitor/
    cyanone
    November 15, 2023
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "blur"
kernel.name = "monitorAM" -- Analog Monochrome Monitor

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = 'intensity',
    default = 0.0,
    min = 0,
    max = 10,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  
}


kernel.fragment =
[[

//uniform sampler2D tiledtexture: repeat_enable, filter_linear_mipmap;    // texture to be used as "pixels"
//uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;   // grab the camera's view

uniform float opacity = 0.5 ; //: hint_range(0.0, 1.0)  // how much of the tiled texture to show (1 recommended) 
uniform float pixel_size = 0.01;    // size of pixelation effect
uniform bool greyscale = false;  // whether to greyscale the image or not before applying tiletexture
uniform float contrast = 0.5;     // whether to greyscale the image or not before applying tiletexture
uniform vec3 pixel_colors = vec3( 0.0, 1.0, 0.0 );   // the overriding color of the tiled texture, white by default
uniform vec3 background_color = vec3( 0.2, 0.7, 0.7 ); // : source_color;   // the overriding color of the background, black by default

//----------------------------------------------

// Convert to Greyscale using luminosity method if aplicable
vec4 to_grayscale(vec4 color) {
    float luminance = 0.21 * color.r + 0.72 * color.g + 0.07 * color.b;
    return vec4(luminance, luminance, luminance, color.a);
}

// Adjust contrast of the greyscale image
vec4 adjust_contrast(vec4 color) {
    color.rgb = (color.rgb - 0.5) * max(contrast, 0.0) + 0.5;
    return color;
}

// Applies the tiled texture on top of the original texture imitating 
// photoshop's HARD MIX blending mode
vec4 hard_mix(vec4 color1, vec4 color2) {
    vec4 result; // The resulting texture
    for (int i = 0; i < 4; i++) { // loop through the four channels
        float value = color1[i] + color2[i]; // add the values of the two colors
        if (value >= 1.0) { // if the value is greater than or equal to 1.0, set it to 1.0
            result[i] = 1.0;
        } else { // otherwise, set it to 0.0
            result[i] = 0.0;
        }
    }
    return result; // return the result color
}

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //P_UV vec2 SCREEN_UV = gl_FragCoord.xy * CoronaTexelSize.zw;
    P_UV vec2 SCREEN_UV = UV;

    //----------------------------------------------

    vec2 uv = SCREEN_UV;
    vec2 uv2 = SCREEN_UV;
    
    // apply pixelation on the base texture
    uv = floor(uv / pixel_size) * pixel_size;
    vec4 color1 = texture2D( CoronaSampler0, uv );
    float alpha = color1.a;

    // apply greyscale adjustments if applicable
    if (greyscale) {
        color1 = to_grayscale(color1);
        color1 = adjust_contrast(color1);
    }
    
    // apply hard mix blending
    vec4 color2 = texture2D( CoronaSampler1, uv2 / pixel_size );
    vec4 final_result = mix(color1, hard_mix(color1, color2), opacity);
    
    // replace default white with desired color
    if (final_result == vec4(1.0, 1.0, 1.0, 1.0)) {
        final_result = vec4(pixel_colors, 1.0);
        // replace default black background with desired color
    } else {
        if (final_result == vec4(0.0, 0.0, 0.0, 1.0)) {
            final_result = vec4(background_color, 1.0);
        }
    }
    
    // assign final texture
    COLOR = final_result;
    //----------------------------------------------
    
    // Restrict to texture alpha
    COLOR.a = alpha;
    COLOR.rgb *= COLOR.a;


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


