
--[[
  Origin Author: lurgx
  https://godotshaders.com/author/lurgx/

  Rainbow outline by @Farfalk and @ThePadDev, And Edit for @LURGX in 2022

  Apply to canvas items with transparent backgrounds.
  Check that there is sufficient transparent background space for the outline!

  CC0 License (but citation is welcome <3)
  All code is property of @Farfalk and @ThePadDev
  Thanks for shader and I'm a newbie with shaders 
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "linePx"
kernel.name = "rainbow"
kernel.isTimeDependent = true



kernel.fragment =
[[

bool rainbow  = true; //Activate the rainbow or select you color
vec4 line_color = vec4(1.0, 1.0, 1.0, 1.0); //color line : hint_color 
float line_scale = 5;    // thickness of the line : hint_range(0, 20) 
float frequency  = 0.5;  // frequency of the rainbow : hint_range(0.0, 2.0)
float light_offset = 0.01;   // this offsets all color channels; : hint_range(0.00001, 1.0) 
float alpha = 1.0; //: hint_range(0.0, 1.0) 



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_COLOR vec4 finColor;

  vec2 size = CoronaTexelSize.zw * line_scale;
  
  float outlineA = texture2D(CoronaSampler0, texCoord + vec2(-size.x, 0)).a;
  outlineA += texture2D(CoronaSampler0, texCoord + vec2(0, size.y)).a;
  outlineA += texture2D(CoronaSampler0, texCoord + vec2(size.x, 0)).a;
  outlineA += texture2D(CoronaSampler0, texCoord + vec2(0, -size.y)).a;
  outlineA += texture2D(CoronaSampler0, texCoord + vec2(-size.x, size.y)).a;
  outlineA += texture2D(CoronaSampler0, texCoord + vec2(size.x, size.y)).a;
  outlineA += texture2D(CoronaSampler0, texCoord + vec2(-size.x, -size.y)).a;
  outlineA += texture2D(CoronaSampler0, texCoord + vec2(size.x, -size.y)).a;
  outlineA = min(outlineA, 1.0);
  
  P_COLOR float lineA = light_offset + sin(2.0*3.14*frequency*CoronaTotalTime);
  P_COLOR float lineG = light_offset + sin(2.0*3.14*frequency*CoronaTotalTime + radians(120.0));
  P_COLOR float lineB = light_offset + sin(2.0*3.14*frequency*CoronaTotalTime + radians(240.0));


  vec4 animated_line_color = vec4( lineA, lineG, lineB, alpha );
  
  
  vec4 color = texture2D(CoronaSampler0, texCoord);
  if (rainbow == true){//if rainbow is activated
    finColor = mix(color, animated_line_color, outlineA - color.a);
  }
  if (rainbow == false){//if rainbow not is activated and you pick a color
    finColor = mix(color, line_color , outlineA - color.a);
  }


  return finColor;
}
]]

return kernel



--[[




--]]