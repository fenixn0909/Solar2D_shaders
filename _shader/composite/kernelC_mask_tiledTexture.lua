
--[[
    Origin Author: mreliptik
    https://godotshaders.com/shader/tiled-texture-inside-of-mask/

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "mask"
kernel.name = "tiledTexture"

kernel.isTimeDependent = true
kernel.textureWrap = 'repeat'

kernel.vertexData =
{
  { name = "Speed_X",   default = 1, min = -2, max = 2, index = 0, },
  { name = "Speed_Y",   default = 1, min = -2, max = 2, index = 1, },
  { name = "Scale",     default = 3, min = 0.1, max = 10, index = 2, },
} 


kernel.fragment =
[[

//----------------------------------------------


float Speed_X = CoronaVertexUserData.x;
float Speed_Y = CoronaVertexUserData.y;
float Scale = CoronaVertexUserData.z;

vec2 Tile_Speed = vec2( Speed_X, Speed_Y);

//----------------------------------------------

P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
P_COLOR vec4 COLOR;
float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

  //vec2 pattern_pixel_size = 1.0 / vec2(textureSize(pattern, 0));
  //vec2 pattern_pixel_size = 1.0 / vec2( Pattern_W, Pattern_H );
  vec2 pattern_pixel_size = 1.0 / vec2( 100, 100 );
  //vec2 pattern_pixel_size = 1.0 / TEXTURE_PIXEL_SIZE;

  vec2 diff = pattern_pixel_size / TEXTURE_PIXEL_SIZE;
  
  vec4 in_mask = texture2D(CoronaSampler0, UV);
  
  // brings the uv to -1, 1
  vec2 centered_uv = UV * 2.0 - 1.0;
  vec2 tiled_uv = centered_uv * Scale * diff;
  
  // brings back the uv to 0, 1
  tiled_uv  = (tiled_uv * 0.5 + 0.5) ;
  
  // Move Inner Tex
  //Tile_Speed.y = Tile_Speed.y + abs(sin(TIME);
  //Tile_Speed.y = mod(TIME*0.5, 0.25);
  //Tile_Speed.y = 0.1;

  tiled_uv += Tile_Speed * TIME;
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


