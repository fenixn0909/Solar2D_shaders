
--[[
    https://godotshaders.com/shader/balatro-fire-shader/
    xxidbr9
    January 15, 2025
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "fxNoise"
kernel.name = "balatroFire"


kernel.isTimeDependent = true


kernel.uniformData =
{
    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "uniSetting",
        paramName = {
            'Fire_SpeedX','Fire_SpeedY','Fire_Alpha','Fire_Aperture',
            'Col_Top_R','Col_Top_G','Col_Top_B','Col_Top_A',
            'Col_Mid_R','Col_Mid_G','Col_Mid_B','Col_Mid_A',
            'Col_Bot_R','Col_Bot_G','Col_Bot_B','Col_Bot_A',
        },
        default = {
            .2,.5,.8,.17,
            0,.7,1,1,
            1,.5,0,1,
            1,.03,.001,1,
        },
        min = {
             -5,-5,0,-2,
             0,0,0,0,
             0,0,0,0,
             0,0,0,0,
        },
        max = {
            5,5,2,5,
            1,1,1,1,
            1,1,1,1,
            1,1,1,1,
        },
    },
}




kernel.fragment =
[[

uniform sampler2D TEXTURE; //noise_tex
uniform mat4 u_UserData0; 
//----------------------------------------------

float Fire_SpeedX =      u_UserData0[0][0];
float Fire_SpeedY =      u_UserData0[0][1];
float Fire_Alpha =       u_UserData0[0][2];
float Fire_Aperture =    u_UserData0[0][3];
P_COLOR vec4 Col_Top = u_UserData0[1];
P_COLOR vec4 Col_Mid = u_UserData0[2];
P_COLOR vec4 Col_Bot = u_UserData0[3];

vec2 Fire_Speed = vec2( Fire_SpeedX, Fire_SpeedY );




float TIME = CoronaTotalTime;

//----------------------------------------------

vec4 tri_color_mix(vec4 color1, vec4 color2, vec4 color3, float pos) {
    pos = clamp(pos, 0.0, 1.0);
    if (pos < 0.5) {
        return mix(color1, color2, pos * 2.0);
    } else {
        return mix(color2, color3, (pos - 0.5) * 2.0);
    }
}

//-----------------------------------------------

P_COLOR vec4 COLOR = vec4(0);
P_UV vec2 iResolution = 1.0 / CoronaTexelSize.zw;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    vec2 base_uv = UV * 1.0;
    
    // Create two layers of noise with different speeds
    vec2 shifted_uv1 = base_uv + TIME * Fire_Speed;
    vec2 shifted_uv2 = base_uv + TIME * Fire_Speed * 1.5;
    
    // Sample noise texture twice
    float fire_noise1 = texture2D(TEXTURE, fract(shifted_uv1)).r;
    float fire_noise2 = texture2D(TEXTURE, fract(shifted_uv2)).r;
    
    // Combine the noise samples
    float combined_noise = (fire_noise1 + fire_noise2) * 0.5;
    
    // Calculate fire shape
    float noise = UV.y * (((UV.y + Fire_Aperture) * combined_noise - Fire_Aperture) * 75.0);
    
    // Add horizontal movement
    noise += sin(UV.y * 10.0 + TIME * 2.0) * 0.1;
    
    // Calculate gradient position and mix three colors
    float gradient_pos = clamp(noise * 0.08, 0.3, 2.0);
    //vec4 smoth_mid_color = smoothstep(Col_Bot, Col_Mid, vec4(1));
    vec4 fire_color = tri_color_mix(Col_Top, Col_Mid, Col_Bot, gradient_pos);

    // Set final color and alpha
    COLOR = fire_color;
    COLOR.a = clamp(noise, 0.0, 1.0) * Fire_Alpha;
    //----------------------------------------------
    COLOR.rgb *= COLOR.a;


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


