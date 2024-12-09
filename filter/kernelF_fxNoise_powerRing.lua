

--[[
    https://godotshaders.com/shader/ring-of-power/
    CasualGarageCoder
    August 6, 2023
--]]


local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "fxNoise"
kernel.name = "powerRing"

--Test
kernel.isTimeDependent = true

kernel.vertexData   = {
  {
    name    = "r",
    default = 0,
    min     = 0,
    max     = 1,
    index   = 0,
    },
}
kernel.fragment = [[

uniform sampler2D noise;

uniform float radius = .7;// : hint_range(0.0, 1.0, 0.01) 
uniform float thickness = .3;// : hint_range(0.0, 1.0, 0.01) 
uniform vec4 color = vec4(0.1, 0.4, 0.9, .5);// : hint_color 
uniform float brightness = 5.0;// : hint_range(0.0, 15.0, 0.01) 
uniform float angular_speed = 0.05;// : hint_range(-5.0, 5.0, 0.01) 
uniform float radial_speed = .04;// : hint_range(-5.0, 5.0, 0.01) 
uniform float alpha = .75;// : hint_range(0.0, 1.0, 0.01) 

//----------------------------------------------


//----------------------------------------------


//----------------------------------------------

P_COLOR vec4 COLOR;
//float TIME = mod(CoronaTotalTime, 10);
float TIME = CoronaTotalTime * 10;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------

    vec2 v = vec2(.5) - UV;
    float d = length(v) * 2.;
    float angle = atan(v.y, v.x) + (TIME * angular_speed);
    float thick_ratio = 1. - (abs(d - max(0., radius)) / max(.0001, thickness));
    vec2 polar = fract(vec2(angle / 6.28, d + (TIME * radial_speed)));
    vec4 col = thick_ratio * brightness * color;
    vec3 tex = texture2D(noise, polar).rgb;
    col.a = (alpha * (tex.r + tex.g + tex.b) * clamp(thick_ratio, 0., 1.)) / 3.;
    COLOR = col;

    //----------------------------------------------
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]
return kernel

--[[


--]]

