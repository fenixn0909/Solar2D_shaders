
--[[
  Origin Author: gre
  https://gl-transitions.com/editor/windowslice
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "windowSlice"

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
//----------------------------------------------
uniform float count = 200.0;
uniform float smoothness = 0.5;

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 p = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  float pr = smoothstep(-smoothness, 0.0, p.x - progress * (1.0 + smoothness));
  float s = step(pr, fract(count * p.x));
  //return mix(getFromColor(p), getToColor(p), s);
  
  //----------------------------------------------
  P_COLOR vec4 cFrom = texture2D(CoronaSampler0,p);
  P_COLOR vec4 cTo = colorBG;
  COLOR = mix( cFrom, cTo, s) ;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


