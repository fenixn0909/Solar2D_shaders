
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
    name = 'Intensity',
    default = 0.0,
    min = 0,
    max = 0.3,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  
}

kernel.vertexData =
{
    { name = "Speed",  default = 2.5, min = -15, max = 15, index = 0, },
    { name = "Range",  default = .3, min = -1, max = 1, index = 1, },
    { name = "Intensity",  default = .1, min = 0, max = .3, index = 2, },
    { name = "Tint_Amount",  default = .4, min = 0, max = 1, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x; 
float Range = CoronaVertexUserData.y; 
float Intensity = CoronaVertexUserData.z; 
float Tint_Amount = CoronaVertexUserData.w; 

vec4 tint_color = vec4(0.3, 0.7, 0.9, 1.0); //: source_color

//----------------------------------------------

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{


    //----------------------------------------------

    vec2 warp = texture2D( CoronaSampler1, UV ).xy - 0.5;
    warp.x += sin(TIME*Speed) * Range;
    warp.y += cos(TIME*Speed) * Range;
                             // get our normal warp
    vec4 screen = texture2D( CoronaSampler0, UV + warp * Intensity);                           // sample based on warp and Intensity and blur based on Intensity
    float alpha = screen.a;
    
    screen = mix(screen, tint_color, Tint_Amount);                          // tint our image
    float noise = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453);                          // get a random-ish value for some speckle noise
    float diff = max(dot(warp, normalize(vec2(1.0, 1.0))), 0.0);                            // light diffusion for glass shape highlights
    screen += diff * Intensity;                         // apply diffusion based on Intensity
    
    screen += noise * Intensity; // apply speckle noise based on Intensity
    
    COLOR = screen;     // yarp

    //----------------------------------------------
    COLOR.a = alpha;
    COLOR.rgb *= alpha;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


