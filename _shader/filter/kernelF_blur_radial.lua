
--[[
  Origin Author: arlez80
  https://godotshaders.com/author/arlez80/
  
  /*
    放射状ブラーエフェクト by あるる（きのもと　結衣） @arlez80
    Radial Blur Effect by Yui Kinomoto

    MIT License
  */

  
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "blur"
kernel.name = "radial"

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "gridAmount",
    default = 3,
    min = 1,
    max = 24,
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
// 発射中央部
uniform vec2 blur_center = vec2( 0.5, 0.5 );
// ブラー強度
float blur_power = 0.01; //: hint_range( 0.0, 1.0 ) best 0.0, 0.2
// サンプリング回数
uniform int sampling_count = 6; //: hint_range( 1, 64 ) 


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  //SCREEN_TEXTURE = CoronaSampler0;
  P_COLOR vec4 COLOR;
  
  //Pixelate
  P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );
  P_UV vec2 SCREEN_UV = UV_Pix;
  
  //Smooth
  //P_UV vec2 SCREEN_UV = texCoord;

  //Test 
  blur_power = abs(sin(CoronaTotalTime)*1) * 0.4 - 0.2;

  vec2 direction = SCREEN_UV - blur_center;
  vec3 c = vec3( 0.0, 0.0, 0.0 );
  float f = 1.0 / float( sampling_count );
  for( int i=0; i < sampling_count; i++ ) {
    c += texture2D( CoronaSampler0, SCREEN_UV - blur_power * direction * float(i) ).rgb * f;
  }
  COLOR.rgb = c;



  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


