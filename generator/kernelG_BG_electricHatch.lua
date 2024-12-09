
--[[
  Origin Author: arlez80
  https://godotshaders.com/author/arlez80/
  
  A Electric Hatch Background Shader

  /*
    電子的十字背景シェーダー by あるる（きのもと 結衣） @arlez80
    Electric Hatch Background Shader by KINOMOTO Yui @arlez80

    MIT License
  */

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "electricHatch"

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
const float PI = 3.1415926535;

uniform float speed = 0.05;
uniform vec2 scale = vec2( 8.0, 4.5 );
uniform float rotate_speed = 1.1;
uniform float line_width = 0.1; //: hint_range( 0.0, 1.0 ) 
uniform float line_size = 0.1;

uniform vec4 back_color = vec4( 0.0, 0.0, 0.0, 1.0 ); //: hint_color 
uniform vec4 line_color = vec4( 0.0, 1.0, 1.0, 1.0 ); //: hint_color

float get_ratio_scan_line( float p )
{
  return max(
    -sin( mod( p, line_size ) / line_size * PI ) + line_width
  , 0.0
  ) / line_width;
}

float hatch( vec2 src_uv, float time, float dir )
{
  float r = time * rotate_speed * dir;
  float c = cos( r );
  float s = sin( r );
  mat2 matr = mat2(
    vec2( c, s )
  , vec2( -s, c )
  );
  vec2 uv = ( ( src_uv - vec2( 0.5, 0.5 ) ) * scale * time * 0.5 ) * matr;
  return clamp( 
    (
      get_ratio_scan_line( uv.x )
    + get_ratio_scan_line( uv.y )
    ) * sin( time * PI ) * 4.0
  , 0.0
  , 1.0
  );
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  // Pixelate
  P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );
  //P_UV vec2 SCREEN_UV = UV_Pix;
  // Smooth
  P_UV vec2 SCREEN_UV = texCoord;
  P_COLOR vec4 COLOR;

  float TIME = CoronaTotalTime;
  float time = mod( TIME * speed, 0.3 ) / 0.3;
  float f = clamp(
    hatch( SCREEN_UV, time, 1.0 )
  + hatch( SCREEN_UV, mod( time + 0.5, 1.0 ), -1.0 )
  , 0.0
  , 1.0
  );

  COLOR = mix( back_color, line_color, f );

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


