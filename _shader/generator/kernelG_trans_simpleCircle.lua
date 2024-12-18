
--[[
    Origin Author: agurkas
    https://godotshaders.com/author/agurkas/
  


    #VARIATION Find the tag and tweak them for different patterns

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "simpleCircle"

-- kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Progress",     default = .5, min = 0, max = 1, index = 0, },
  { name = "Speed",        default = 3, min = 0, max = 20, index = 1, },
  { name = "CircleW",      default = 4, min = -90, max = 90, index = 2, },
  { name = "CircleH",      default = 4, min = -90, max = 90, index = 3, },
} 

kernel.fragment =
[[

float Progress = CoronaVertexUserData.x;
float Speed = CoronaVertexUserData.y;
float CircleW = CoronaVertexUserData.z;
float CircleH = CoronaVertexUserData.w;
//----------------------------------------------

P_COLOR vec4 Col_Fill = vec4( 1.0, 0.0, 0.0, 1.0);

//----------------------------------------------

P_COLOR vec4 COLOR = Col_Fill;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    float progress = Progress * Speed; 
    //----------------------------------------------
    float ratio = CircleW / CircleH;
    
    // #VARIATION Shape: Circle, Eye 
    //float dist = distance(vec2(0.5, 0.5), vec2(mix(0.5, UV.x, ratio), UV.y));
    
    // #VARIATION Shape: Tilted, Slanting, Oblique 
    float dist = distance( vec2( mix(0.5, UV.x, 1),UV.x), vec2( mix(0.5, UV.y, ratio),UV.x) );
    
    //float dist = distance(vec2(0.5, 0.5), vec2(mix( 0.5, UV.x, ratio), vec2(mix( .5, UV.y, ratio)) );
    
    // #VARIATION Color: Solid
    //COLOR.a = step(progress, dist);
    
    // #VARIATION Color: Smooth Border
    COLOR.a = smoothstep(0, progress, dist);
    COLOR.rgb *= COLOR.a;

    //----------------------------------------------
    return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


