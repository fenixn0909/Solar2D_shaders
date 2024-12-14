--local object = display.newImage("image.png")

--object.fill.effect = "filter.custom.pixeloutline"
--object.fill.effect.intensity   = 0.0 to 10.0 -- how thick is it
--object.fill.effect.r, g, b   = 4 to 50 -- color

--So you will need to leave a 1px border around the image for the outline to work. 
--In this example there's no border on the bottom, so his feet aren't outlined.

--Add Pixelate?

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "linePx"
kernel.name = "outter"

kernel.vertexData  = {
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
    default = 0.5,
    min     = 0,
    max     = 1,
    index   = 2,
    },{
    name    = "size",
    default = 0.1,
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
  slot_size = ( CoronaTexelSize.zw * 1);
  sample_uv_offset = ( slot_size * 0.5 );
  return position;
}
]]

kernel.fragment = 
[[

P_NORMAL float stroke = CoronaVertexUserData.w;

varying P_UV vec2 slot_size;
varying P_UV vec2 sample_uv_offset;


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{

  P_COLOR vec4 v_lineColor = vec4( CoronaVertexUserData.x, CoronaVertexUserData.y, CoronaVertexUserData.z, 1);
  P_UV vec2 uv_pix = ( sample_uv_offset + ( floor( texCoord / slot_size ) * slot_size ) );
  P_COLOR vec4 texColor = texture2D( CoronaSampler0, uv_pix );

  if (texColor.a == 0.0)
  {
  P_NORMAL float w = stroke * CoronaTexelSize.z; //x
  P_NORMAL float h = stroke * CoronaTexelSize.w; //y
      if (texture2D(CoronaSampler0, texCoord + vec2(w, 0.0)).a != 0.0 ||
          texture2D(CoronaSampler0, texCoord + vec2(-w, 0.0)).a != 0.0 ||
          texture2D(CoronaSampler0, texCoord + vec2(0.0, h)).a != 0.0 ||
          texture2D(CoronaSampler0, texCoord + vec2(0.0,-h)).a != 0.0)
          texColor.rgb = v_lineColor.rgb;
  }
  return CoronaColorScale(texColor);
}
]]
return kernel
-- graphics.defineEffect( kernel )