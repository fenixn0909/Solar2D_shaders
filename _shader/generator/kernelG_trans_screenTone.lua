
--[[
    Origin Author: vanviethieuanh
    https://godotshaders.com/author/vanviethieuanh/

    Find and go #VARIATION and tweak them for different patterns
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "screenTone"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Progress",      default = 0.5, min = 0, max = 1, index = 0, },
  { name = "Tween",         default = .85, min = 0, max = 1, index = 1, },
  { name = "SizeX",         default = 3.2, min = 0, max = 25, index = 2, },
  { name = "SizeY",         default = 3.2, min = 0, max = 25, index = 3, },
} 

kernel.fragment =
[[

float Progress = CoronaVertexUserData.x;
float Tween = CoronaVertexUserData.y; 
float SizeX = CoronaVertexUserData.z;
float SizeY = CoronaVertexUserData.w;

//----------------------------------------------

vec4 in_color = vec4( 0.0, 0.0, 0.0, 1.0); //:hint_color
vec4 out_color = vec4( 2.0, 2.0, 2.0, .25); //:hint_color

vec2 size = vec2( SizeX*10, SizeY*10 );

//----------------------------------------------

P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    P_UV vec2 iTexelSize = vec2(.001, .001);
    vec2 a = (1./iTexelSize) / size;

    vec2 uv=UV;
    uv *= a;

    vec2 i_uv = floor(uv);
    vec2 f_uv = fract(uv);

    float progress = Progress * 2.5 - 1.5;
    //----------------------------------------------

    // Left to Right      #VARIATION
    float wave = max(0.,i_uv.x/(a.x) - progress);

    // Top to Bottom      #VARIATION
    //float wave = max(0.,i_uv.y/(a.y) - progress);

    vec2 center = f_uv*2.-1.;
    float circle = length(center);
    circle = 1. - step(wave,circle);

    //vec4 color = mix(in_color, out_color, step(0.5, Tween));
    vec4 color = mix(in_color, out_color, Tween * Progress );

    COLOR = vec4(circle) * color;

    //----------------------------------------------
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


