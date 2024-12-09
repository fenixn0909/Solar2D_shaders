
--[[
  Origin Author: alxl
  https://godotshaders.com/author/alxl/
  
  A fairly self-explanatory shader for animated stripes. 
  Shader params allow you to adjust the color, speed, and angle of the stripes, as well as the width of the stripes and the gaps between them.

  Increase divisions to get more stripes. 
  Increase stripe_bias to make the stripes thicker than the gaps between them. Note that angle is in radians
  
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "stripes"
kernel.isTimeDependent = true


kernel.vertexData =
{
  {
    name = "textureRatio",
    default = 1,
    min = 0,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "paletteRowCols",
    default = 4,
    min = 1,
    max = 16,     -- 16x16->256
    index = 1,    -- v_UserData.y
  },
}



kernel.vertex =
[[
varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;

P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{ 
  slot_size = vec2( u_TexelSize.z, u_TexelSize.w ) * v_UserData.x; // multiply textureRatio to get matching UV of palette.
  sample_uv_offset = ( slot_size * 0.5 );
  return position;
}
]]

kernel.fragment =
[[

uniform P_DEFAULT vec4 u_resolution;

P_COLOR vec4 color_gap = vec4(0.25, 0.25, 0.25, .50); //: hint_color 
P_COLOR vec4 color_stripe = vec4(1.0, 0.75, 0.0, 1.0);//: hint_color 
P_DEFAULT float divisions = 8.0; // increase for more stripe density
P_DEFAULT float stripe_bias = 1.95; // 1.0 means no stripes; 2.0 means stripes and gaps are equal size
P_DEFAULT float speed = 0.075;
//P_DEFAULT float angle = 0.7854; // in radians
P_DEFAULT float angle = 0.7854; // in radians


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  float w = cos(angle) * texCoord.x + sin(angle) * texCoord.y - speed * CoronaTotalTime;
  
  P_COLOR vec4 finColor;

  if (floor(mod(w * divisions, stripe_bias)) < 0.0001) {
    finColor = color_gap;
  } else {
    finColor = color_stripe;
  }

  return CoronaColorScale(finColor);
}
]]

return kernel


