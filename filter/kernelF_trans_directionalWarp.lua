
--[[

  Origin Author: pschroen
  https://gl-transitions.com/editor/directionalwarp
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "directionalWarp"

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
uniform vec2 direction = vec2(-1.0, 1.0); //

const float smoothness = 0.5;
const vec2 center = vec2(0.5, 0.5);

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 uv = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  vec2 v = normalize(direction);
  v /= abs(v.x) + abs(v.y);
  float d = v.x * center.x + v.y * center.y;
  float m = 1.0 - smoothstep(-smoothness, 0.0, v.x * uv.x + v.y * uv.y - (d - 0.5 + progress * (1.0 + smoothness)));
  //return mix(getFromColor((uv - 0.5) * (1.0 - m) + 0.5), getToColor((uv - 0.5) * m + 0.5), m);

  //----------------------------------------------
  
  COLOR = mix(
    texture2D( CoronaSampler0, (uv - 0.5) * (1.0 - m) + 0.5 ),
    colorBG,
    m
  );
  
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]

