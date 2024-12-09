
--[[

  Origin Author: paniq
  https://gl-transitions.com/editor/Morph
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "morph"

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
uniform float strength = 0.1; //

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 p = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  //vec4 ca = getFromColor(p);
  //vec4 cb = getToColor(p);
  vec4 ca = texture2D( CoronaSampler0, p );
  vec4 cb = colorBG;
  
  vec2 oa = (((ca.rg+ca.b)*0.5)*2.0-1.0);
  vec2 ob = (((cb.rg+cb.b)*0.5)*2.0-1.0);
  vec2 oc = mix(oa,ob,0.5)*strength;
  
  float w0 = progress;
  float w1 = 1.0-w0;
  //return mix(getFromColor(p+oc*w0), getToColor(p-oc*w1), progress);

  //----------------------------------------------
  COLOR = mix(
    texture2D( CoronaSampler0, p+oc*w0 ),
    colorBG,
    progress
  );
  
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


