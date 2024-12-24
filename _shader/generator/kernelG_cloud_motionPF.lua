 
--[[
    https://godotshaders.com/shader/clouds-in-motion/
    gerardogc2378
    August 14, 2021
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "cloud"
kernel.name = "motionPF" -- Platformer

kernel.isTimeDependent = true

kernel.uniformData =
{
    -- index = 0, -- u_UserData0
    -- type = "mat4",  -- vec4 x 4
    -- type = "mat2",  -- vec2 x 2


    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "colorMat4",
        paramName = {
            'Offset', 'Size', 'Speed', 'Lyr_Step',
            'cloud_R','cloud_G','cloud_B','cloud_A',
            'BG_R','BG_G','BG_B','BG_A',
            'none','none','none','none',
        },
        default = {
            1.5, 2.5, -3.5, .1,
            1.0, 1.0, 1.0, 1.0,         -- Col_Cloud 
            0.18, 0.70, 0.87, 1.0,      -- Col_Back
            0.0, 0.0, 0.0, 0.0,
        },
        min = {
            -10, -10, -10, 0.01,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
        },
        max = {
            10, 10, 10, .5,
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
        },
    },
    {
        index = 1, 
        type = "mat4",  -- vec4 x 4
        name = "colorMat4_2",
        paramName = {
            'Offset', 'Size', 'Speed', 'Lyr_Step',
            'cloud_R','cloud_G','cloud_B','cloud_A',
            'BG_R','BG_G','BG_B','BG_A',
            'none','none','none','none',
        },
        default = {
            1.5, 2.5, -3.5, .1,
            1.0, 1.0, 1.0, 1.0,         -- Col_Cloud 
            0.8, 0.0, 0.7, 1.0,      -- Col_Back
            0.0, 0.0, 0.0, 0.0,
        },
        min = {
            -10, -10, -10, 0.01,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
        },
        max = {
            10, 10, 10, .5,
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
        },
    },

    -- {
    --     type = "vec4",
    --     name = "setting",   
    --     -- Offset, Size, Speed, Lyr_Step
    --     default = {1.5, 2.5, -3.5, 0.1}, 
    --     min = { -10, -10, -10, -10 },
    --     max = { 10, 10, 10, 10 },
    --     index = 1, -- u_UserData1
    -- },

}


kernel.fragment =
[[
//----------------------------------------------

uniform mat4 u_UserData0; // mat4A
uniform mat4 u_UserData1; // mat4A_2

vec4 setting = u_UserData0[0];
P_COLOR vec4 Col_Cloud = u_UserData0[1];
P_COLOR vec4 Col_Back = u_UserData0[2];

float Offset = setting[0];      // : hint_range( -0.5, 1.5, 10) Reverse Cloud if the cal result is minus
float Size = setting[1];        // : hint_range( 0.1, 2.5, 10) Higher the smaller + slower
float Speed = setting[2];       // : hint_range(-0.5, 5.0)
float Lyr_Step = setting[3];    // : hint_range( 0.05, 0.1) Lower the more

//----------------------------------------------
const float TAU = 6.28318530718;
//----------------------------------------------

float Func(float pX)
{
    return 0.6*(0.5*sin(0.1*pX) + 0.5*sin(0.553*pX) + 0.7*sin(1.2*pX));
}

float FuncR(float pX)
{
    return 0.5 + 0.25*(1.0 + sin(mod(40.0*pX, TAU)));
}


float Layer(vec2 pQ, float pT)
{
    vec2 Qt = 3.5*pQ;
    pT *= 0.5;
    Qt.x += pT;

    float Xi = floor(Qt.x);
    float Xf = Qt.x - Xi -0.5;

    vec2 C;
    float Yi;
    float D = 1.0 - step(Qt.y,  Func(Qt.x));

    // Disk:
    Yi = Func(Xi + 0.5);
    C = vec2(Xf, Qt.y - Yi );
    D =  min(D, length(C) - FuncR(Xi+ pT/80.0));

    // Previous disk:
    Yi = Func(Xi+1.0 + 0.5);
    C = vec2(Xf-1.0, Qt.y - Yi );
    D =  min(D, length(C) - FuncR(Xi+1.0+ pT/80.0));

    // Next Disk:
    Yi = Func(Xi-1.0 + 0.5);
    C = vec2(Xf+1.0, Qt.y - Yi );
    D =  min(D, length(C) - FuncR(Xi-1.0+ pT/80.0));

    return min(1.0, D);
}


//----------------------------------------------

//-----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime;


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //P_DEFAULT float alpha = abs(sin(CoronaTotalTime)) -0.15;

    vec2 SCREEN_UV = UV;

    //----------------------------------------------

    vec2 uv = Size * (SCREEN_UV - UV * Offset);

    // Render:
    vec3 Color = Col_Back.rgb;
    for( float J = 0.0; J <= 1.0; J += Lyr_Step )
    {
        // Cloud Layer:
        float Lt =  TIME * Speed * (0.5  + 2.0 * J) * (1.0 + 0.1 * sin(226.0 * J)) + 17.0 * J;
        vec2 Lp = vec2(0.0, 0.3 + 1.5 * ( J - 0.5));
        float L = Layer(uv + Lp, Lt);
        
        // Blur and color:
        float blur = 4.0 * (0.5 * abs(2.0 - 5.0 * J)) / (11.0 - 5.0 * J);
        float V = mix( 0.0, 1.0, 1.0 - smoothstep( 0.0, 0.01 +0.2 * blur, L ) );
        vec3 Lc =  mix( Col_Back.rgb, Col_Cloud.rgb, J);
        Color = mix( Color, Lc,  V );
    }
    COLOR = vec4(Color, Col_Cloud.a);

    //----------------------------------------------
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


