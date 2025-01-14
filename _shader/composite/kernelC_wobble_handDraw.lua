
--[[
  Origin Author: roughskin
  https://godotshaders.com/author/roughskin/
  
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "wobble"
kernel.name = "handDraw"

kernel.isTimeDependent = true


kernel.vertexData =
{
  { name = "Speed",     default = 3, min = 0, max = 10, index = 0, },
  { name = "Strength",  default =  0.012, min = 0, max = 0.031, index = 1, },
  { name = "Frames",      default = 30, min = 0, max = 1000, index = 2, },
} 


kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Strength = CoronaVertexUserData.y;
float Frames = CoronaVertexUserData.z;
//----------------------------------------------

int frames = int(Frames);

//----------------------------------------------
float clock(float time){
  float fframes = float(frames);
  return floor(mod(time * Speed, fframes)) / fframes;
}

//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  float c = clock(CoronaTotalTime*5); //Get clock frame
  
  vec4 offset = texture2D(CoronaSampler1, vec2(UV.x + c, UV.y + c) * 0.5) * Strength; //Get offset 
  P_COLOR vec4 COLOR = texture2D(CoronaSampler0, vec2(UV.x,UV.y) + offset.xy - vec2(0.5,0.5)*Strength); //We need to remove the displacement 
  
  return CoronaColorScale(COLOR);
}
]]

return kernel
