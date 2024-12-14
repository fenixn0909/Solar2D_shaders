
--[[
  Origin Author: Xaychru
  https://gl-transitions.com/editor/Radial
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "radial"

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

uniform float smoothness = 1.0; // 
const float PI = 3.141592653589;


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 p = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  vec2 rp = p*2.-1.;
  /*
  return mix(
    getToColor(p),
    getFromColor(p),
    smoothstep(0., smoothness, atan(rp.y,rp.x) - (progress-.5) * PI * 2.5)
  );
  */
  //----------------------------------------------
  vec4 texFrom = texture2D(CoronaSampler0, p);
  vec4 texTo = colorBG;
  float m = smoothstep(0., smoothness, atan(rp.y,rp.x) - (progress-.5) * PI * 2.5);
  
  COLOR = mix( texTo,texFrom, m );

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


