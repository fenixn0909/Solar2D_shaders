

--[[
  https://godotshaders.com/author/exuin/
  Exuin
  December 25, 2021
  
  What?! Radial speedlines?

  This shader relies on a noise texture to generate the spikes. 
  I suggest turning up persistence and lacunarity, whatever those things mean. 
  Change sample_radius to animate the speedlines!

--]]


local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "fxNoise"
kernel.name = "speedLineRadial"

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

vec2 center = vec2(0.5, 0.5);
float sample_radius = 0.5; //: hint_range(0.0, 1.0) 
vec4 line_color = vec4(1,0,0,1); //: hint_color 
float center_radius = .3; //: hint_range(0.0, 1.0)


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    sample_radius = abs(sin(CoronaTotalTime * 1.3));

    P_UV vec2 UV = texCoord; 
    vec2 dist = UV - center;
    float angle = atan(dist.y / dist.x);
    vec2 v_uvSample = vec2(sample_radius * cos(angle), sample_radius * sin(angle));
    float noise_value = texture2D(CoronaSampler0, v_uvSample).r;
    vec4 color = mix(line_color, vec4(0.0), noise_value);
    color = mix(color, vec4(0.0), 1.0 - length(dist) - center_radius);
    P_COLOR vec4 COLOR = color;

    return CoronaColorScale(COLOR);
}
]]
return kernel

--[[
  

--]]

