
--[[
    Origin Author: Fernando Kuteken
    https://gl-transitions.com/editor/circle
    License: MIT

--]]

local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "circle"

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


//----------------------------------------------
uniform vec2 center = vec2(0.5, 0.5);
uniform vec3 backColor = vec3(0.1, 0.1, 0.1);


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 uv = texCoord;
  P_COLOR vec4 COLOR;
  
  //----------------------------------------------
  float distance = length(uv - center);
  float radius = sqrt(8.0) * abs(progress - 0.5);
  /*
  if (distance > radius) {
    return vec4(backColor, 1.0);
  }
  else {
    if (progress < 0.5) return getFromColor(uv);
    else return getToColor(uv);
  }
  */
  //----------------------------------------------

  colorBG.rgb *= colorBG.a;

  if (distance > radius) {
    return CoronaColorScale( vec4(backColor, 1.0) );
  }
  else {
    if (progress < 0.5) return CoronaColorScale( texture2D( CoronaSampler0, uv ) );
    else return CoronaColorScale( colorBG );
  }

}
]]

return kernel

--[[

--]]


