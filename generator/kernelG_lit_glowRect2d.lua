
--[[
    https://godotshaders.com/shader/glowing-rect-2d/
    Grandpa_Pit
    July 23, 2024
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "lit"
kernel.name = "glowRect2d"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "resolutionX",
    default = 1,
    min = 1,
    max = 99,
    index = 0, 
  },
  {
    name = "resolutionY",
    default = 1,
    min = 1,
    max = 99,
    index = 1, 
  },
}


kernel.fragment =
[[


P_DEFAULT float resolutionX = CoronaVertexUserData.x;
P_DEFAULT float resolutionY = CoronaVertexUserData.y;
P_UV vec2 iResolution = vec2(resolutionX,resolutionY);
//----------------------------------------------

//render_mode blend_add;

P_COLOR vec3 color = vec3(.1, .5, .3);
P_DEFAULT float max_glow = 4.0;

uniform vec2 rect_size = vec2(.051, .051);
uniform float bness = 1.0;
uniform float fall_off_scale = 3.0; // The less the larger
uniform float b_offset = 0.0; 

// -----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    P_COLOR vec4 COLOR;
    P_DEFAULT float TIME = CoronaTotalTime;
    //P_DEFAULT float alpha = abs(sin(CoronaTotalTime));
    P_DEFAULT float dt = abs(sin(CoronaTotalTime));
    //----------------------------------------------

    vec2 uv = UV - vec2(.5);
    vec2 cloest_rect_point; 
    cloest_rect_point = uv; 
    cloest_rect_point.x = clamp(uv.x, -rect_size.x, rect_size.x);  
    cloest_rect_point.y = clamp(uv.y, -rect_size.y, rect_size.y);   
    vec2 cuv = uv - cloest_rect_point;
    float d2c = length(cuv);
    //COLOR.a = - log(d2c*fall_off_scale + b_offset) * bness; 
    COLOR.a = - log(d2c*fall_off_scale + b_offset) * bness * dt ; 
    //COLOR.a = - log(d2c*fall_off_scale* dt + b_offset) * bness  ; 
    //COLOR.rgb = color;
    COLOR.rgb = color * min(COLOR.a, max_glow);
    //COLOR.rgb = color * ( 1/  min(COLOR.a, max_glow) );
    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    
    void fragment() {
    
    }
--]]


