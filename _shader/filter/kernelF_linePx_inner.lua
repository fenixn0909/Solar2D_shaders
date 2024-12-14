
-- Add Alpha?

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "linePx"
kernel.name = "inner"

kernel.isTimeDependent = true

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
    max     = 32,
    index   = 3,
  },
}

kernel.vertex =
[[
varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;
P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{
  P_UV float numPixels = 1;
  slot_size = ( u_TexelSize.zw * numPixels );
  sample_uv_offset = ( slot_size * 0.5 );
  return position;
}
]]

kernel.fragment = [[

varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;

P_NORMAL float size = CoronaVertexUserData.w;

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    P_COLOR vec4 v_lineColor = vec4( CoronaVertexUserData.x, CoronaVertexUserData.y, CoronaVertexUserData.z, 1);
    P_UV vec2 uv_pix = ( sample_uv_offset + ( floor( texCoord / slot_size ) * slot_size ) );
    P_COLOR vec4 texColor = texture2D( CoronaSampler0, uv_pix );

    if (texColor.a != 0.0) //Inline
    {
    P_NORMAL float w = size * CoronaTexelSize.z;
    P_NORMAL float h = size * CoronaTexelSize.w;
    

      if ((texture2D(CoronaSampler0, texCoord + vec2(w, 0.0)).a == 0.0  ||
        texture2D(CoronaSampler0, texCoord + vec2(-w, 0.0)).a == 0.0 ||
        texture2D(CoronaSampler0, texCoord + vec2(0.0, h)).a == 0.0 ||
        texture2D(CoronaSampler0, texCoord + vec2(0.0,-h)).a == 0.0))
      {
        float mx = abs(sin(CoronaTotalTime));
        texColor.rgb = mix( texColor.rgb, v_lineColor.rgb, mx);
      }
          
    }

    texColor.rgb *= texColor.a;
    return CoronaColorScale(texColor);
}
]]
return kernel
-- graphics.defineEffect( kernel )