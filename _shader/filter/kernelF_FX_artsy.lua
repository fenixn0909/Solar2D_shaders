--[[
    Origin Author: oli4_vh
    https://godotshaders.com/author/oli4_vh/

    Picks the highest value color in a circle range as the output color.
    Results in a pretty cool effect imo.



--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "artsy"

kernel.vertexData   = {
  {
    name    = "r",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 0,
    },{
    name    = "g",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 1,
    },{
    name    = "b",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 2,
    },{
    name    = "size",
    default = 1,
    min     = 0,
    max     = 4,
    index   = 3,
  },
}


kernel.vertex =
[[
varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;
P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{
  slot_size = ( u_TexelSize.zw * 1);
  sample_uv_offset = ( slot_size * 0.5 );
  return position;
}
]]

kernel.fragment = 
[[

varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;

uniform float size = 1.5;

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 uv_pix = ( sample_uv_offset + ( floor( texCoord / slot_size ) * slot_size ) );
  P_UV vec2 UV = texCoord; //Smooth
  //P_UV vec2 UV = uv_pix; //Pixelate
  
  vec4 c = texture2D(CoronaSampler0, UV, 0.0);
  for (float x = -size; x < size; x++)
  {
    for (float y = -size; y < size; y++)
    {
      if (x*x + y*y > size*size){continue;}
      vec4 new_c = texture2D( CoronaSampler0, UV+CoronaTexelSize.zw * vec2(x, y));
      if (length(new_c) >length(c)){
        c = new_c;
      }
    }
  }

  return CoronaColorScale( c );
}
]]
return kernel
--[[



--]]