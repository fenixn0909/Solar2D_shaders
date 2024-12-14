
--[[
  Origin Author: gre
  https://gl-transitions.com/editor/randomsquares

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "randSquares"

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

uniform ivec2 size= ivec2(24, 24); // larger for pixel fade, ultra larger for noise
uniform float smoothness = 1; // fade, 0 = off
 
float rand (vec2 co) {
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV);
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------

  float r = rand(floor(vec2(size) * UV));
  float m = smoothstep(0.0, -smoothness, r - (progress * (1.0 + smoothness)));
  
  COLOR.a *= 1-m;
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


