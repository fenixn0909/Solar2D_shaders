
--[[

  Origin Author: fkuteken
  https://gl-transitions.com/editor/CircleCrop
  ported by gre from https://gist.github.com/fkuteken/f63e3009c1143950dee9063c3b83fb88
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "circleCrop"


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
float ratio = CoronaVertexUserData.y;
//----------------------------------------------
uniform vec4 bgcolor = vec4(0.0, 0.0, 0.0, 1.0); // 

vec2 ratio2 = vec2(1.0, 1.0 / ratio);
float s = pow(2.0 * abs(progress - 0.5), 3.0);



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 p = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  float dist = length((vec2(p) - 0.5) * ratio2);
  /*
  return mix(
    progress < 0.5 ? getFromColor(p) : getToColor(p), // branching is ok here as we statically depend on progress uniform (branching won't change over pixels)
    bgcolor,
    step(s, dist)
  );
  */

  //----------------------------------------------
  COLOR = mix( 
    progress < 0.5 ? texture2D( CoronaSampler0, p ) : colorBG,
    bgcolor,
    step(s, dist)
  );
  
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


