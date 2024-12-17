
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
  { name = "Speed",         default = 3, min = 0, max = 100, index = 0, },
  { name = "Angle",         default = 60, min = 0, max = 360, index = 1, },
  { name = "Lines",         default = 2, min = 0, max = 100, index = 2, },
  { name = "Blur",          default = .1, min = 0, max = 3, index = 3, },
} 


kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Angle = CoronaVertexUserData.y; 
float Lines = CoronaVertexUserData.z;
float Blur = CoronaVertexUserData.w;

//----------------------------------------------

uniform vec3 color_one = vec3( 0.9, 0.7, 0.3 ); //: source_color; 
uniform vec3 color_two = vec3( 0.8, 0.2, 0.3 ); //: source_color;  

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
    return cos(uv.x * 0.0 - TIME*Speed + uv.y * -Lines*10 * .5);
}

//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------

  vec2 uv = UV;
  vec2 resolution = 1.0 / TEXTURE_PIXEL_SIZE;
  float a = TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y;
  uv.x *= a;
  uv = rotate(uv, Angle);
  float g = stripe(uv);
  vec3 col = mix(color_one, color_two, smoothstep(0.0, Blur, g));
  COLOR = vec4(col, 1.0);

  //----------------------------------------------

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[



--]]


