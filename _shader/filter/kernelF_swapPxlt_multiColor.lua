-- 4 color pixel swapping

-- USAGE:
-- require ("multiswap')

--local object = display.newImage("image.png")

--object.fill.effect = "filter.custom.multiswap"
--object.fill.effect.keys = {
--  213/255,  95/255,  96/255, 1,
--  141/255,  76/255, 101/255, 1,
--  218/255, 177/255, 132/255, 1,
--  160/255, 125/255, 121/255, 1
--}
--object.fill.effect.colors = {
--  243/255, 133/255,  11/255, 1,
--  186/255, 102/255,  10/255, 1,
--  102/255,  63/255,  21/255, 1,
--   92/255,  50/255,   4/255, 1
--}

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "swapPxlt"
kernel.name = "multiColor"

-- Expose effect parameters using vertex data
kernel.uniformData = {
  {
    name = "matAimC",
    default = {
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    min = {
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0
    },
    max = {
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    type="mat4",
    index = 0, -- u_UserData0
  },
  {
    name = "matToC",
    default = {
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0
    },
    min = {
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 0.0
    },
    max = {
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    },
    type="mat4",
    index = 1, -- u_UserData1
  },
}


kernel.fragment =
[[

uniform P_COLOR mat4 u_UserData0; // trgtC
uniform P_COLOR mat4 u_UserData1; // toC
P_NORMAL float deadZone = 0.01;

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  //FRAGCOORD Snippet
  P_UV vec2 sample_uv_offset = ( CoronaTexCoord.zw * 0.5 );
  P_UV vec2 uv = ( sample_uv_offset + ( floor( texCoord / CoronaTexCoord.zw ) * CoronaTexCoord.zw ) );

  P_COLOR vec4 texColor = texture2D( u_FillSampler0, uv );
  
  for(int i = 0; i < 4; i++){
      P_COLOR vec4 keys = u_UserData0[i];
      P_COLOR vec4 colors = u_UserData1[i];
      if ((abs(texColor[0] - keys[0]) < deadZone) && (abs(texColor[1] - keys[1]) < deadZone) && (abs(texColor[2] - keys[2]) < deadZone)){
          texColor = colors;
          break;
      }
  }

  return CoronaColorScale(texColor);
}
]]


return kernel
-- graphics.defineEffect( kernel )