
--[[

  Origin Author: 0gust1
  https://gl-transitions.com/editor/SimpleZoom
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "simpleZoom"

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
uniform float zoom_quickness = 0.8; //
float nQuick = clamp(zoom_quickness,0.2,1.0);

vec2 zoom(vec2 uv, float amount) {
  return 0.5 + ((uv - 0.5) * (1.0-amount)); 
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 uv = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  /*
  return mix(
    getFromColor(zoom(uv, smoothstep(0.0, nQuick, progress))),
    getToColor(uv),
   smoothstep(nQuick-0.2, 1.0, progress)
  );
  */

  //----------------------------------------------
  P_COLOR vec4 cFrom = texture2D( CoronaSampler0, zoom(uv, smoothstep(0.0, nQuick, progress) ) );
  P_COLOR vec4 cTo = colorBG;
  float m = smoothstep(nQuick-0.2, 1.0, progress);

  COLOR = mix( cFrom, cTo, m) ;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


