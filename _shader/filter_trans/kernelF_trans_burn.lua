
--[[
    Origin Author: gre
    https://gl-transitions.com/editor/burn
    License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "burn"

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
vec4 colorBG = vec4(0.9, 0.4, 0.2, 0);

//----------------------------------------------

vec3 color = vec3(0); // vec3(0.9, 0.4, 0.2);
P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 uv )
{
  
  vec4 cFrom = texture2D( CoronaSampler0, uv ) + vec4(progress*color, 1.0);
  vec4 cTo = colorBG + vec4((1.0-progress)*color, 0.0);
  cTo.rgb *= 1-progress;
  COLOR = mix( cFrom, cTo, progress);

  //----------------------------------------------
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


