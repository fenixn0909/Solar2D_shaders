
--[[
  Origin Author: exuin
  https://godotshaders.com/author/exuin/

  Here is a simple lines screen transition. Change y_threshold to change how far along the lines are.

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "lines"

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "textureRatio",
    default = 1,
    min = 0,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "paletteRowCols",
    default = 4,
    min = 1,
    max = 16,     -- 16x16->256
    index = 1,    -- v_UserData.y
  },
}


kernel.fragment =
[[

uniform P_DEFAULT vec4 u_resolution;

float num_lines = 20.;
float y_threshold = 0.5; //: hint_range(0.0, 1.0)
vec4 line_color_a = vec4(1.); //: hint_color
vec4 line_color_b = vec4(0., 1., 0., 1.0); //: hint_color


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_COLOR vec4 finColor;
  
  //TEST
  //float y_threshold = mod( CoronaTotalTime * 1, 1) ; //Cover Scene
  float y_threshold = mod( CoronaTotalTime * -1, 1) ; //Reveal Scene

  vec2 tiled_uv = vec2(fract(texCoord.x * num_lines / 2.), texCoord.y);
  if (tiled_uv.x < 0.5){
    if(tiled_uv.y < y_threshold){
      finColor = line_color_a;
    } else {
      finColor = vec4(0.0);
    }
  } else {
    if (tiled_uv.y > 1. - y_threshold){
      finColor = line_color_b;
    } else {
      finColor = vec4(0.0);
    }
  }

  return CoronaColorScale(finColor);
}
]]

return kernel

--[[



--]]


