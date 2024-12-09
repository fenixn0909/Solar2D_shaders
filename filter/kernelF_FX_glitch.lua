--[[
  Origin Author: arlez80
  https://godotshaders.com/author/arlez80/

  IMPORTANT: using sceenTexture as sampler0


  This is a glitch effect shader.




--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "glitch"
kernel.isTimeDependent = true


kernel.vertexData   = {
  {
    name    = "r",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 0,
    },{
    name    = "g",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 1,
    },{
    name    = "b",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 2,
    },{
    name    = "size",
    default = 1,
    min     = 0,
    max     = 4,
    index   = 3,
  },
}
kernel.fragment = [[
// 振動の強さ
uniform float shake_power = 0.03;
// 振動率
uniform float shake_rate = 0.2; //: hint_range( 0.0, 1.0 ) 
// 振動速度
uniform float shake_speed = 5.0;
// 振動ブロックサイズ
uniform float shake_block_size = 30.5;
// 色の分離率
uniform float shake_color_rate = 0.01; // : hint_range( 0.0, 1.0 )

//uniform sampler2D SCREEN_TEXTURE = CoronaSampler0;

float random( float seed )
{
  return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46, -54.3415 ) ) ) );
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_DEFAULT float TIME = CoronaTotalTime;
  P_UV vec2 SCREEN_UV = texCoord;

  float enable_shift = float( random( floor( TIME * shake_speed ) ) < shake_rate);

  vec2 fixed_uv = SCREEN_UV;
  fixed_uv.x += (
    random(
      ( floor( SCREEN_UV.y * shake_block_size ) / shake_block_size )
    + TIME
    ) - 0.5
  ) * shake_power * enable_shift;

  vec4 pixel_color = texture2D( CoronaSampler0, fixed_uv, 0.0);
  pixel_color.r = mix(
    pixel_color.r
  , texture2D( CoronaSampler0, fixed_uv + vec2( shake_color_rate, 0.0 ), 0.0).r
  , enable_shift
  );
  pixel_color.b = mix(
    pixel_color.b
  , texture2D( CoronaSampler0, fixed_uv + vec2( -shake_color_rate, 0.0 ), 0.0 ).b
  , enable_shift
  );


  return CoronaColorScale(pixel_color);
}

]]
return kernel

--[[



--]]