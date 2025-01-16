
--[[
  Origin Author: Bombardlos
  https://godotshaders.com/shader/palette-filter-and-pixelate-combined/

  This is just two shaders combined, resulting in the background in my pic.
   
  Here are the projects separately
   
  https://godotshaders.com/shader/palette-filter-for-3d-and-2d/
  https://godotshaders.com/shader/pixelate/
   
   
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "palettePx"
kernel.name = "filter"

kernel.isTimeDependent = true

kernel.vertexData =
{
    { name = "Speed",  default = .5, min = 0, max = 5, index = 0, },
    { name = "Amount",  default = 300, min = 0, max = 500, index = 1, },
    { name = "Flip_Color",  default = 1.5, min = -1, max = 2, index = 2, },
} 


kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
int Amount = int(CoronaVertexUserData.y * 1);
float Flip_Color = CoronaVertexUserData.z;

//----------------------------------------------

float TIME = CoronaTotalTime;
P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    float flip_color = mod(TIME*Speed, 1) * Flip_Color;
    float amount = TIME*Speed * float(Amount);
    //----------------------------------------------
    vec2 grid_uv = floor(UV * float(Amount) + 0.5) / float(Amount);

    vec4 col = texture2D(CoronaSampler0,grid_uv);
    float alpha = col.a;
    float lum = dot(col.rgb,vec3(0.2126,0.7152,0.0722)); // luminance

    //col = texture2D(CoronaSampler1,vec2(abs(Flip_Color - lum),0));
    col = texture2D(CoronaSampler1,vec2(abs(flip_color - lum),0));

    COLOR = col;
    COLOR.a = alpha;
    COLOR.rgb *= COLOR.a;
    //----------------------------------------------

    return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


