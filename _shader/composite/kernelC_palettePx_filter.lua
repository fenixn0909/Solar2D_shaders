
--[[
  Origin Author: Bombardlos
  https://godotshaders.com/shader/palette-filter-and-pixelate-combined/

  This is just two shaders combined, resulting in the background in my pic.
   
  Here are the projects separately
   
  https://godotshaders.com/shader/palette-filter-for-3d-and-2d/
  https://godotshaders.com/shader/pixelate/
   
   
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "palettePx"
kernel.name = "filter"

--Test
kernel.isTimeDependent = true

kernel.vertexData   = {
  {
    name = "texDiffRatioX",
    default = 1,
    min = 0,
    max = 32,  
    index = 0,    
  },
  {
    name = "texDiffRatioY",
    default = 1,
    min = 0,
    max = 32,  
    index = 1,    
  },
  
}


kernel.fragment =
[[
vec2 texDiffRatio = vec2( CoronaVertexUserData.x, CoronaVertexUserData.y );

//----------------------------------------------

uniform bool isFlip = false;
//uniform sampler2D gradient; : hint_black // It can be whatever palette you want
uniform int amount = 2000;


//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  //----------------------------------------------
  //vec2 grid_uv = round(UV * float(amount)) / float(amount);
  vec2 grid_uv = floor(UV * float(amount) + 0.5) / float(amount);

  vec4 col = texture2D(CoronaSampler0,grid_uv);
  float alpha = col.a;
  float lum = dot(col.rgb,vec3(0.2126,0.7152,0.0722)); // luminance
  
  col = texture2D(CoronaSampler1,vec2(abs(float(isFlip) - lum),0));
  

  COLOR = col;
  COLOR.a = alpha;
  COLOR.rgb *= COLOR.a;
  //----------------------------------------------
  
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


