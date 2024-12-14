
--[[
  Origin Author: vanviethieuanh
  https://godotshaders.com/author/vanviethieuanh/
  
  
  In Color is the color of transition in effect
  Out Color is the color of transition out effect

  In Out set which color to pick, If the value greater than 0.5. The color will be Out color otherwise it will be the In color.

  Position the a slide from -1.5 to 1 if it set to 1, whole screen will be reveal. If it -1.5, whole screen will be cover.
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "screenTone"

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

uniform P_DEFAULT vec4 u_resolution;

vec4 in_color = vec4( 1.0, 0.0, 0.0, 1.0); //:hint_color
vec4 out_color = vec4( 0.0, 1.0, 1.0, 1.0); //:hint_color

float in_out = .25; //:hint_range(0.,1.)

float slider = 0.856; //:hint_range(-1.5,1.)
vec2 size = vec2(32., 32.);


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 iTexelSize = vec2(.001, .001);
  vec2 a = (1./iTexelSize) / size;
  
  vec2 uv=texCoord;
  uv *= a;
  
  vec2 i_uv = floor(uv);
  vec2 f_uv = fract(uv);
  
  //Test
  //float slider = -mod( CoronaTotalTime * 1, 2.5) + 1; //Cover Scene
  float slider = mod( CoronaTotalTime * 1, 2.5) - 1.5; //Reavel Scene 
  
  float wave = max(0.,i_uv.x/(a.x) - slider);
  
  vec2 center = f_uv*2.-1.;
  float circle = length(center);
  circle = 1. - step(wave,circle);
  
  vec4 color = mix(in_color, out_color, step(0.5, in_out));
  
  //COLOR = vec4(circle) * color;
  
  P_COLOR vec4 finColor = vec4(circle) * color;

  return CoronaColorScale(finColor);
}
]]

return kernel

--[[

--]]


