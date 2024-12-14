
--[[
  Origin Author: exuin
  https://godotshaders.com/author/exuin/

  Here is a simple lines screen transition. Change progress to change how far along the lines are.

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "lines"


kernel.vertexData =
{
  {
    name = "progress",
    default = .5,
    min = 0,
    max = 1,
    index = 0, 
  },
  {
    name = "lines",
    default = 20,
    min = 0,
    max = 1000,
    index = 1, 
  },
}


kernel.fragment =
[[

float progress = CoronaVertexUserData.x;
float num_lines = CoronaVertexUserData.y;

//----------------------------------------------
vec4 line_color_a = vec4(1.); //: hint_color
vec4 line_color_b = vec4(0., 1., 0., 1.0); //: hint_color


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_COLOR vec4 finColor;
  
  vec2 tiled_uv = vec2(fract(texCoord.x * num_lines / 2.), texCoord.y);
  if (tiled_uv.x < 0.5){
    if(tiled_uv.y < progress){
      finColor = line_color_a;
    } else {
      finColor = vec4(0.0);
    }
  } else {
    if (tiled_uv.y > 1. - progress){
      finColor = line_color_b;
    } else {
      finColor = vec4(0.0);
    }
  }
  //----------------------------------------------
  return CoronaColorScale(finColor);
}
]]

return kernel

--[[



--]]


