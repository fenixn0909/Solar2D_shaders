
--[[
  Origin Author: gre
  https://gl-transitions.com/editor/circleopen
  License: MIT
  
  

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "circleOpen"

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
uniform float smoothness = 0.3;
uniform bool opening = true;

const vec2 center = vec2(0.5, 0.5);
const float SQRT_2 = 1.414213562373;


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 uv = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime*1));
  //progress = 0;
  //----------------------------------------------

  float x = opening ? progress : 1.-progress;
  float m = smoothstep(-smoothness, 0.0, SQRT_2*distance(center, uv) - x*(1.+smoothness));
  //return mix(getFromColor(uv), getToColor(uv), opening ? 1.-m : m);

  //----------------------------------------------
  colorBG.rgb *= colorBG.a;

  vec4 cFrom = texture2D( CoronaSampler0, uv );
  vec4 cTo = colorBG;
  COLOR = mix( cFrom, colorBG, opening ? 1.-m : m );
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


