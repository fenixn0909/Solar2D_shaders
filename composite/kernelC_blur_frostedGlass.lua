
--[[
    https://godotshaders.com/shader/frosted-glass-2/
    fritzy
    July 28, 2024
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "blur"
kernel.name = "frostedGlass"

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

float intensity = CoronaVertexUserData.x; //: hint_range(0.0, 0.3)

//uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest_mipmap;  // mipmap is neaded for textureLod
//uniform sampler2D warp_texture: repeat_enable; // works better as a normal with warping
// warp_texture: CoronaSampler1 

//uniform float intensity = -.1; //: hint_range(0.0, 0.3)
//float intensity = -.1; //: hint_range(0.0, 0.3)
uniform vec4 tint_color = vec4(0.5, 0.6, 0.9, 0.0); //: source_color
uniform float tint_amount = 0.4; //: hint_range(0.0, 1.0)

//----------------------------------------------

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{


    //----------------------------------------------

    vec2 warp = texture2D( CoronaSampler1, UV ).xy - 0.5;                         // get our normal warp
    vec4 screen = texture2D( CoronaSampler0, UV + warp * intensity, intensity * 4.0);                           // sample based on warp and intensity and blur based on intensity
    float alpha = screen.a;
    //vec4 screen = textureLod(screen_texture, UV + warp * intensity, intensity * 4.0);                           // sample based on warp and intensity and blur based on intensity
    
    screen = mix(screen, tint_color, tint_amount);                          // tint our image
    float noise = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453);                          // get a random-ish value for some speckle noise
    float diff = max(dot(warp, normalize(vec2(1.0, 1.0))), 0.0);                            // light diffusion for glass shape highlights
    screen += diff * intensity;                         // apply diffusion based on intensity
    
    screen += noise * intensity; // apply speckle noise based on intensity
    
    COLOR = screen;     // yarp

    //----------------------------------------------
    COLOR.rgb *= alpha;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


