
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
    { name = "Progress",  default = .5, min = 0, max = 1, index = 0, },
    { name = "Burn_Size",  default = .51, min = 0, max = 10, index = 1, },
} 


kernel.fragment =
[[

float Progress = CoronaVertexUserData.x;
float Burn_Size = CoronaVertexUserData.y;

//----------------------------------------------

//float Burn_Size = .51;// : hint_range(0.0, 1.0, 0.01) 火焰大小
vec4 Col_Ash = vec4(0,0,0, .0);// : source_color 灰烬颜色
vec4 burn_color = vec4(0.882, 0.777, 0.169 , 0.0);// : source_color 燃烧颜色
vec4 Col_Proburn = vec4(0.804, 0.2, 0.093 , 1.0);// : source_color 超级燃烧颜色


// -----------------------------------------------

float PI = 3.14159265359;

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;

// -----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    float progress = 1-Progress;
    
    //----------------------------------------------

    vec4 main_texture = texture2D( CoronaSampler0, UV );
    vec4 noise_texture = texture2D( CoronaSampler1, UV );
  
    // This is needed to avoid keeping a small burn_color dot with dissolve being 0 or 1
    // is there another way to do it?
    float Burn_Size_step = Burn_Size * step(0.001, progress) * step(progress, 0.999);
    float threshold = smoothstep(noise_texture.x-Burn_Size_step, noise_texture.x, progress);
    float border = smoothstep(noise_texture.x, noise_texture.x + Burn_Size_step, progress);

    COLOR.a *= threshold;
    //COLOR.rgb *= threshold;
    vec3 new_burn_color1 = mix(Col_Proburn.rgb , burn_color.rgb , 1.0-pow(1.0-border , 5));
    //vec3 new_burn_color2 = mix(Col_Ash.rgb , new_burn_color1 , 1.0-pow(1.0-border , 1000));
    //COLOR.rgb = mix(new_burn_color2, main_texture.rgb, border);
    
    Col_Ash.a *= main_texture.a;
    Col_Ash.rgb *= Col_Ash.a;
    vec4 new_burn_color2 = mix(Col_Ash , vec4(new_burn_color1, 1) , 1.0-pow(1.0-border , 1000));
    COLOR = mix(new_burn_color2, main_texture, border);
    


    //----------------------------------------------
    COLOR.a *= main_texture.a;
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    
--]]


