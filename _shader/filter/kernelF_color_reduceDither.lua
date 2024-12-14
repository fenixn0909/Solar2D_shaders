
--[[
  Origin Author: Vildravn
  https://godotshaders.com/shader/color-reduction-and-dither/

  Reduces the values per RGB-channel.

  Can use a checkerboard-dither with variable intensity.



--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "color"
kernel.name = "reduceDither"

--Test
-- kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = .5,
    min = 0,
    max = 1,
    index = 0, 
  },
}


kernel.fragment =
[[
//P_DEFAULT float progress = CoronaVertexUserData.x;
//----------------------------------------------
uniform float colors = 4; //: hint_range(1.0, 16.0);
uniform float dither = 0.2; //: hint_range(0.0, 0.5, 1.2);


//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  //P_UV vec2 UV_Pix = (CoronaTexelSize.zw * 0.5) + ( floor( texCoord / CoronaTexelSize.zw ) * CoronaTexelSize.zw );

  P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
  //P_DEFAULT float TIME = CoronaTotalTime;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------

    vec4 color = texture2D(CoronaSampler0, UV);
      
    float a = floor(mod(UV.x / TEXTURE_PIXEL_SIZE.x, 2.0));
    float b = floor(mod(UV.y / TEXTURE_PIXEL_SIZE.y, 2.0)); 
    float c = mod(a + b, 2.0);
    
    COLOR.r = (floor((color.r * colors + dither) + 0.5) / colors) * c;
    COLOR.g = (floor((color.g * colors + dither) + 0.5) / colors) * c;
    COLOR.b = (floor((color.b * colors + dither) + 0.5) / colors) * c;
    c = 1.0 - c;
    COLOR.r += (floor((color.r * colors - dither) + 0.5) / colors) * c;
    COLOR.g += (floor((color.g * colors - dither) + 0.5) / colors) * c;
    COLOR.b += (floor((color.b * colors - dither) + 0.5) / colors) * c;
  //----------------------------------------------
  

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


