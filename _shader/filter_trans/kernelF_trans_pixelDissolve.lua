
--[[

  Origin Author: cak3_lover
  https://godotshaders.com/shader/pixelate-into-view-texture-resolution/
  
  I improved "this" shader such that the depixelization occurs at texture resolution
  
  (If you want to customize the pixel resolution I’ve uploaded "another shader")

  "this": https://godotshaders.com/shader/pixelate-into-view-texture-resolution/
  "another shader": https://godotshaders.com/shader/pixelate-into-view-custom-resolution/

  My first shader(s)!
  Enjoy 🙂

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "pixelDissolve"

--Test
-- kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = 1,
    min = 0,
    max = 1,
    index = 0, 
  },
  {
    name = "vd_resolution",
    default = 5000,
    min = 1,
    max = 9999,
    index = 1, 
  },
}


kernel.fragment =
[[
P_DEFAULT float progress = CoronaVertexUserData.x;
vec4 colorBG = vec4(0,0,0,0);
P_DEFAULT float vd_resolution = CoronaVertexUserData.y;

//----------------------------------------------
//uniform float time = 1.0; //:hint_range(0.0, 1.57, 0.001) <- progress
const float pRate = 1.57; // profressRate

// The smaller value, the lager pxBlock. 5000 ~= minimum pxSize
P_DEFAULT vec2 custom_resolution = vec2( vd_resolution, vd_resolution ); 




float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,96.233))) * 43758.5453);
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  progress *= pRate;
  progress = pRate - progress; // Inversion  
  //----------------------------------------------
  
  vec2 within_texture_pixel=vec2(floor(UV * custom_resolution));
  vec4 color= texture2D( CoronaSampler0,  UV);
  
  /*
  vec2 texture_resolution = 1.0 / CoronaTexelSize.zw;
  vec2 within_texture_pixel=floor(UV * texture_resolution);
  vec4 color= texture2D(CoronaSampler0,UV);
  */

  if(sin(progress) > rand(within_texture_pixel))
    COLOR = color;
  else
    COLOR = vec4(0.0,0.0,0.0,0.0);

  //----------------------------------------------
  
  
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


