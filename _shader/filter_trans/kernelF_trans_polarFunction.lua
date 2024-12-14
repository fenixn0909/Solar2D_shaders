
--[[

  Origin Author: Fernando Kuteken
  https://gl-transitions.com/editor/polar_function
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "polarFunction"

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

#define PI 3.14159265359

uniform int segments = 24; //from 3 ~ 400, 24:adorable, 100:like sun


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 uv = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  float angle = -atan(uv.y - 0.5, uv.x - 0.5) - 0.5 * PI;
  float normalized = (angle + 1.5 * PI) * (2.0 * PI);
  
  float radius = (cos(float(segments) * angle) + 4.0) / 4.0;
  float difference = length(uv - vec2(0.5, 0.5));
  
  if (difference > radius * progress)
    //return getFromColor(uv);
    COLOR = texture2D( CoronaSampler0, uv);
  else
    //return getToColor(uv);
    COLOR = colorBG;


  //----------------------------------------------
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


