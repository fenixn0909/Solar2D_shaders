
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
  { name = "Speed",         default = .25, min = 0, max = 5, index = 0, },
  { name = "Cycle",         default = 12, min = 0, max = 30, index = 1, },
  { name = "Size",         default = .05, min = 0, max = 1, index = 2, },
  { name = "Width",          default = .5, min = 0, max = 30, index = 3, },
} 


kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Cycle = CoronaVertexUserData.y; 
float Size = CoronaVertexUserData.z;
float Width = CoronaVertexUserData.w;

//----------------------------------------------

vec4 lightning_color = vec4( .9, 1.0, 0.7, .8); //: hint_color

float Ratio = .2;
float Time_shift = 3;

const float PI = 3.14159265359;

//----------------------------------------------
float rand(float x){
    return fract(sin(x)*100000.0);
}
//----------------------------------------------

P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
    P_RANDOM float bolt = abs(mod(UV.y * Cycle + (rand(CoronaTotalTime) + Time_shift) * Speed * -1., 0.5)-0.25)-0.125;
    bolt *= 4. * Width;
    // why 4 ? Because we use mod 0.5, the value be devide by half
    // and we -0.25 (which is half again) for abs function. So it 25%!

    // scale down at start and end
    bolt *=  (0.5 - abs(UV.y-0.5)) * 2.; 

    // turn to a line
    // center align line
    float wave = abs(UV.x - 0.5 + bolt);
    // invert and ajust size
    wave = 1. - step(Size*.5, wave);

    float blink = step(rand(CoronaTotalTime)*Ratio, .5);
    wave *= blink;

    vec4 display = lightning_color * vec4(wave);

    COLOR = display;

    //----------------------------------------------

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[



--]]


