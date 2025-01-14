
--[[
    https://godotshaders.com/shader/frosty-rotative-deformation/
    CasualGarageCoder
    December 6, 2022


    
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "deform"
kernel.name = "frostyRotation" 

kernel.isTimeDependent = true

kernel.textureWrap = 'repeat'




kernel.vertexData =
{
  { name = "Speed",     default = 1, min = 0, max = 10, index = 0, },
  { name = "Dist_Rate",  default =  2, min = 0.01, max = 10, index = 1, },
  { name = "Coord_Off",    default = .7, min = -1, max = 1, index = 2, },
  { name = "Dist_Off",    default = .5, min = -1, max = 1, index = 3, },
} 


kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Dist_Rate = CoronaVertexUserData.y;
float Coord_Off = CoronaVertexUserData.z;
float Dist_Off = CoronaVertexUserData.w;  

uniform sampler2D TEXTURE;

//----------------------------------------------

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime * 100; // * speed

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    float dist_rate = Dist_Rate * 0.0001;
    //----------------------------------------------

    float angle = TIME * Speed;
    vec2 dist = Dist_Off - UV;
    float s = sin(angle);
    float c = cos(angle);
    mat2 m = mat2(vec2(c, -s), vec2(s, c));
    dist *= m;
    vec4 coord = texture2D(CoronaSampler1, dist * dist_rate);
    coord.x -= Coord_Off;
    coord.y -= Coord_Off;

    vec4 lens_color = texture2D(TEXTURE, UV + coord.xy );
    vec4 col_tex = texture2D(TEXTURE, UV);
    COLOR = lens_color;

    //----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


