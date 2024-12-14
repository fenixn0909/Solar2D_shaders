
--[[
  Origin Author: vanviethieuanh
  https://godotshaders.com/author/vanviethieuanh/
  
  This shader creates a lightning effect in the middle of the sprite. (Low down the resolution then you will have pixel art lightning effect)

  `lightning_color` : specify color
  `size`: how thick bolt line should be
  `width`: how long the range of the bolt should be
  `speed`: how fast the lightning should change
  `cycle`: how many cycles the zigzag should be
  `time_shift`: because we use the sine function as a random, the same `TIME` will produce the same bolt, so if we create different bolts, we need to shift the time a little bit.
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FX"
kernel.name = "lightning2D"

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

vec4 lightning_color = vec4( 1., 0., 0., 1.); //: hint_color

const float PI = 3.14159265359;

float size = 0.05; //: hint_range (0.,1.);
float width = 0.5; //: hint_range (0.,1.);
float speed = 0.25;
float cycle = 3;
float ratio = 0.1;
float time_shift = 3;


float rand(float x){
  return fract(sin(x)*100000.0);
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  
  P_RANDOM float bolt = abs(mod(texCoord.y * cycle + (rand(CoronaTotalTime) + time_shift) * speed * -1., 0.5)-0.25)-0.125;
  bolt *= 4. * width;
  // why 4 ? Because we use mod 0.5, the value be devide by half
  // and we -0.25 (which is half again) for abs function. So it 25%!
  
  // scale down at start and end
  bolt *=  (0.5 - abs(texCoord.y-0.5)) * 2.; 
  
  // turn to a line
  // center align line
  float wave = abs(texCoord.x - 0.5 + bolt);
  // invert and ajust size
  wave = 1. - step(size*.5, wave);
  
  float blink = step(rand(CoronaTotalTime)*ratio, .5);
  wave *= blink;
  
  vec4 display = lightning_color * vec4(wave);
  
  //COLOR = display;


  P_COLOR vec4 finColor = display;

  return CoronaColorScale(finColor);
}
]]

return kernel

--[[



--]]


