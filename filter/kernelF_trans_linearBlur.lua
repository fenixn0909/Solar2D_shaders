
--[[

  Origin Author: gre
  https://gl-transitions.com/editor/LinearBlur
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "linearBlur"

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
uniform float intensity = 0.1; //
const int passes = 6;


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 uv = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  vec4 c1 = vec4(0.0);
  vec4 c2 = vec4(0.0);

  float disp = intensity*(0.5-distance(0.5, progress));
  for (int xi=0; xi<passes; xi++)
  {
      float x = float(xi) / float(passes) - 0.5;
      for (int yi=0; yi<passes; yi++)
      {
          float y = float(yi) / float(passes) - 0.5;
          vec2 v = vec2(x,y);
          float d = disp;
          //c1 += getFromColor( uv + d*v);
          //c2 += getToColor( uv + d*v);
          c1 += texture2D( CoronaSampler0, uv + d*v );
          c2 += colorBG;


      }
  }
  c1 /= float(passes*passes);
  c2 /= float(passes*passes);
  //return mix(c1, c2, progress);

  //----------------------------------------------
  
  COLOR = mix( c1, c2, progress ) ;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


