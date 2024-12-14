
--[[
  Origin Author: gratemate
  https://godotshaders.com/author/gratemate/

  TEXTURE: heightMap

  Simple transition. Animate or change fill amount to see the transition.

  To use the shaders simply add your preferred heightmap in the heightMap sampler and animate fill to change the threshold, you can also change the color of the transition.

  Examples of heightmaps are provided in screenshots.

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "dissolve"

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

float fill = -0.05; //: hint_range(-0.01,1.0) 
uniform vec4 color = vec4 (1, 0, 0, 1);// hint



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  fill = abs(sin(CoronaTotalTime) * 1);

  float h = texture2D(CoronaSampler0,texCoord).x;
  h = clamp(floor(h+fill), 0.0, 1.0);
  P_COLOR vec4 COLOR = vec4(color.rgb,color.a*h);
  
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


