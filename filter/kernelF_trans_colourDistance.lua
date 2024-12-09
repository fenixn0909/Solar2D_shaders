
--[[

  Origin Author: P-Seebauer
  https://gl-transitions.com/editor/ColourDistance
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "colourDistance"

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
uniform float power = 5.0; //

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 p = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  vec4 fTex = texture2D( CoronaSampler0, p );
  //vec4 tTex = colorBG;
  vec4 tTex = texture2D( CoronaSampler0, 1-p ); // Using diagonal color
  tTex.a = 1-progress;
  tTex.rgb *= tTex.a;

  float m = step(distance(fTex, tTex), progress);
  /*
  return mix(
    mix(fTex, tTex, m),
    tTex,
    pow(progress, power)
  );
  */
  //----------------------------------------------
  COLOR = mix(
    mix(fTex, tTex, m),
    tTex,
    pow(progress, power)
  );
  
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


