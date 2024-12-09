
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
  {
    name = "textPxW",
    default = 600,
    min = 0,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "textPxH",
    default = 2000,
    min = 1,
    max = 9999,     
    index = 1,    -- v_UserData.y
  },
}




kernel.fragment =
[[

float textPxW = CoronaVertexUserData.x;
float textPxH = CoronaVertexUserData.y;
vec2 resolution = vec2( textPxW, textPxH );
//uniform vec2 resolution = vec2(400.0, 400.0);
//----------------------------------------------


#define TAU 6.28318530718



uniform vec3 spiral_color = vec3(0.2, 0.6, 0.3); //: source_color 
uniform float frequency = 8.0;  //: hint_range(1.0, 10.0, 0.1)
uniform float speed = 8.0;      //: hint_range(1.0, 20.0, 0.1)
uniform float brightness = 5.0; //: hint_range(1.0, 10.0, 0.1)
uniform float balance = 0.5;    //: hint_range(0.0, 1.0, 0.01)
uniform float octaves = 4.0;    //: hint_range(1.0, 10.0, 1.0)

//----------------------------------------------

float draw_spiral(vec2 uv, float rotation) {
    float uv_radius = length(uv);
    float uv_phi = atan(uv.y, uv.x) + rotation;
    float spiral_phi = (log(uv_radius) * frequency - uv_phi) / TAU;
    float spiral_ceil_radius = exp((TAU * ceil(spiral_phi) + uv_phi) / frequency);
    float spiral_floor_radius = exp((TAU * floor(spiral_phi) + uv_phi) / frequency);
    return mix(mix(abs(uv_radius - spiral_ceil_radius), abs(uv_radius - spiral_floor_radius), balance), max(abs(uv_radius - spiral_ceil_radius), abs(uv_radius - spiral_floor_radius)), balance);
}

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed



P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //vec4 FRAGCOORD = gl_FragCoord;

    //----------------------------------------------

    vec2 uv = UV - 0.5;
    uv.x *= resolution.x / resolution.y;
    float spiral = 0.0;
    for (float i = 0.0; i < octaves; i += 1.0) {
        spiral += draw_spiral(uv, TIME * speed * (0.5 + sin(i)));
    }
    spiral /= octaves;
    vec3 color = spiral * spiral_color;
    COLOR = vec4(color * brightness, 1.0);

    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


