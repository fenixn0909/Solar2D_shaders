
--[[
    https://godotshaders.com/shader/pixel-melt/
    ericalfaro
    May 31, 2024
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "pixelMelt"

--Test
-- kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = 1,
    min = 0,
    max = 1,
    index = 0, 
  },
  {
    name = "meltiness",
    default = 1,
    min = 0,
    max = 1,
    index = 1, 
  },
}


kernel.fragment =
[[
float progress = CoronaVertexUserData.x;
float meltiness = CoronaVertexUserData.y; //: hint_range(0.0, 16.0)   // How jagged each band of melting pixels are

//----------------------------------------------

float psuedo_rand(float x) {
    return mod(x * 2048103.0 + cos(x * 1912.0), 1.0);
}

float when_lt(float x, float y) {
  return max(sign(y - x), 0.0);
}

float when_gt(float x, float y) { //greater than return 1
  return max(sign(x - y), 0.0);
}

float when_eq(float x, float y) {
  return 1.0 - abs(sign(x - y));
}

//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV);
    //progress = abs(sin(CoronaTotalTime));
    P_UV vec4 FRAGCOORD = gl_FragCoord;
    P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;

    

    //----------------------------------------------

    vec2 uv = UV;

    
    uv.y -= progress / UV.y; // Move pixels near the top faster

    // Created jagged edges for each pixel on the x-axis 
    uv.y -= progress * meltiness * psuedo_rand(UV.x - mod(UV.x, TEXTURE_PIXEL_SIZE.x));

    COLOR = texture2D( CoronaSampler0, uv );

    // "delete" pixels out of range
    COLOR.a = COLOR.a * when_gt( uv.y, 0.0 );
    //COLOR.a = COLOR.a * -when_lt( uv.y, 0.0 );

    //if (uv.y <= 0.0) {
        //COLOR.a = 0.0;
    //}
    

    //----------------------------------------------
    COLOR.rgb *= COLOR.a;


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


