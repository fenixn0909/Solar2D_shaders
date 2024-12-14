 
--[[
    https://godotshaders.com/shader/acceleration-effect/
    Kaizer297
    August 2, 2024


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "speedSilhouette"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "col_r",
    default = 0,
    min = 0,
    max = 1,
    index = 0, 
  },
  {
    name = "col_g",
    default = 0.53,
    min = 0,
    max = 1,
    index = 1, 
  },
  {
    name = "col_b",
    default = 0.75,
    min = 0,
    max = 1,
    index = 2, 
  },
  {
    name = "col_a",
    default = 0.5,
    min = 0,
    max = 1,
    index = 3, 
  },
}


kernel.fragment =
[[

float r = CoronaVertexUserData.x;
float g = CoronaVertexUserData.y;
float b = CoronaVertexUserData.z;
float opacity = CoronaVertexUserData.w;

vec3 Col_Sil = vec3( r, g, b);

uniform float Mix_Rate = 0.5;
//----------------------------------------------

uniform sampler2D TEXTURE;

//----------------------------------------------


// -----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    //----------------------------------------------

    vec4 texture_color = texture2D(TEXTURE, UV);
    COLOR = texture_color;
    if (texture_color.a != 0.0)
    COLOR = vec4(mix(texture_color.rgb, Col_Sil, Mix_Rate), opacity);

    //----------------------------------------------
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


