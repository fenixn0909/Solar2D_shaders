
--[[

  Origin Author: Paweł Płóciennik
  https://gl-transitions.com/editor/WaterDrop
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "waterDrop"

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
uniform float amplitude = 75; //
uniform float speed = 20; // great either slower: 20 or faster: 50


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 p = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  vec2 dir = p - vec2(.5);
  float dist = length(dir);

  if (dist > progress) {
    //return mix(getFromColor( p ), getToColor( p ), progress);
    COLOR = mix( texture2D( CoronaSampler0,p), colorBG, progress);
  } else {
    vec2 offset = dir * sin(dist * amplitude - progress * speed);
    //return mix(getFromColor( p + offset), getToColor( p), progress);
    COLOR = mix( texture2D( CoronaSampler0, p + offset ), colorBG, progress);
  }

  //----------------------------------------------
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


