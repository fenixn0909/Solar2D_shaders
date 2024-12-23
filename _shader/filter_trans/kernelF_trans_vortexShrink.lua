
--[[
    https://godotshaders.com/shader/vortex-and-shrink/
    RayL019
    May 29, 2024
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "vortexShrink"


kernel.vertexData =
{
  { name = "Progress", default = .5, min = 0, max = 1, index = 0, },
  { name = "Range", default = .7, min = 0, max = 5, index = 1, },
  { name = "Strength", default = 15., min = 0, max = 100, index = 2, },
}


kernel.fragment =
[[
float Progress = CoronaVertexUserData.x;
float Range = CoronaVertexUserData.y;
float Strength = CoronaVertexUserData.z;

//----------------------------------------------

uniform sampler2D iChannel0;



//----------------------------------------------
mat2 rotate(float a)
{
    float s = sin(a);
    float c = cos(a);
    return mat2(vec2(c,-s),vec2(s,c));
}

//----------------------------------------------

vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;

P_COLOR vec4 COLOR;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    
    //----------------------------------------------

    vec2 aspect = vec2(TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y, 1.0);
    vec2 center = 0.5 * aspect;
    
    vec2 uv = UV / aspect;
    uv -= center;
    
    float d = length(uv);
    
    
    //vortex
    float cTime = Strength * Progress;
    d = smoothstep(0., Range, Range - d) * cTime;
    uv *= rotate(d);
    
    //shrink
    float edge = 1. * abs(Progress *.55);
    uv = uv + normalize(uv) * edge;
    
    uv += center;
    uv /= aspect;
    if (uv.x > 1. || uv.y > 1. || uv.x < 0. || uv.y < 0.) {
        COLOR = vec4(0., 0., 0., 0.);
    } else {
        COLOR = texture2D(iChannel0, uv);
    }
    

    //----------------------------------------------
    //COLOR.rgb *= COLOR.a;


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


