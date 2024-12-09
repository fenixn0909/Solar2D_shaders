
--[[
  Origin Author: mandubian
  https://github.com/gl-transitions/gl-transitions/blob/master/transitions/CrazyParametricFun.glsl
  License: MIT


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "crazyParametric"

--Test
-- kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = 1,
    min = 0,
    max = 1,
    index = 0, 
  },
}


kernel.fragment =
[[
P_DEFAULT float progress = CoronaVertexUserData.x;
vec4 colorBG = vec4(0,0,0,0);
float ratio = CoronaVertexUserData.x;
//----------------------------------------------

uniform float a = 4;
uniform float b = 1;
uniform float amplitude = 120;
uniform float smoothness = 0.1;

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime*1));
  //progress = 0;
  //----------------------------------------------

  vec2 p = UV.xy / vec2(1.0).xy;
  vec2 dir = p - vec2(.5);
  float dist = length(dir);
  float x = (a - b) * cos(progress) + b * cos(progress * ((a / b) - 1.) );
  float y = (a - b) * sin(progress) - b * sin(progress * ((a / b) - 1.));
  vec2 offset = dir * vec2(sin(progress  * dist * amplitude * x), sin(progress * dist * amplitude * y)) / smoothness;
  //return mix(getFromColor(p + offset), getToColor(p), smoothstep(0.2, 1.0, progress));
  
  COLOR = mix( texture2D( CoronaSampler0, p + offset ), colorBG, progress);

  //----------------------------------------------

  
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


