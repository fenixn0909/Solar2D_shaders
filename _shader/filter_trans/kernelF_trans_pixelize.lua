
--[[
  Origin Author: gre
  https://gl-transitions.com/editor/pixelize
  License: MIT
  forked from https://gist.github.com/benraziel/c528607361d90a072e98

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "pixelize"

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

uniform ivec2 squaresMin= ivec2(20) ; // minimum number of squares (when the effect is at its higher level)
uniform int steps  = 50; // zero disable the stepping

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  //progress = sin(CoronaTotalTime);
  //----------------------------------------------

  float d = min(progress, 1.0 - progress);
  //float d = clamp(progress, 0, 1);
  float dist = steps>0 ? ceil(d * float(steps)) / float(steps) : d;
  vec2 squareSize = 2.0 * dist / vec2(squaresMin);
  
  vec2 p = dist>0.0 ? (floor(UV / squareSize) + 0.5) * squareSize : UV;

  COLOR = texture2D( CoronaSampler0, p);
  COLOR.a *= clamp( 1-progress, 0, 1);
  COLOR.rgb *= clamp( COLOR.a, 0, 1);

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


