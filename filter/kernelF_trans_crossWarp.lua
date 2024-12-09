
--[[
  Origin Author: Eke Péter <peterekepeter@gmail.com>
  https://gl-transitions.com/editor/crosswarp
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "crossWarp"

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

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  float x = progress;
  x=smoothstep(.0,1.0,(x*2.0+UV.x-1.0));
  //return mix(getFromColor((UV-.5)*(1.-x)+.5), getToColor((UV-.5)*x+.5), x);

  COLOR = mix( texture2D(CoronaSampler0,(UV-.5)*(1.-x)+.5), colorBG, x);

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


