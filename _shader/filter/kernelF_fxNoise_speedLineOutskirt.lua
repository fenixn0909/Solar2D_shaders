

--[[
  https://godotshaders.com/shader/speed-lines-shader-for-godot-4/
  axilirate
  March 2, 2023
  
  outskirts, surounding, around
  
--]]


local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "fxNoise"
kernel.name = "speedLineOutskirt"

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

//uniform sampler2D noise: repeat_enable;
uniform vec4 line_color = vec4(0.45, 0.6, 0.9, 1); // : source_color;
uniform float line_count = 8;// : hint_range(0.0, 2.0, 0.05) 
uniform float line_density = .5; // : hint_range(0.0, 1.0)
uniform float line_faloff = .3; // : hint_range(0.0, 1.0)
uniform float mask_size = 0.001; // : hint_range(0.0, 1.0)
uniform float mask_edge = .45; // : hint_range(0.0, 1.0)
uniform float animation_speed = 11.7; // : hint_range(1.0, 20.0)

P_DEFAULT float PI = 3.14159265359;

// ----------------------------------------------------------------------------------------------------

float inv_lerp(float from, float to, float value){
    return (value - from) / (to - from);
  }

  vec2 polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat)
  {
    vec2 dir = uv - center;
    float radius = length(dir) * 2.0;
    float angle = atan(dir.y, dir.x) * 1.0/(PI * 2.0);
    return mod(vec2(radius * zoom, angle * repeat), 1.0);
  }

  vec2 rotate_uv(vec2 uv, vec2 pivot, float rotation) {
      float cosa = cos(rotation);
      float sina = sin(rotation);
      uv -= pivot;
      return vec2(
          cosa * uv.x - sina * uv.y,
          cosa * uv.y + sina * uv.x 
      ) + pivot;
  }

// ----------------------------------------------------------------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    P_DEFAULT float TIME = CoronaTotalTime;
    P_COLOR vec4 COLOR;
    // ----------------------------------------------------------------------------------------------------

    vec2 polar_uv = polar_coordinates(rotate_uv(UV, vec2(0.5), floor(fract(TIME) * animation_speed) ) , vec2(0.5), 0.01, line_count);
    //vec3 lines = texture(noise, polar_uv).rgb;
    vec3 lines = texture2D( CoronaSampler0, polar_uv).rgb;
    
    float mask_value = length(UV - vec2(0.5));
    float mask = inv_lerp(mask_size, mask_edge, mask_value);
    float result = 1.0 - (mask * line_density);
    
    result = smoothstep(result, result + line_faloff, lines.r);
    
    COLOR.rgb = vec3(line_color.rgb);
    COLOR.a = min(line_color.a, result);
    COLOR.rgb *= COLOR.a;
    // ----------------------------------------------------------------------------------------------------

    //return CoronaColorScale( result );
    return CoronaColorScale( COLOR );
}
]]
return kernel

--[[
  


--]]

