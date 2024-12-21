
--[[
    https://godotshaders.com/shader/grid-shader-tutorial/
    FencerDevLog
    February 19, 2024
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "grid"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Zoom",          default = 3, min = 0, max = 50, index = 0, },
  { name = "Thickness",     default = 2, min = 0.1, max = 100, index = 1, },
  { name = "Brightness",    default = 1, min = 0.1, max = 8, index = 2, },
} 

kernel.fragment =
[[

float Zoom = CoronaVertexUserData.x;
float Thickness = CoronaVertexUserData.y;
float Brightness = CoronaVertexUserData.z;
float Steps = CoronaVertexUserData.w;

//----------------------------------------------

P_COLOR vec3 Col_Line = vec3(0.2, 0.3, 0.5); //: source_color
#define TAU 6.28318530718

//----------------------------------------------

float draw_grid(vec2 uv) {
    vec2 grid_uv = cos(uv * TAU);
    return max(grid_uv.x, grid_uv.y);
}

vec2 rotate(vec2 uv, float angle) {
    return uv * mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed
vec2 Resolution = 1.0 / CoronaTexelSize.zw;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------

    vec2 uv = UV - 0.5;
    uv.x *= Resolution.x / Resolution.y;
    uv += vec2(sin(TIME) * 0.4, cos(TIME) * 0.6);
    uv = rotate(uv, TIME * 0.1);
    //float Zoom = abs(sin(TIME * 0.5)) * 40.0;
    float line_thickness = Zoom * Thickness * 10 / Resolution.y;
    vec3 color = smoothstep(1.0 - line_thickness, 1.0, draw_grid(uv * Zoom)) * Col_Line;
    COLOR = vec4(color * Brightness, 1.0);

    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


