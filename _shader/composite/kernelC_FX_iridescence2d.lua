 
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
kernel.textureWrap = 'repeat'


kernel.uniformData =
{
    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "uniSetting",
        paramName = {
            'Speed','Noise_Scale','Distor_X','Distor_Y',
            'Intensity','','','',
            '', '', '','',
            '', '', '','',
        },
        default = {
            5, .1, 1, 1.5,
            .5, 0, 0, 0,
             0, 0, 0, 0,
             0, 0, 0, 0,
        },
        min = {
             -10, 0.001, 0, 0,
             0, .0, .001, 0.01,
            .0, .0, .001, 0.01,
            .0, .0, .001, 0.01,
        },
        max = {
            10, 2, 10, 10,
            1, 1.0, 1.0, 1,
            1.0, 1.0, 1.0, 1,
            1.0, 1.0, 1.0, 1,
        },
    },
}






kernel.fragment =
[[

uniform mat4 u_UserData0; 
uniform mat4 u_UserData1; 
//----------------------------------------------


P_COLOR float Speed       = u_UserData0[0][0];
P_COLOR float Noise_Scale = u_UserData0[0][1];
P_COLOR float Distor_X    = u_UserData0[0][2];
P_COLOR float Distor_Y    = u_UserData0[0][3];

P_COLOR float Intensity   = u_UserData0[1][0];




//----------------------------------------------




// -----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime * Speed * 10;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------
  
    vec4 base_texture = texture2D( CoronaSampler0, UV );

    vec2 noise_uv = UV * Noise_Scale;
    float noise_x = texture2D( CoronaSampler1, noise_uv).r;
    float noise_y = texture2D( CoronaSampler1, noise_uv).g;

    vec2 distorted_uv = UV + vec2(noise_x * Distor_X, noise_y * Distor_Y);

    float rainbow_r = sin(distorted_uv.x * 15.0 + TIME * 0.1);
    float rainbow_g = sin(distorted_uv.y * 15.0 + TIME * 0.1 + 2.0);
    float rainbow_b = sin(distorted_uv.x * 10.0 + TIME * 0.1 + 4.0);

    vec3 rainbow_color = vec3(rainbow_r, rainbow_g, rainbow_b);
    rainbow_color = (rainbow_color + 1.0) * 0.5; // Normalize to [0.0, 1.0]

    vec3 final_color = mix(base_texture.rgb, rainbow_color, Intensity);

    COLOR = vec4(final_color, base_texture.a);

  //----------------------------------------------
  COLOR.rgb *= base_texture.a;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[
    

--]]


