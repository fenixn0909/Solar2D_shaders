
--[[
  Origin Author: Fernando Kuteken
  https://gl-transitions.com/editor/angular
  License: MIT
  
  

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "angular"

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
#define PI 3.141592653589

uniform float startingAngle = 90;

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 uv = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime*1));
  //progress = 0;
  //----------------------------------------------

  float offset = -startingAngle * PI / 180.0; // Minus: From -90 in Solar2D
  float angle = atan(uv.y - 0.5, uv.x - 0.5) + offset;
  float normalizedAngle = (angle + PI) / (2.0 * PI);
  
  normalizedAngle = normalizedAngle - floor(normalizedAngle);
  /*
  return mix(
    getFromColor(uv),
    getToColor(uv),
    step(normalizedAngle, progress)
    );
  */
  //----------------------------------------------

  vec4 cFrom = texture2D( CoronaSampler0, uv);
  vec4 cTo = colorBG;
  COLOR = mix( cFrom, cTo, step(normalizedAngle, progress ));
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


