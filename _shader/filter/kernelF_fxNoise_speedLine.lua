

--[[
  Origin Author: exuin
  https://godotshaders.com/author/exuin/
  
  
--]]


local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "fxNoise"
kernel.name = "speedLine"

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

uniform vec4 line_color_a = vec4(1.0, 0.0, 0.0, 1.0); //: hint_color 
uniform vec4 line_color_b = vec4(0.0, 1.0, 0.0, 1.0); //: hint_color 
//uniform vec4 line_color_b = vec4(0.0, 0.0, 0.0, 0.0); //: hint_color 
uniform float line_threshold = .9999; // : hint( 0.9999, 0.1 ) change line appearance, 
uniform float inverse_speed = 50.1; // last time
uniform float line_length = 300.0;
uniform float angle = 0.0; //: hint_range(0.0, 360.0)
uniform float v_scaleUV = 3.0; //the less value the wider texture displayed
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

    vec4 noise_line = texture2D(CoronaSampler0, vec2(uv.x / line_length + TIME / inverse_speed, uv.y * v_scaleUV));
    

    if (noise_line.r < line_threshold){
      COLOR = vec4(0.);
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

