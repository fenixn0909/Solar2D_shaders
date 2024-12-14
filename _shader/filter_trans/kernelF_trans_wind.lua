
--[[
  Origin Author: gre
  https://gl-transitions.com/editor/wind

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "wind"

--Test
-- kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = .5,
    min = 0,
    max = 1,
    index = 0, 
  },
}


kernel.fragment =
[[
P_DEFAULT float progress = CoronaVertexUserData.x;
vec4 colorBG = vec4(0,0,0,0);
//----------------------------------------------

uniform float size = 0.05; // = 0.02

float rand (vec2 co) {
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV);
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------

  float r = rand(vec2(0, UV.y));
  float m = smoothstep(0.0, -size, UV.x*(1.0-size) + size*r - (1-progress * (1.0 + size)));
  
  COLOR.a *= m;
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


