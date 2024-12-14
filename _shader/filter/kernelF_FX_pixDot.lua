--[[
  Origin Author: jijiji
  https://godotshaders.com/author/jijiji/

  from world of zero youtube: https://www.youtube.com/watch?v=RD9qvXO_Ha4

  and make pixelate align center.




--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "pixDot"

kernel.vertexData   = {
  {
    name    = "amountX",
    default = 128,
    min     = 0,
    max     = 1024,
    index   = 0,
    },{
    name    = "amountY",
    default = 128,
    min     = 0,
    max     = 1024,
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

//uniform float amount_x = 216; // : hint_range(0, 128) 
//uniform float amount_y = 216; // : hint_range(0, 128) 

float amount_x = CoronaVertexUserData.x;
float amount_y = CoronaVertexUserData.y;


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  P_COLOR vec4 v_lineColor = vec4( CoronaVertexUserData.x, CoronaVertexUserData.y, CoronaVertexUserData.z, 1);
  P_UV vec2 uv_pix = ( sample_uv_offset + ( floor( texCoord / slot_size ) * slot_size ) );
  P_UV vec2 UV = texCoord;
  //P_COLOR vec4 texColor = texture2D( CoronaSampler0, uv_pix );


  vec2 pos = uv_pix;
  pos *= vec2(amount_x, amount_y);
  pos = ceil(pos);
  pos /= vec2(amount_x, amount_y);
  vec2 cellpos = pos - (0.5 / vec2(amount_x, amount_y));
  
  pos -= UV;
  pos *= vec2(amount_x, amount_y);
  pos = vec2(1.0) - pos;
  
  float dist = distance(pos, vec2(0.5));

  vec4 c = texture2D(CoronaSampler0, cellpos);
  
  P_COLOR vec4 COLOR = c * step(0.0, (0.5* c.a) - dist);



  return CoronaColorScale(COLOR);
}
]]
return kernel
--[[



--]]