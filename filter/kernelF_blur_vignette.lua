

--[[
    Blur Vignette (Post Processing / ColorRect) [Godot 4.2.1]
    https://godotshaders.com/shader/blur-vignette-post-processing-colorrect-godot-4-2-1/
    paitorocxon
    December 29, 2023
--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "blur"
kernel.name = "vignette"

kernel.isTimeDependent = true

-- Expose effect parameters using vertex data
kernel.vertexData   = {
  {
    name = "intensity",
    default = 0.65, 
    min = 0,
    max = 1,
    index = 0,  -- This corresponds to "CoronaVertexUserData.x"
  },
  
}

kernel.fragment =
[[

//----------------------------------------------

uniform sampler2D screen_texture; //: hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float blur_radius = 0.3; // : hint_range(0, 1) ; // Radius of the blur effect
uniform float blur_amount = 5.0; // : hint_range(0, 5) ; // Strength of the blur effect
uniform float blur_inner = 0.7; // : hint_range(0, 1) ; // Inner edge of the blur effect
uniform float blur_outer = 0.8; // : hint_range(0, 1) ; // Outer edge of the blur effect

P_COLOR vec4 Col_Base = vec4( 2.0, 7.0, 8.0, 1.0);

//----------------------------------------------

P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    P_UV vec2 SCREEN_UV = gl_FragCoord.xy * CoronaTexelSize.zw;
    //----------------------------------------------
    
    vec4 pixelColor = texture2D(screen_texture, UV);      // Original color of the pixel from the screen
    
    //vec4 blurColor = textureLod(screen_texture, SCREEN_UV, blur_amount);        // Color with blur effect from the screen
    //vec4 blurColor = texture2D(screen_texture, SCREEN_UV, blur_amount);        // Color with blur effect from the screen
    vec4 blurColor = texture2D(screen_texture, UV, blur_amount);        // Color with blur effect from the screen

    float distance = length(UV - vec2(0.5, 0.5));       // Calculate distance from the center of the screen

    float blur = smoothstep(blur_inner - blur_radius, blur_outer, distance);        // Apply smoothstep function to control transition between areas

    //pixelColor.rgb = mix(blurColor.rgb, COLOR.rgb, -blur);      // Mix colors of the blur effect and the original color based on the smoothstep value
    pixelColor.rgb = mix(blurColor.rgb, Col_Base.rgb, -blur);      // Mix colors of the blur effect and the original color based on the smoothstep value

    blurColor.a = blur;         // Set the alpha component of the blur effect to the smoothstep value
    blurColor.a += pixelColor.a;

    blurColor.rgb = mix(blurColor.rgb, vec3(1.0), 0.1);         // Mix colors of the blur effect with white for an additional effect
    //blurColor.rgb = mix(blurColor.rgb, pixelColor.rgb, .1);         // Mix colors of the blur effect with white for an additional effect

    //COLOR = pixelColor;      // Set the final color to the modified color of the blur effect
    COLOR = blurColor;      // Set the final color to the modified color of the blur effect
    //----------------------------------------------
    
    //COLOR.rgb *= COLOR.a;
    //COLOR.rgb *= pixelColor.rgb;

    return CoronaColorScale( COLOR );
}
]]

return kernel