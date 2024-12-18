
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
  { name = "Speed",         default = 6, min = 0, max = 50, index = 0, },
  { name = "RectWH",        default = 3, min = 0, max = 25, index = 1, },
  { name = "Glow_Max",      default = 4, min = -5, max = 50, index = 2, },
  { name = "Scale_FallOff", default = 3, min = 0.01, max = 5, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float RectWH = CoronaVertexUserData.y;
float Glow_Max = CoronaVertexUserData.z;
float Scale_FallOff = CoronaVertexUserData.w;

//----------------------------------------------


uniform float Brightness = 3.0;
//uniform float Scale_FallOff = 3.0; // The less the larger
uniform float b_offset = 0.0; 

vec2 Rect_Size = vec2( RectWH*0.01, RectWH*0.01 );

P_COLOR vec3 color = vec3(.1, .5, .3);


// -----------------------------------------------

P_COLOR vec4 COLOR;
  P_DEFAULT float TIME = CoronaTotalTime * Speed;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    //P_DEFAULT float alpha = abs(sin(CoronaTotalTime));
    P_DEFAULT float dt = abs(sin( TIME ));
    //----------------------------------------------

    vec2 uv = UV - vec2(.5);
    vec2 cloest_rect_point; 
    cloest_rect_point = uv; 
    cloest_rect_point.x = clamp(uv.x, -Rect_Size.x, Rect_Size.x);  
    cloest_rect_point.y = clamp(uv.y, -Rect_Size.y, Rect_Size.y);   
    vec2 cuv = uv - cloest_rect_point;
    float d2c = length(cuv);
    //COLOR.a = - log(d2c*Scale_FallOff + b_offset) * Brightness; 
    COLOR.a = - log(d2c*Scale_FallOff + b_offset) * Brightness * dt ; 
    //COLOR.a = - log(d2c*Scale_FallOff* dt + b_offset) * Brightness  ; 
    //COLOR.rgb = color;
    COLOR.rgb = color * min(COLOR.a, Glow_Max);
    //COLOR.rgb = color * ( 1/  min(COLOR.a, Glow_Max) );
    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    
--]]


