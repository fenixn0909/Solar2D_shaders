
--[[
  Origin Author: godotshaders
  https://godotshaders.com/author/godotshaders/
  
  A pixel transition effect where the screen fills with pixels. Use it on an overlay ColorRect or Sprite.  

  This shader is made and contributed by, Tsar333.
  https://github.com/BlooRabbit/Godot-shaders

  // Pixel transition shader
  // Adapted from a shadertoy shader by iJ01 (https://www.shadertoy.com/view/Xl2SRd)


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "scrnPixel"

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Progress",   default = .5, min = 0, max = 1, index = 0, },
  { name = "R",       default = 0.0, min = 0, max = 1, index = 1, },
  { name = "G",       default = 0.0, min = 0, max = 1, index = 2, },
  { name = "B",       default = 0.0, min = 0, max = 1, index = 3, },
} 


kernel.fragment =
[[

float Progress = CoronaVertexUserData.x;
float R = CoronaVertexUserData.y;
float G = CoronaVertexUserData.z;
float B = CoronaVertexUserData.w;
float A = 1;

P_COLOR vec4 Col_Fill = vec4( R, G, B, A);

vec2 ScreenRate = vec2( 1, 1 );

//----------------------------------------------
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,96.233))) * 43758.5453);
}
//----------------------------------------------
P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

  P_UV vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;
  P_UV vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
  P_UV vec2 FRAGCOORD = UV * iResolution;
  vec2 uv = FRAGCOORD.xy / iResolution.xy;

  float resolution = 5.0;
  vec2 lowresxy = vec2(
    floor(FRAGCOORD.x / resolution),
    floor(FRAGCOORD.y / resolution)
  );
  Progress*=1.6;
  if(abs(sin(Progress)) > rand(lowresxy)){
  //COLOR = vec4(uv,0.5+0.5*sin(5.0 * FRAGCOORD.x),1.0);
  //COLOR.rgb *= Col_Fill.rgb;
  COLOR = Col_Fill;
  // Worked Rainbow Color
  //COLOR = vec4(UV,0.5+0.5*sin(5.0 * FRAGCOORD.x),1.0); 
  }else{
  COLOR = vec4(0.0,0.0,0.0,0.0);
  // change to COLOR = vec4(0.0,0.0,0.0,1.0); to make black pixels
  } 

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


