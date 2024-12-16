
--[[
    https://godotshaders.com/shader/2d-spiral-effect/
    FencerDevLog
    March 4, 2024

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "spiral2D"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",         default = 4, min = -50, max = 50, index = 0, },
  { name = "Freq",          default = 12, min = -45, max = 45, index = 1, },
  { name = "Bright",        default = 5, min = 1, max = 20, index = 2, },
  { name = "Octaves",      default = 4, min = 1, max = 10, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Freq = CoronaVertexUserData.y;
float Bright = CoronaVertexUserData.z;
float Octaves = CoronaVertexUserData.w;
//----------------------------------------------
vec2 resolution = vec2( 1, 1 );
//----------------------------------------------

uniform vec3 spiral_color = vec3(0.2, 0.6, 0.3); //: source_color 
uniform float balance = 1.5;    //: hint_range(0.0, 1.0, 0.01)

//uniform float Freq = 8.0;  //: hint_range(1.0, 10.0, 0.1)
//uniform float Speed = 8.0;      //: hint_range(1.0, 20.0, 0.1)
//uniform float Bright = 5.0; //: hint_range(1.0, 10.0, 0.1)
//uniform float Octaves = 42.0;    //: hint_range(1.0, 10.0, 1.0)

#define TAU 6.28318530718

//----------------------------------------------

float draw_spiral(vec2 uv, float rotation) {
    float uv_radius = length(uv);
    float uv_phi = atan(uv.y, uv.x) + rotation;
    float spiral_phi = (log(uv_radius) * Freq - uv_phi) / TAU;
    float spiral_ceil_radius = exp((TAU * ceil(spiral_phi) + uv_phi) / Freq);
    float spiral_floor_radius = exp((TAU * floor(spiral_phi) + uv_phi) / Freq);
    return mix(mix(abs(uv_radius - spiral_ceil_radius), abs(uv_radius - spiral_floor_radius), balance), max(abs(uv_radius - spiral_ceil_radius), abs(uv_radius - spiral_floor_radius)), balance);
}

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------

    vec2 uv = UV - 0.5;
    uv.x *= resolution.x / resolution.y;
    float spiral = 0.0;
    for (float i = 0.0; i < Octaves; i += 1.0) {
        spiral += draw_spiral(uv, TIME * Speed * (0.5 + sin(i)));
    }
    spiral /= Octaves;
    vec3 color = spiral * spiral_color;
    COLOR = vec4(color * Bright, 1.0);

    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


