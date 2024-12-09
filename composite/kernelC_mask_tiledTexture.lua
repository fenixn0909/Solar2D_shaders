
--[[
  Origin Author: mreliptik
  https://godotshaders.com/author/mreliptik/


  Allows you to tile a pattern inside of another texture acting as a mask (based on opacity). The pattern texture will scale from its center but you can always offset it using the offset uniform. 

  HOW TO USE?

  On a texture (TextureRect, Sprite, etc…) add a new ShaderMaterial and a new Shader and put the code below.

  In the shader params, put the pattern texture you want to tile (make sure “repeat” is enabled in the import tab).

  Play with the tile_factor and the offset, to obtain the result you desire! You can easily animate these values to make the pattern move.

  Parameters

  pattern: the tilable texture you want to use
  tile_factor: the scaling factor, the bigger the more tilling
  tile_offset: offset the texture from its center
   

  Shoutout to Nekoto, for the help!

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "mask"
kernel.name = "tiledTexture"

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "patternW",
    default = 1,
    min = 1,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "patternH",
    default = 4,
    min = 1,
    max = 9999,     -- 16x16->256
    index = 1,    -- v_UserData.y
  },
  {
    name = "textureRatio",
    default = 1,
    min = 1,
    max = 9999,     
    index = 2,    -- v_UserData.z
  },
  
}


kernel.fragment =
[[

uniform float tile_factor = 10.0; //: hint_range(0.0, 10.0);
vec2 tile_offset = vec2(0.0);

float patternW = CoronaVertexUserData.x;
float patternH = CoronaVertexUserData.y;
float textureRatio = CoronaVertexUserData.z;

//float patternW = 1;
//float patternH = 1;



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_COLOR vec4 COLOR;
  P_UV vec2 UV = texCoord;

  //vec2 pattern_pixel_size = 1.0 / vec2(textureSize(pattern, 0));
  vec2 pattern_pixel_size = 1.0 / vec2( patternW, patternH );

  vec2 diff = pattern_pixel_size / CoronaTexelSize.zw;
  
  vec4 in_mask = texture2D(CoronaSampler0, UV);
  
  // brings the uv to -1, 1
  vec2 centered_uv = UV * 2.0 - 1.0;
  vec2 tiled_uv = centered_uv * tile_factor * diff;
  
  // brings back the uv to 0, 1
  tiled_uv  = (tiled_uv * textureRatio * 0.5 + 0.5) ;
  
  // Move Inner Tex
  //tile_offset.y = tile_offset.y + abs(sin(CoronaTotalTime);
  tile_offset.y = mod(CoronaTotalTime*0.5, 0.25);
  //tile_offset.y = 0.1;

  tiled_uv += tile_offset;
  tiled_uv = mod( tiled_uv, 1) ;
  vec4 pattern_tex = texture2D(CoronaSampler1, tiled_uv);
  COLOR.rgb = pattern_tex.rgb;
  COLOR.a = pattern_tex.a * in_mask.a;

  COLOR.rgb *= COLOR.a;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


