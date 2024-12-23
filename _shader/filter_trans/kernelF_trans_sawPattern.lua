
--[[
  Origin Author: arlez80
  https://godotshaders.com/author/arlez80/
  
  ギザギザトランジションシェーダー by あるる（きのもと 結衣）
  Saw Transition Shader by KINOMOTO Yui

  MIT License

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "sawPattern"

kernel.vertexData =
{
  {
    name = "progress",
    default = 0.5,
    min = 0,
    max = 1,
    index = 0, 
  },
  {
    name = "gridAmount",
    default = 3,
    min = 1,
    max = 24,
    index = 1,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
}


kernel.fragment =
[[
float progress = CoronaVertexUserData.x;
P_UV float gridAmount = CoronaVertexUserData.y;

//----------------------------------------------
uniform float saw_l_shift = -0.267;
uniform float saw_r_interval = 0.1; // The less the more
uniform float saw_l_interval = 2.0;
uniform float saw_r_scale = 2.0; // The more the longer
uniform float saw_l_scale = 0.821;

uniform vec2 uv_scale = vec2( 2.0, 8.0 );
uniform vec4 colorTint = vec4( 1.0, 1.0, 1.0, 1.0 ); //: hint_color 

float left = -2.0;
float offsetL = 0.0;
float ratioL = -1.0;

float right = 0.0;
float offsetR = -1.0;
float ratioR = 2.5;
//----------------------------------------------

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

//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  
  //left = progress * ratioL + offsetL;
  right = progress * ratioR + offsetR;

  P_UV vec2 UV = texCoord;
  //----------------------------------------------

  vec2 scaled_uv = UV * uv_scale;
  float saw_a = calc_saw( scaled_uv.y, saw_r_interval, saw_r_scale );
  float saw_b = calc_saw( scaled_uv.y + saw_l_shift, saw_l_interval, saw_l_scale );

  /*
  //Origin
  vec4 texture_pixel = texture2D( CoronaSampler0, UV );
  P_COLOR vec4 COLOR = vec4(
    colorTint.rgb * texture_pixel.rgb
  , colorTint.a * texture_pixel.a
    * float( scaled_uv.x < max( saw_a, saw_b ) + right )
    * float( max( saw_a, saw_b ) + left < scaled_uv.x )
  );
  */

  P_COLOR float v_alpha = colorTint.a 
    * float( scaled_uv.x < max( saw_a, saw_b ) + right )
    * float( max( saw_a, saw_b ) + left < scaled_uv.x );

  //v_alpha = f_when_eq(v_alpha, 1.0);

  P_UV vec2 v_uvGrid = mod( UV * gridAmount, 1.0 );
  P_COLOR vec4 texColor = texture2D( CoronaSampler0, v_uvGrid);
  //P_COLOR vec4 COLOR = vec4(colorTint.rgb, v_alpha);
  P_COLOR vec4 COLOR = vec4(texColor.rgb, v_alpha);
  
  
  //----------------------------------------------
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


