 
--[[
    https://godotshaders.com/shader/2d-drop-shadow/
    ArtcadeDev
    January 23, 2023
    
    https://godotshaders.com/shader/2d-topdown-shadow-that-goes-out-of-bounds/
    Bettiold
    December 9, 2023

    
    Mixing and Simplified Version
    Restriction: Shadown won't cast outside of the rect.

--]]

local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "shadow"
kernel.name = "drop2D"


kernel.vertexData =
{
  { name = "OffX",      default = 64, min = -128, max = 128, index = 0, },
  { name = "OffY",      default = 64, min = -128, max = 128, index = 1, },
  { name = "Rot",       default = 0, min = -10, max = 10, index = 2, },
  { name = "Scale",     default = 1.25, min = 1.1, max = 3, index = 3, },
} 

kernel.fragment =
[[

float OffX = CoronaVertexUserData.x;
float OffY = CoronaVertexUserData.y;
float Rot = CoronaVertexUserData.z;
float Scale = CoronaVertexUserData.w;

vec2 OffsetUV = vec2( OffX*10, OffY*10 );
vec4 Col_Shadow = vec4 ( 1.0, 0.0, 0.0, .8);

float Zoom = 1.25;

uniform sampler2D TEXTURE;

//----------------------------------------------

float when_gt(float x, float y) { //greater than return 1
  return max(sign(x - y), 0.0);
}

// -----------------------------------------------

P_COLOR vec4 COLOR = vec4(0);
vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    mat2 rotation_matrix = mat2(vec2(cos(Rot), sin(Rot)), vec2(-sin(Rot), cos(Rot)));
    mat2 scale_matrix = mat2(vec2(1.0, 0.0),vec2(0.0, TEXTURE_PIXEL_SIZE.x/TEXTURE_PIXEL_SIZE.y));
    vec2 uv = ( ((UV * 2.0 - 1.0)* Zoom +1.0) / 2.0-vec2(0.5))*scale_matrix;
    vec2 uv_rot = uv * rotation_matrix * scale_matrix + vec2(0.5);
    vec2 uv_shadow = uv * Scale * rotation_matrix * scale_matrix + vec2(0.5);
    uv = (uv * rotation_matrix + vec2(0.25)*OffsetUV*rotation_matrix)* scale_matrix +vec2(0.5);
    //----------------------------------------------

    vec4 col_origin = texture2D(TEXTURE, uv_rot, 0.0);
    //vec4 col_offset = texture2D(TEXTURE, uv_rot - uv * TEXTURE_PIXEL_SIZE * 1 , 0.0);
    vec4 col_offset = texture2D(TEXTURE, uv_shadow  - uv * TEXTURE_PIXEL_SIZE * 1 , 0.0);

    float result = when_gt( col_offset.a - col_origin.a, 0 );
    COLOR = mix( col_origin, Col_Shadow, result  );

    //----------------------------------------------
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


