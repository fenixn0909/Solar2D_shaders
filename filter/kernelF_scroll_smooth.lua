
-- Need: display.setDefault( "textureWrapX", "repeat" )

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "scroll"
kernel.name = "smooth"

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "speedX",
    default = 0.1,
    min = -10,
    max = 10,
    index = 0, -- v_UserData.x
  },
  {
    name = "speedY",
    default = 0.1,
    min = -10,
    max = 10,
    index = 1, -- v_UserData.y
  },
}


kernel.fragment =
[[
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_DEFAULT float offX = CoronaTotalTime* v_UserData.x;
  P_DEFAULT float offY = CoronaTotalTime* v_UserData.y;
  
  P_UV vec2 uv_offset = vec2( texCoord.x + offX, texCoord.y + offY );
  P_COLOR vec4 texColor = texture2D( u_FillSampler0, uv_offset ); 

  return CoronaColorScale(texColor);
}
]]



return kernel