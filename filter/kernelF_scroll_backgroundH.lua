 
--[[
    https://godotshaders.com/shader/scrolling-background/
    Exuin
    March 14, 2021
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "scroll"
kernel.name = "backgroundH"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "speed",
    default = 1,
    min = -99,
    max = 99,
    index = 0, 
  },
}


kernel.fragment =
[[

float speed = CoronaVertexUserData.x;

//----------------------------------------------



//-----------------------------------------------
P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;
//-----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  //----------------------------------------------
    COLOR = texture2D(CoronaSampler0, vec2(UV.x + TIME * speed, UV.y));
  //----------------------------------------------
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    

--]]


