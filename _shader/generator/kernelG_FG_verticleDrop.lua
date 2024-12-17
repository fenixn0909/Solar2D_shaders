
--[[
    https://godotshaders.com/shader/vertical-drops/
    FencerDevLog
    September 16, 2024

    Great for rain, snow, fireflies

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FG"
kernel.name = "verticleDrop"


kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",         default = 2.0, min = -10, max = 10, index = 0, },
  { name = "Density",       default = 800, min = 50, max = 1000, index = 1, },
  { name = "Trail",         default = 77, min = -50, max = 800, index = 2, },
  { name = "Compression",   default = 1.1, min = -5, max = 5, index = 3, },
} 


kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Density = CoronaVertexUserData.y;
float Trail = CoronaVertexUserData.z;
float Compression = CoronaVertexUserData.w;

//----------------------------------------------
//----------------------------------------------

uniform vec3 color = vec3(0.5, 0.7, .9); // : source_color 
uniform float brightness = 100.5; //: hint_range(0.1, 10.0, 0.1)

float PI = 3.14159265359;

// -----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //----------------------------------------------

    vec2 uv = -UV;
    float time = TIME * Speed;
    uv.x *= Density;
    vec2 duv = vec2(floor(uv.x), uv.y) * Compression;
    float offset = sin(duv.x);
    float fall = cos(duv.x * 30.0);
    float trail = mix(100.0, Trail, fall);
    float drop = fract(duv.y + time * fall + offset) * trail;
    drop = 1.0 / drop;
    drop = smoothstep(0.0, 1.0, drop * drop);
    drop = sin(drop * PI) * fall * brightness;
    float shape = sin(fract(uv.x) * PI);
    drop *= shape * shape;
    COLOR = vec4(color * drop, 0.0);

    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    
--]]


