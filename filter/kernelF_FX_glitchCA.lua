--[[
  2D Sprite “Cartridge Tilting Glitch”

  Origin Author: sashatouille
  https://godotshaders.com/author/sashatouille/


  A small shader that can be attached to a sprite. 
  This shader will allow you to simulate the graphical glitches that we could see on the old consoles when we touched the cartridge in the middle of a game!
  Works event better with a sprite sheet animated sprite (see screenshots).

  

--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "glitchCT"
kernel.isTimeDependent = true


kernel.vertexData   = {
  {
    name    = "r",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 0,
    },{
    name    = "g",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 1,
    },{
    name    = "b",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 2,
    },{
    name    = "size",
    default = 1,
    min     = 0,
    max     = 4,
    index   = 3,
  },
}
kernel.fragment = 
[[
uniform float red_displacement = 0.5; //: hint_range(-1.0,1.0) 
uniform float green_displacement = 3; //: hint_range(-1.0,1.0)
uniform float blue_displacement = 10; //: hint_range(-1.0,1.0) 
float ghost = 0.0; //: hint_range(0.0, 1.0)
uniform float intensity = 100; //: hint_range(0.0,1.0) 
float scan_effect = 0.2; //: hint_range(0.0,1.0) 
float distortion_effect = 1.0; //: hint_range(0.0,1.0)
float negative_effect = 1.0; // : hint_range(0.0,1.0)

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_DEFAULT float TIME = CoronaTotalTime;
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;

  float v_offRate = 0.2;
  float v_offSet = 0.1;

  ghost = abs(sin(CoronaTotalTime*50))*0.5;
  //scan_effect = abs(sin(CoronaTotalTime*5))*1;
  //negative_effect = abs(sin(CoronaTotalTime))*1;

  vec4 baseTexture = texture2D(CoronaSampler0, UV);
  vec4 color1 = texture2D(CoronaSampler0, UV+vec2(sin(TIME*0.2*intensity), tan(UV.y)));
  COLOR = (1.0-scan_effect)*baseTexture*0.75 + scan_effect*color1;
  
  vec4 color2 = texture2D(CoronaSampler0, UV+vec2(fract(TIME*0.01*intensity), cos(fract(TIME*intensity)*10.0)));
  COLOR = COLOR + ((1.0-distortion_effect)*baseTexture*0.75 + distortion_effect*color2);
  
  vec4 color3 = texture2D(CoronaSampler0, UV + vec2(fract(TIME*0.1*intensity), tan(TIME*0.02*intensity) ));
  COLOR = COLOR - ((1.0-negative_effect)*baseTexture*0.5 + negative_effect*color3);
  
  COLOR.r = (1.0-red_displacement)*baseTexture.r + red_displacement*texture2D(CoronaSampler0, UV-vec2(sin(TIME*intensity)*v_offRate - v_offSet, v_offSet) ).r;
  COLOR.g = (1.0-green_displacement)*baseTexture.g +  green_displacement*texture2D(CoronaSampler0, UV+vec2(- 0.05, sin(TIME*intensity) *v_offRate- 0.05 )  ).g;
  COLOR.b = (1.0-blue_displacement)*baseTexture.b + blue_displacement*texture2D(CoronaSampler0, UV+vec2(sin(TIME*intensity)*v_offRate - v_offSet, cos(TIME*intensity)*0.1) + v_offSet ).b;
  COLOR = COLOR + texture2D(CoronaSampler0, UV + UV*ghost)*ghost;
  //COLOR.rgb *= COLOR.a;

  return CoronaColorScale(COLOR);
}

]]
return kernel

--[[



--]]