
--[[
  Origin Author: gre
  https://gl-transitions.com/editor/flyeye
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "flyeye"

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

uniform float size = 0.04;
uniform float zoom = 50.0;
uniform float colorSeparation = 0.3;



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;

  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------

  float inv = 1. - progress;
  vec2 disp = size*vec2(cos(zoom*UV.x), sin(zoom*UV.y));
  //vec4 texTo = getToColor(UV + inv*disp);
  
  vec4 texFrom = vec4(
    texture2D(CoronaSampler0, UV + progress*disp*(1.0 - colorSeparation)).r,
    texture2D(CoronaSampler0, UV + progress*disp).g,
    texture2D(CoronaSampler0, UV + progress*disp*(1.0 + colorSeparation)).b,
    texture2D(CoronaSampler0, UV).a 
    //texture2D(CoronaSampler0, UV + progress*disp) 
    //1.0
    );
    
  //return texTo*progress + texFrom*inv;
  vec4 texTo = colorBG;
  COLOR = texTo * progress + texFrom * inv;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


