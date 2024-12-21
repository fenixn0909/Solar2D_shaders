
--[[

  https://godotshaders.com/shader/dithering-screen-door-transparency/
  KingToot
  May 27, 2024

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "dithering"

--Test
-- kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = .5,
    min = 0,
    max = 1,
    index = 0, 
  },
}


kernel.fragment =
[[

//uniform float intensity = 0.0; // : hint_range(0.0, 1.0, 0.05)

P_DEFAULT float progress = CoronaVertexUserData.x;
//----------------------------------------------

//vec4 backBG = vec4(0,0,0,0);


// --- Constants --- //
const mat4 THRESHOLD_MATRIX = mat4(
    vec4(1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0),
    vec4(13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0),
    vec4(4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0),
    vec4(16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0));

//----------------------------------------------

int modi( int a, int b ){ return (a)-((a)/(b))*(b); }

//----------------------------------------------

P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;
P_UV vec2 iResolution = 1.0 / TEXTURE_PIXEL_SIZE;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV);
    //progress = abs(sin(CoronaTotalTime));

    //----------------------------------------------

    vec2 uv = UV / CoronaTexelSize.zw;
    //float player_dist = (clamp(1.0 - distance(SCREEN_UV / SCREEN_PIXEL_SIZE, player_position / SCREEN_PIXEL_SIZE) * SCREEN_PIXEL_SIZE.x / radius, 0.0, 1.0)) * player_influence * step(0.01, progress);
    //COLOR.a *= step(0.0, THRESHOLD_MATRIX[int(uv.x) % 4][int(uv.y) % 4] - progress - player_dist);

    //COLOR.a *= step(0.0, THRESHOLD_MATRIX[int(uv.x) % 4][int(uv.y) % 4] - progress);
    COLOR.a *= step(0.0, THRESHOLD_MATRIX[ modi( int(uv.x), 4) ][ modi( int(uv.y), 4) ] - progress);
    //modi( uv.x, 4)


    COLOR.rgb *= COLOR.a;

    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


