
--[[

    https://godotshaders.com/shader/%e7%87%83%e7%83%a7-burn-2d/
    A.ling
    July 14, 2024


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "FX"
kernel.name = "burnOut"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = 1,
    min = 1,
    max = 99,
    index = 0, 
  },
  {
    name = "resolutionY",
    default = 1,
    min = 1,
    max = 99,
    index = 1, 
  },
}


kernel.fragment =
[[


//----------------------------------------------

uniform float burn_size = .51;// : hint_range(0.0, 1.0, 0.01) 火焰大小
uniform vec4 ash_color = vec4(0,0,0,1.0);// : source_color 灰烬颜色
uniform vec4 burn_color = vec4(0.882, 0.777, 0.169 , 1.0);// : source_color 燃烧颜色
uniform vec4 proburn_color = vec4(0.804, 0.2, 0.093 , 1.0);// : source_color 超级燃烧颜色

float progress = CoronaVertexUserData.x;

// -----------------------------------------------

float PI = 3.14159265359;

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;

// -----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    // Test
    progress = abs(sin(CoronaTotalTime));

    
    //----------------------------------------------

    vec4 main_texture = texture2D( CoronaSampler0, UV );
    vec4 noise_texture = texture2D( CoronaSampler1, UV );
  
    // This is needed to avoid keeping a small burn_color dot with dissolve being 0 or 1
    // is there another way to do it?
    float burn_size_step = burn_size * step(0.001, progress) * step(progress, 0.999);
    float threshold = smoothstep(noise_texture.x-burn_size_step, noise_texture.x, progress);
    float border = smoothstep(noise_texture.x, noise_texture.x + burn_size_step, progress);

    COLOR.a *= threshold;
    vec3 new_burn_color1 = mix(proburn_color.rgb , burn_color.rgb , 1.0-pow(1.0-border , 5));
    vec3 new_burn_color2 = mix(ash_color.rgb , new_burn_color1 , 1.0-pow(1.0-border , 1000));
    COLOR.rgb = mix(new_burn_color2, main_texture.rgb, border);
    COLOR.rgb *= main_texture.a;
    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    
--]]


