 
--[[
    https://godotshaders.com/shader/square-pixelation/
    Exuin
    September 16, 2021
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "pixel"
kernel.name = "square"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "size",
    default = 1,
    min = 1,
    max = 100,
    index = 0, 
  },
}


kernel.fragment =
[[


int pixel_size = int(CoronaVertexUserData.x); //: hint_range(1, 100)


//----------------------------------------------



//-----------------------------------------------
P_COLOR vec4 COLOR;
P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
//P_DEFAULT float TIME = CoronaTotalTime; // Test

//-----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  // pixel_size = int( floor(TIME/1) ); // Test
  //----------------------------------------------
  vec2 pos = UV / TEXTURE_PIXEL_SIZE;
  vec2 square = vec2(float(pixel_size), float(pixel_size));
  vec2 top_left = floor(pos / square) * square;
  vec4 total = vec4(0., 0., 0., 0.);
  for (int x = int(top_left.x); x < int(top_left.x) + pixel_size; x++){
    for (int y = int(top_left.y); y < int(top_left.y) + pixel_size; y++){
      total += texture2D(CoronaSampler0, vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE);
    }
  }
  COLOR = total / float(pixel_size * pixel_size);
  //----------------------------------------------
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    

--]]


