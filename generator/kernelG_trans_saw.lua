
--[[
  Origin Author: arlez80
  https://godotshaders.com/author/arlez80/
  
  ギザギザトランジションシェーダー by あるる（きのもと 結衣）
  Saw Transition Shader by KINOMOTO Yui

  MIT License


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "saw"

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

uniform float saw_b_shift = -0.267;
uniform float saw_a_interval = 1.0;
uniform float saw_b_interval = 2.0;
uniform float saw_a_scale = 1.0;
uniform float saw_b_scale = 0.821;

uniform vec2 uv_scale = vec2( 2.0, 8.0 );
uniform vec4 colorCover = vec4( 1.0, 1.0, 1.0, 1.0 ); //: hint_color 

float right = 0.0;
float left = -2.0;

vec3 when_eq(vec3 x, vec3 y) {
  //return 1.0 - abs(sign(x - y));
  return abs(sign(x - y));
}

float f_when_eq(float x, float y) {
  //return 1.0 - abs(sign(x - y));
  return abs(sign(x - y));
}


float calc_saw( float y, float interval, float scale )
{
  return max( ( abs( interval / 2.0 - mod( y, interval ) ) - ( interval / 2.0 - 0.5 ) ) * scale, 0.0 );
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  //Test
  left = abs(sin(CoronaTotalTime)*3)-0.8;
  //left = 0.0;
  right = 1.0;

  P_UV vec2 UV = texCoord;

  vec2 scaled_uv = UV * uv_scale;
  float saw_a = calc_saw( scaled_uv.y, saw_a_interval, saw_a_scale );
  float saw_b = calc_saw( scaled_uv.y + saw_b_shift, saw_b_interval, saw_b_scale );

  
  P_COLOR float v_alpha = colorCover.a 
    * float( scaled_uv.x < max( saw_a, saw_b ) + right )
    * float( max( saw_a, saw_b ) + left < scaled_uv.x );

  v_alpha = f_when_eq(v_alpha, 1.0);

  P_COLOR vec4 COLOR = vec4(colorCover.rgb, v_alpha);


  COLOR.rgb *= COLOR.a;

  //COLOR.rgb = vec3(1, 0, 0) * when_eq( COLOR.a, 0);
  if ( vec3(0,0,0) == when_eq( COLOR.rgb, vec3(0,0,0) ))
  {
    //COLOR.rgb = vec3(1, 0, 0);
  }
  //COLOR.rgb = vec3(1, 0, 0) * when_eq( COLOR.rgb, vec3(0,0,0) );


  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


