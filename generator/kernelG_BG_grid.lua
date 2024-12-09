
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

uniform vec3 line_color = vec3(0.2, 0.3, 0.5); //: source_color
//uniform float zoom = 20.0;    //: hint_range(1.0, 50.0, 0.1)
uniform float thickness = 2.0;  //: hint_range(0.1, 10.0, 0.1)
uniform float brightness = 2.0; //: hint_range(0.1, 4.0, 0.1) 

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

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------

    vec2 uv = UV - 0.5;
    uv.x *= resolution.x / resolution.y;
    uv += vec2(sin(TIME) * 0.4, cos(TIME) * 0.6);
    uv = rotate(uv, TIME * 0.1);
    float zoom = abs(sin(TIME * 0.5)) * 40.0;
    float line_thickness = zoom * thickness / resolution.y;
    vec3 color = smoothstep(1.0 - line_thickness, 1.0, draw_grid(uv * zoom)) * line_color;
    COLOR = vec4(color * brightness, 1.0);

    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


