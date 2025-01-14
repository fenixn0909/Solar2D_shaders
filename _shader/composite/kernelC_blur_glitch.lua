
--[[
  Origin Author: roughskin
  https://godotshaders.com/author/roughskin/

--]]

local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "blur"
kernel.name = "glitch"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",     default = 1, min = 0, max = 10, index = 0, },
  { name = "Strength",  default =  0.04, min = 0, max = 0.2, index = 1, },
  { name = "AM_X",    default = 1.1, min = -5, max = 5, index = 2, },
  { name = "AM_Y",    default = 1.1, min = -5, max = 5, index = 3, },
} 

kernel.fragment =
[[


float Speed = CoronaVertexUserData.x;
float Strength = CoronaVertexUserData.y;
float AM_X = CoronaVertexUserData.z;
float AM_Y = CoronaVertexUserData.w;

//----------------------------------------------


//----------------------------------------------


float rand (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}
//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  
  //Random Offset
  vec2 randSeed = UV + CoronaTotalTime;
  P_RANDOM float offRnd = rand(randSeed) - 0.5;

  //Best if offset translate around circle
  float timeMult = 10000 * Speed;
  float degree = CoronaTotalTime * timeMult; 
  float AM = 1.1;
  
  float offX = sin(radians(degree)) * offRnd * AM_X;
  float offY = sin(radians(degree)) * offRnd * AM_Y;
  
  vec4 offset = texture2D(CoronaSampler1, vec2(UV.x + offX, UV.y + offY)) * Strength; //Get offset 
  P_COLOR vec4 COLOR = texture2D(CoronaSampler0, vec2(UV.x,UV.y) + offset.xy - vec2(0.5,0.5)*Strength); //We need to remove the displacement 
  
  return CoronaColorScale(COLOR);
}
]]

return kernel
