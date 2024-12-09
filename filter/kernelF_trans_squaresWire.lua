
--[[

  Origin Author: gre
  https://gl-transitions.com/editor/squareswire
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "squaresWire"

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

uniform ivec2 squares = ivec2(10,10);//
uniform vec2 direction = vec2(1.0, -0.5);//
uniform float smoothness = 1.6;//

const vec2 center = vec2(0.5, 0.5);

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 p = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  vec2 v = normalize(direction);
  v /= abs(v.x)+abs(v.y);
  float d = v.x * center.x + v.y * center.y;
  float offset = smoothness;
  float pr = smoothstep(-offset, 0.0, v.x * p.x + v.y * p.y - (d-0.5+progress*(1.+offset)));
  vec2 squarep = fract(p*vec2(squares));
  vec2 squaremin = vec2(pr/2.0);
  vec2 squaremax = vec2(1.0 - pr/2.0);
  float a = (1.0 - step(progress, 0.0)) * step(squaremin.x, squarep.x) * step(squaremin.y, squarep.y) * step(squarep.x, squaremax.x) * step(squarep.y, squaremax.y);
  

  //return mix(getFromColor(p), getToColor(p), a);

  //----------------------------------------------
  COLOR = mix(texture2D( CoronaSampler0, p ), colorBG, a);

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


