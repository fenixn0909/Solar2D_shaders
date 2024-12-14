
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
//----------------------------------------------

uniform float Range = .7;
uniform float Speed  = .35;
uniform float Strength = 16.;

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
P_DEFAULT float TIME = CoronaTotalTime; // * speed

P_COLOR vec4 COLOR;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //progress = abs(sin(CoronaTotalTime));
    
    float progress = sin(TIME * Speed);
    
    //----------------------------------------------

    vec2 aspect = vec2(TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y, 1.0);
    vec2 center = 0.5 * aspect;
    
    vec2 uv = UV / aspect;
    uv -= center;
    
    float d = length(uv);
    
    
    //vortex
    float cTime = Strength * progress;
    d = smoothstep(0., Range, Range - d) * cTime;
    uv *= rotate(d);
    
    //shrink
    float edge = 1. * abs(progress);
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


