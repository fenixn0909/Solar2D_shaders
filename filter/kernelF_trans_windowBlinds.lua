
--[[
  Origin Author: Fabien Benetou
  https://gl-transitions.com/editor/windowblinds
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "windowBlinds"

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

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //progress = mod(CoronaTotalTime*0.5, 0.5) + 0.25;
  //progress = 0.5;
  //----------------------------------------------
  
  float t = progress;
    
  if (mod(floor(UV.y*100.*progress),2.)==0.)
    t*=2.-.5;
  /*
  return mix(
    getFromColor(UV),
    getToColor(UV),
    mix(t, progress, smoothstep(0.8, 1.0, progress))
  );
  */
  //----------------------------------------------

  float m = mix(t, progress, smoothstep(0.8, 1.0, progress));
  COLOR = mix(texture2D(CoronaSampler0,UV), colorBG, m);
  //COLOR.a = texture2D(CoronaSampler0,UV).a;
  //COLOR.rgb *= COLOR.a;
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


