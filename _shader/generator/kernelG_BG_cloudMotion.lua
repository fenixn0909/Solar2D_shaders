 
--[[
    https://godotshaders.com/shader/clouds-in-motion/
    gerardogc2378
    August 14, 2021
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "cloudMotion"

kernel.isTimeDependent = true

kernel.uniformData =
{
    -- index = 0, -- u_UserData0
    -- type = "mat4",  -- vec4 x 4
    -- type = "mat2",  -- vec2 x 2
    {
        name = "colorMat4",
        default = {
            1.0, 1.0, 1.0, 1.0,         -- Cloud Color
            0.18, 0.70, 0.87, 1.0,      -- backColor
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
        },
        -- default = {1.5, 1.5, 1.5, 1.5},
        min = {
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
        },
        max = {
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
        },
        type = "mat4",  -- vec4 x 4
        index = 0, 
    },

    {
        name = "setting",   
        -- offset, size, speed, lyr_step
        default = {1.5, 2.5, -3.5, 0.1}, 
        min = { -10, -10, -10, -10 },
        max = { 10, 10, 10, 10 },
        type = "vec4",
        index = 1, -- u_UserData1
    },
    

}

-- kernel.vertexData =
-- {
--   {
--     -- hint_range( 0.5, 1.5, 2) >1: Higher, <1: Reverse
--     name = "offset",    
--     default = 1.5,
--     min = -5,
--     max = 5,
--     index = 0, 
--   },
-- }


kernel.fragment =
[[
//----------------------------------------------


uniform mat4 u_UserData0; // mat4A
uniform vec4 u_UserData1; // setting

P_COLOR vec4 cloudColor = u_UserData0[0];
P_COLOR vec4 backColor = u_UserData0[1];

float offset = u_UserData1[0];      // : hint_range( -0.5, 1.5, 10) Reverse Cloud if the cal result is minus
float size = u_UserData1[1];        // : hint_range( 0.1, 2.5, 10) Higher the smaller + slower

float speed = u_UserData1[2];       // : hint_range(-0.5, 5.0)
float lyr_step = u_UserData1[3];    // : hint_range( 0.05, 0.1) Lower the more


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

    vec2 uv = size * (SCREEN_UV - UV * offset);

    // Render:
    vec3 Color= backColor.rgb;
    for( float J = 0.0; J <= 1.0; J += lyr_step )
    {
        // Cloud Layer:
        float Lt =  TIME * speed * (0.5  + 2.0 * J) * (1.0 + 0.1 * sin(226.0 * J)) + 17.0 * J;
        vec2 Lp = vec2(0.0, 0.3 + 1.5 * ( J - 0.5));
        float L = Layer(uv + Lp, Lt);
        // Blur and color:
        float Blur = 4.0 * (0.5 * abs(2.0 - 5.0 * J)) / (11.0 - 5.0 * J);
        float V = mix( 0.0, 1.0, 1.0 - smoothstep( 0.0, 0.01 +0.2 * Blur, L ) );
        //vec3 Lc=  mix(cloudColor.rgb, vec3(1.0), J);
        vec3 Lc=  mix( backColor.rgb, cloudColor.rgb, J);
        Color =mix( Color, Lc,  V );
    }
    COLOR = vec4(Color, cloudColor.a);
    //----------------------------------------------
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


