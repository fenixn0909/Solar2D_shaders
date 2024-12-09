
--[[
  https://godotshaders.com/shader/scrolling-line-background/
  SuperMatCat24
  October 18, 2024

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "scrollingLine"

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

//----------------------------------------------

uniform vec3 color_one = vec3( 0.9, 0.7, 0.3 ); //: source_color; 
uniform vec3 color_two = vec3( 0.8, 0.2, 0.3 ); //: source_color;  

uniform float angle = 60.0;
uniform float line_count = 20.0; 
uniform float speed = 1.0; 
uniform float blur = 0.1; //: hint_range(0.0, 2.0, 0) 

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;
vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;

//----------------------------------------------

vec2 rotate(vec2 uv, float rotation_angle) {
    float radians_angle = radians(rotation_angle);
    float cos_angle = cos(radians_angle);
    float sin_angle = sin(radians_angle);
    mat2 rotation_matrix = mat2(vec2(cos_angle, -sin_angle), vec2(sin_angle, cos_angle));
    return uv * rotation_matrix;
}

float stripe(vec2 uv) {
    return cos(uv.x * 0.0 - TIME*speed + uv.y * -line_count/2.0);
}


//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------

  vec2 uv = UV;
  vec2 resolution = 1.0 / TEXTURE_PIXEL_SIZE;
  float a = TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y;
  uv.x *= a;
  uv = rotate(uv, angle);
  float g = stripe(uv);
  vec3 col = mix(color_one, color_two, smoothstep(0.0, blur, g));
  COLOR = vec4(col, 1.0);

  //----------------------------------------------


  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[



--]]


