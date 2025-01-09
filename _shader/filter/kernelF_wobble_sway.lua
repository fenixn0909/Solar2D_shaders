--[[

    https://github.com/kan6868/Solar2D-Shader/blob/main/sway/sway.lua

    kan6868

]]


local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "wobble"
kernel.name = "sway"

kernel.isTimeDependent = true

kernel.uniformData =
{
    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "uniSetting",
        paramName = {
            'Speed','Strength_Min','Strength_Max','Strength_Scale',
            'Interval','Detail','TimeOffset','HeightOffset',
            'Distortion','','','',
            '','','',''
        },
        default = {
            3., 2, 1, 20,
            3.5, 1., 0., .5,
            .5, 0, 0, 0,
            0, 0, 0, 0,
        },
        min = {
             0, .0, 0.0, 0.1,
            .0, .0, .001, 0.01,
            .0, .0, .0, 0.,
            .0, .0, .0, 0.,
        },
        max = {
            20.0, 5, 10.0, 100.0,
            20.0, 10.0, 5.0, 1.0,
            100.0, 1.0, 1.0, .5,
            1.0, 1.0, 1.0, .5,
        },
    },

}


kernel.vertex =
[[
    uniform mat4 u_UserData0; // uniSetting
    //----------------------------------------------
    
    P_COLOR float Speed = u_UserData0[0][0];
    P_COLOR float Strength_Min = u_UserData0[0][1];
    P_COLOR float Strength_Max = u_UserData0[0][2];
    P_COLOR float Strength_Scale = u_UserData0[0][3];

    P_COLOR float Interval = u_UserData0[1][0];
    P_COLOR float Detail = u_UserData0[1][1];
    P_COLOR float TimeOffset = u_UserData0[1][2];
    P_COLOR float HeightOffset = u_UserData0[1][3];

    P_COLOR float Distortion = u_UserData0[2][0];

    //----------------------------------------------
    
    P_COLOR float getWind(P_COLOR vec2 vertex, P_COLOR vec2 uv, P_COLOR float time, P_COLOR float heightOffset, P_COLOR float distortion){
        P_COLOR float diff = pow(Strength_Max - Strength_Min, 2.0);
        P_COLOR float strength = clamp(Strength_Min + diff + sin(time / Interval) * diff, Strength_Min, Strength_Max) * Strength_Scale;
        P_COLOR float wind = (sin(time) + cos(time * Detail)) * strength * max(0.0, (1.0-uv.y) - heightOffset) + sin(time)*distortion;
        
        return wind; 
    }

    P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
    {
        P_COLOR float time = CoronaTotalTime * Speed + TimeOffset;
        position.x += getWind(position.xy, CoronaTexCoord, time, HeightOffset, Distortion);

        return position;
    }
]]





return kernel