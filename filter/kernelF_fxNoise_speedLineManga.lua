

--[[
  https://godotshaders.com/shader/speedlines-manga-style/
  yo1
  September 28, 2024
--]]


local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "fxNoise"
kernel.name = "speedLineManga"

--Test
kernel.isTimeDependent = true

kernel.vertexData   = {
  {
    name    = "r",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 0,
    },{
    name    = "g",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 1,
    },{
    name    = "b",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 2,
    },{
    name    = "size",
    default = 1,
    min     = 0,
    max     = 32,
    index   = 3,
  },
}
kernel.fragment = [[

uniform vec4 line_color_a = vec4(1.62, 1.85, 3.0, 1.0);
uniform vec4 line_color_b = vec4(.0, 3.0, 3.75, 1.0);
uniform vec4 back_color = vec4(0.171,0.1,0,1);
uniform float line_threshold = 0.999; //: hint_range(0.0, 1.0, 0.01)
uniform float speed = 0.07; //: hint_range(0.0, 1.0, 0.01)
uniform float line_length = 1000.0;
uniform float angle = 0.0;//: hint_range(0.0, 360.0) 

//----------------------------------------------

P_COLOR vec4 COLOR;

//----------------------------------------------


//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //P_UV vec2 UV = UV;
    float TIME = mod(CoronaTotalTime, 10);
    //----------------------------------------------

    vec2 uv = vec2(UV.x * cos(radians(angle)) - UV.y * sin(radians(angle)), UV.x * sin(radians(angle)) + UV.y * cos(radians(angle)));
    vec4 noise_line = texture2D(CoronaSampler0, vec2(uv.x / line_length + fract(TIME) * speed, uv.y));
    if (noise_line.r < line_threshold){
      COLOR = back_color;
    } else {
      COLOR = mix(line_color_a, line_color_b, 1.0 - noise_line.r);
    }

    //----------------------------------------------
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]
return kernel

--[[


--]]

