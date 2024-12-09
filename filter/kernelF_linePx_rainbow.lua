
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


kernel.vertex =
[[
varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;
P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{
  P_UV float numPixels = 1;
  slot_size = ( u_TexelSize.zw * numPixels );
  sample_uv_offset = ( slot_size * 0.5 );
  return position;
}
]]


kernel.fragment =
[[

varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;


bool rainbow  = true; //Activate the rainbow or select you color
vec4 line_color = vec4(1.0, 1.0, 1.0, 1.0); //color line : hint_color 
float line_scale = 2;    // thickness of the line : hint_range(0, 20) 
float frequency  = 3;  // frequency of the rainbow : hint_range(0.0, 12.0)
//float light_offset = 0.1;   // this offsets all color channels; : hint_range(0.00001, 1.0) 
vec3 light_offset = vec3(-0.0, -0.2, -0.1);   // this offsets all color channels; : hint_range(0.00001, 1.0) 


float alpha = 1.0; //: hint_range(0.0, 1.0) 



P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_COLOR vec4 finColor;

  vec2 size = CoronaTexelSize.zw * line_scale;
  P_UV vec2 uv_pix = ( sample_uv_offset + ( floor( texCoord / slot_size ) * slot_size ) );
  
  float outlineA = texture2D(CoronaSampler0, uv_pix + vec2(-size.x, 0)).a;
  

  outlineA += texture2D(CoronaSampler0, uv_pix + vec2(0, size.y)).a;
  outlineA += texture2D(CoronaSampler0, uv_pix + vec2(size.x, 0)).a;
  outlineA += texture2D(CoronaSampler0, uv_pix + vec2(0, -size.y)).a;
  outlineA += texture2D(CoronaSampler0, uv_pix + vec2(-size.x, size.y)).a;
  outlineA += texture2D(CoronaSampler0, uv_pix + vec2(size.x, size.y)).a;
  outlineA += texture2D(CoronaSampler0, uv_pix + vec2(-size.x, -size.y)).a;
  outlineA += texture2D(CoronaSampler0, uv_pix + vec2(size.x, -size.y)).a;
  outlineA = min(outlineA, 1.0);
  
  P_COLOR float lineA = light_offset.r + abs(sin(2.0*3.14*frequency*CoronaTotalTime*0.3));
  P_COLOR float lineG = light_offset.g + abs(sin(2.0*3.14*frequency*CoronaTotalTime*0.5 + radians(120.0)));
  P_COLOR float lineB = light_offset.b + abs(sin(2.0*3.14*frequency*CoronaTotalTime*0.7 + radians(240.0)));


  vec4 animated_line_color = vec4( lineA, lineG, lineB, alpha );
  
  
  vec4 color = texture2D(CoronaSampler0, uv_pix);
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