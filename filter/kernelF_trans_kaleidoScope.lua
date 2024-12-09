
--[[
  Origin Author: nwoeanhinnogaehr
  https://gl-transitions.com/editor/kaleidoscope
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "kaleidoScope"

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

uniform float speed = 1.0; //
uniform float angle = 1.0; //
uniform float power = 1.5; //

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------

  vec2 p = UV.xy / vec2(1.0).xy;
  vec2 q = p;
  float t = pow(progress, power)*speed;
  p = p -0.5;
  for (int i = 0; i < 7; i++) {
    p = vec2(sin(t)*p.x + cos(t)*p.y, sin(t)*p.y - cos(t)*p.x);
    t += angle;
    p = abs(mod(p, 2.0) - 1.0);
  }
  abs(mod(p, 1.0));

  /*
  return mix(
    mix(getFromColor(q), getToColor(q), progress),
    mix(getFromColor(p), getToColor(p), progress), 
    1.0 - 2.0*abs(progress - 0.5));
    */

  //----------------------------------------------

  vec4 fromColorQ = texture2D( CoronaSampler0, q );
  vec4 toColorQ = colorBG;

  vec4 fromColorP = texture2D( CoronaSampler0, p );
  vec4 toColorP = colorBG;

  vec4 m1 = mix( fromColorQ, toColorQ, progress);
  vec4 m2 = mix( fromColorP, toColorP, progress);

  COLOR = mix( m1, m2, 1.0 - 2.0 *  abs( progress - 0.5 ) );
  

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


