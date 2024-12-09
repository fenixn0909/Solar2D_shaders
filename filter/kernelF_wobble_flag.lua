--[[
  Origin Author: mreliptik
  https://godotshaders.com/author/mreliptik/


  This is a simple shader to animate a texture like a flag. You can use the various uniforms to control the look and feel of the flag.

  speed: speed at which the TIME elapses. Basically the wind speed
  frequency_x: frequency of the sine wave for the x axis
  frequency_y: frequency of the sine wave for the y axis
  amplitude_x: amplitude of the distortion for the x axis
  amplitude_y: amplitude of the distortion for the y axis
  inclination: inclination in the x axis, where the flag is attached (left)
  I made a video showing you how I made it, check it out here: https://youtu.be/FIYrT8H9Qgg 

  Feel free to use it however you like!

  Get demo project


--]]



local kernel = {}

kernel.language = "glsl"

kernel.category = "filter"
kernel.group = "wobble"
kernel.name = "flag"

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "x",
    default = 1,
    min = 0,
    max = 4,
    index = 0, -- v_UserData.x
  },
  {
    name = "y",
    default = 1,
    min = 0,
    max = 4,
    index = 1, -- v_UserData.y
  },
}


kernel.vertex =
[[

uniform float speed = 2.0;
uniform float frequency_y = 5.0;
uniform float frequency_x = 5.0;
uniform float amplitude_y = 1.0;
uniform float amplitude_x = 1.0;
uniform float inclination = 1.0;

P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{ 
  P_POSITION vec2 VERTEX = CoronaTexCoord;
  P_UV vec2 UV = position;
  float TIME = CoronaTotalTime*0.5;

  VERTEX.y += sin((UV.x - TIME * speed) * frequency_y) * amplitude_y * UV.x;
  VERTEX.x += cos((UV.y - TIME * speed) * frequency_x) * amplitude_x * UV.x;
  VERTEX.x -= UV.y * inclination;

  return VERTEX;
}
]]

return kernel

--[[


--]]
