 
--[[
    https://godotshaders.com/shader/2d-iridescence/
    erratic_unicorn
    November 29, 2024
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "FX"
kernel.name = "iridescence2d"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "resolutionX",
    default = 1,
    min = 1,
    max = 99,
    index = 0, 
  },
}


kernel.fragment =
[[

//uniform sampler2D noise_texture;
uniform float noise_scale = 1.0; //: hint_range(0.1, 10.0)
uniform float distortion_scale_x = 0.03; //: hint_range(0.0, 10.0)
uniform float distortion_scale_y = 0.03; //: hint_range(0.0, 10.0)
uniform float rainbow_intensity = 0.5; //: hint_range(0.0, 1.0) 

float speed = 127;

//----------------------------------------------




// -----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime * speed;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------
  
    vec4 base_texture = texture2D( CoronaSampler0, UV );

    vec2 noise_uv = UV * noise_scale;
    float noise_x = texture2D( CoronaSampler1, noise_uv).r;
    float noise_y = texture2D( CoronaSampler1, noise_uv).g;

    vec2 distorted_uv = UV + vec2(noise_x * distortion_scale_x, noise_y * distortion_scale_y);

    float rainbow_r = sin(distorted_uv.x * 15.0 + TIME * 0.1);
    float rainbow_g = sin(distorted_uv.y * 15.0 + TIME * 0.1 + 2.0);
    float rainbow_b = sin(distorted_uv.x * 10.0 + TIME * 0.1 + 4.0);

    vec3 rainbow_color = vec3(rainbow_r, rainbow_g, rainbow_b);
    rainbow_color = (rainbow_color + 1.0) * 0.5; // Normalize to [0.0, 1.0]

    vec3 final_color = mix(base_texture.rgb, rainbow_color, rainbow_intensity);

    COLOR = vec4(final_color, COLOR.a);

  //----------------------------------------------
  COLOR.rgb *= base_texture.a;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    

--]]


