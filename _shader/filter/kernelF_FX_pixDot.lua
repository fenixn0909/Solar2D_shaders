--[[
  Origin Author: jijiji
  https://godotshaders.com/author/jijiji/

  from world of zero youtube: https://www.youtube.com/watch?v=RD9qvXO_Ha4

  and make pixelate align center.

--]]

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "pixDot"


kernel.vertexData =
{
  { name = "DotsX",        default = 64, min = 32, max = 128, index = 0, },
  { name = "DotsY",        default = 64, min = 32, max = 128, index = 1, },
  { name = "OffX",     default = .5, min = -1, max = 1, index = 2, },
  { name = "OffY",     default = .5, min = -1, max = 1, index = 3, },
} 


kernel.fragment = 
[[


//----------------------------------------------

float DotsX = CoronaVertexUserData.x;
float DotsY = CoronaVertexUserData.y;
float OffX = CoronaVertexUserData.z;
float OffY = CoronaVertexUserData.w;

vec2 DistUV = vec2( OffX, OffY );

//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    vec2 pos = UV;
    pos *= vec2(DotsX, DotsY);
    pos = ceil(pos);
    pos /= vec2(DotsX, DotsY);
    vec2 cellpos = pos - (0.5 / vec2(DotsX, DotsY));

    pos -= UV;
    pos *= vec2(DotsX, DotsY);
    pos = vec2(1.0) - pos;

    float dist = distance(pos, DistUV);

    vec4 c = texture2D(CoronaSampler0, cellpos);

    P_COLOR vec4 COLOR = c * step(0.0, (0.5* c.a) - dist);
    //----------------------------------------------
    COLOR.a = c.a;

    return CoronaColorScale(COLOR);
}
]]
return kernel
--[[



--]]