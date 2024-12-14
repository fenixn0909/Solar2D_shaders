
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
  {
    name = "screenWidth",
    default = 64,
    min = 0,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "screenHeight",
    default = 64,
    min = 1,
    max = 9999,     -- 16x16->256
    index = 1,    -- v_UserData.y
  },
}


kernel.fragment =
[[

float time = 1.0;
float screenWidth = CoronaVertexUserData.x;
float screenHeight = CoronaVertexUserData.y;


float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,96.233))) * 43758.5453);
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_COLOR vec4 COLOR;

  // Test
  time = CoronaTotalTime;

  // FRAGCOORD Snippet
  P_UV vec4 FRAGCOORD = gl_FragCoord;
  P_UV vec2 SCREEN_PIXEL_SIZE = 1/ vec2(screenWidth, screenHeight);

  vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
  vec2 uv = FRAGCOORD.xy / iResolution.xy;


  float resolution = 5.0;
  vec2 lowresxy = vec2(
    floor(FRAGCOORD.x / resolution),
    floor(FRAGCOORD.y / resolution)
  );
  
  if(abs(sin(time)) > rand(lowresxy)){
  COLOR = vec4(uv,0.5+0.5*sin(5.0 * FRAGCOORD.x),1.0);

  // Worked Rainbow Color
  //COLOR = vec4(texCoord,0.5+0.5*sin(5.0 * FRAGCOORD.x),1.0); 
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


