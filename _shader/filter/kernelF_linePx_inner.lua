

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "linePx"
kernel.name = "inner"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",   default = 20, min = 0, max = 50, index = 0, },
  { name = "Size",    default = 10, min = 0, max = 50, index = 1, },
} 


kernel.vertex =
[[
varying P_UV vec2 Slot_Size;
varying P_UV vec2 sample_uv_offset;
P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{
  P_UV float numPixels = 1;
  Slot_Size = ( u_TexelSize.zw * numPixels );
  sample_uv_offset = ( Slot_Size * 0.5 );
  return position;
}
]]



kernel.fragment = [[

varying P_UV vec2 Slot_Size;
varying P_UV vec2 sample_uv_offset;
//----------------------------------------------

float Speed = CoronaVertexUserData.x;
float Size = CoronaVertexUserData.y;
//----------------------------------------------

P_COLOR vec3 Col_Line = vec3( 1.0, 1.0, 1.0 );

//----------------------------------------------

P_COLOR vec4 COLOR = vec4(0.0);
P_DEFAULT float TIME = CoronaTotalTime * Speed;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    P_COLOR vec4 v_lineColor = vec4( Col_Line, 1);
    P_UV vec2 uv_pix = ( sample_uv_offset + ( floor( UV / Slot_Size ) * Slot_Size ) );
    COLOR = texture2D( CoronaSampler0, uv_pix );

    if (COLOR.a != 0.0) //Inline
    {
        P_NORMAL float w = Size * CoronaTexelSize.z;
        P_NORMAL float h = Size * CoronaTexelSize.w;
    

        if ((texture2D(CoronaSampler0, UV + vec2(w, 0.0)).a == 0.0  ||
            texture2D(CoronaSampler0, UV + vec2(-w, 0.0)).a == 0.0 ||
            texture2D(CoronaSampler0, UV + vec2(0.0, h)).a == 0.0 ||
            texture2D(CoronaSampler0, UV + vec2(0.0,-h)).a == 0.0))
        {
            float mx = abs(sin( TIME ));
            COLOR.rgb = mix( COLOR.rgb, v_lineColor.rgb, mx);
        }
          
    }
    
    //----------------------------------------------
    COLOR.rgb *= COLOR.a;
    return CoronaColorScale(COLOR);
}
]]
return kernel
-- graphics.defineEffect( kernel )