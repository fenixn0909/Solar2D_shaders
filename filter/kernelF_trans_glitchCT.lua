
--[[
  Origin Author: arlez80
  https://godotshaders.com/author/arlez80/
  
  A glitch transition shader.

  Set animation key to fade by AnimationPlayer to do fade in/out, or Use script like this:
  var time:float = 0.0

  func _process( delta:float ):
  var shader:ShaderMaterial = # here is some MeshInstance's material

  time += delta
  shader.set_shader_param( "fade", clamp( time, 0.0, 1.0 ) )



--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "glitchCT"

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

//----------------------------------------------


// 振動の強さ
float shake_power = 0.01;
// 振動ブロックサイズ
uniform float shake_block_size = 50; // The larger the more
// 色の分離率
float fade = 0.2; //: hint_range( 0.0, 1.0 ) 
// R方向
uniform vec2 direction_r = vec2( 0.1, 0.02 );
// G方向
uniform vec2 direction_g = vec2( 0.4, 0.2 );
// B方向
uniform vec2 direction_b = vec2( -0.3, -0.15 );

float random( float seed )
{
  return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46, -54.3415 ) ) ) );
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  // Pixelate
  P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );
  //P_UV vec2 SCREEN_UV = UV_Pix;
  // Smooth
  P_UV vec2 SCREEN_UV = texCoord;

  P_COLOR vec4 COLOR;
  //float TIME = CoronaTotalTime;
  float TIME = progress;
  fade = progress;

  //Test
  //shake_power = abs(sin(CoronaTotalTime))*0.02;
  //fade = abs(sin(CoronaTotalTime*2))*0.3;
  //fade = 0;

  vec2 fixed_uv = SCREEN_UV;
    fixed_uv.x += (
      random(
        ( floor( SCREEN_UV.y * shake_block_size ) / shake_block_size )
      + TIME
      ) - 0.5
    ) * shake_power * ( fade * 12.0 );

    COLOR = vec4(
      texture2D( CoronaSampler0, fixed_uv + normalize( direction_r ) * fade, 0.0 ).r
    , texture2D( CoronaSampler0, fixed_uv + normalize( direction_g ) * fade, 0.0 ).g
    , texture2D( CoronaSampler0, fixed_uv + normalize( direction_b ) * fade, 0.0 ).b
    , 1.0
    ) * ( 1.0 - fade );

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


