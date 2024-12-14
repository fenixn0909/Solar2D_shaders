
--[[
  Origin Author: gre
  https://gl-transitions.com/editor/ripple
  License: MIT
  
  

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "ripple"

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
uniform float amplitude= 100.0;
uniform float speed= 50.0;


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime*1));
  //progress = 0;
  //----------------------------------------------

  vec2 dir = UV - vec2(.5);
  float dist = length(dir);
  vec2 offset = dir * (sin(progress * dist * amplitude - progress * speed) + .5) / 30.;
  /*
  return mix(
    getFromColor(UV + offset),
    getToColor(UV),
    smoothstep(0.2, 1.0, progress)
  */
  //----------------------------------------------

  vec4 cFrom = texture2D( CoronaSampler0, UV + offset);
  vec4 cTo = colorBG;
  COLOR = mix( cFrom, cTo, smoothstep(0.2, 1.0, progress) );
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


