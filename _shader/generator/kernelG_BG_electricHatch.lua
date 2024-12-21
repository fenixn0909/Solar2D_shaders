
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

kernel.isTimeDependent = true

kernel.vertexData =
{
    { name = "Speed",           default = 0.05, min = 0, max = 2, index = 0, },
    { name = "Rotate_Speed",    default = 1.1, min = 0, max = 36, index = 1, },
    { name = "Line_Width",      default = 0.1, min = 0, max = 1, index = 2, },
    { name = "Zoom",       default = 0.1, min = 0, max = 8, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Rotate_Speed = CoronaVertexUserData.y;
float Line_Width = CoronaVertexUserData.z;
float Zoom = CoronaVertexUserData.w;
//----------------------------------------------

const float PI = 3.1415926535;
uniform vec2 scale = vec2( 8.0, 4.5 );

uniform vec4 back_color = vec4( 0.0, 0.0, 0.0, 1.0 ); //: hint_color 
uniform vec4 line_color = vec4( 0.0, 1.0, 1.0, 1.0 ); //: hint_color

//----------------------------------------------
float get_ratio_scan_line( float p )
{
  return max(
    -sin( mod( p, Zoom ) / Zoom * PI ) + Line_Width
  , 0.0
  ) / Line_Width;
}

float hatch( vec2 src_uv, float time, float dir )
{
  float r = time * Rotate_Speed * dir;
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
//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

  // Pixelate
  P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( UV / CoronaTexelSize.zw ) * CoronaTexelSize.zw );
  //P_UV vec2 SCREEN_UV = UV_Pix;
  // Smooth
  P_UV vec2 SCREEN_UV = UV;
  P_COLOR vec4 COLOR;
  //----------------------------------------------

  float TIME = CoronaTotalTime;
  float time = mod( TIME * Speed, 0.3 ) / 0.3;
  float f = clamp(
    hatch( SCREEN_UV, time, 1.0 )
  + hatch( SCREEN_UV, mod( time + 0.5, 1.0 ), -1.0 )
  , 0.0
  , 1.0
  );

  COLOR = mix( back_color, line_color, f );
  //----------------------------------------------

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


