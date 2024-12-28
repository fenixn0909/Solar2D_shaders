 
--[[
    https://godotshaders.com/shader/hologram-simple-canvasitem-shader/
    Vaquers
    June 21, 2023

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "hologram"

kernel.isTimeDependent = true

kernel.uniformData =
{
    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "uniSetting",
        paramName = {
            'Speed','Alpha','Noise_Amount','Effect_Factor',
            'Lines','','','',    
            'Col1_R','Col1_G','Col1_B','Col1_A',
            'Col2_R','Col2_G','Col2_B','Col2_A',
        },
        default = {
            .4, .75, .05, .4,
            45,  0.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 1.0,     
            0.0, 1.0, 0.0, 1.0,
        },
        min = {
            -2.0, 0.0, -2.5, -2.0,
            -10, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
        },
        max = {
            2, 1, 2.5, 2,
            100, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
        },
    },
}



kernel.fragment =
[[

uniform sampler2D TEXTURE;

uniform mat4 u_UserData0; // uniSetting
//----------------------------------------------

float Speed = u_UserData0[0][0];  // : hint_range(0.0, 2.0, 0.01) 
float Alpha = u_UserData0[0][1];  // : hint_range(0.0, 1.0, 0.01) 
float Noise_Amount = u_UserData0[0][2];  // : hint_range(0.0, 1.0, 0.01) 
float Effect_Factor = u_UserData0[0][3];  // : hint_range(0.0, 1.0, 0.01) 


//int I_Lines = 100;
int I_Lines = int( u_UserData0[1][0] );

vec4 Col_1 = u_UserData0[2];
vec4 Col_2 = u_UserData0[3];


float TIME = CoronaTotalTime;
float PI = 3.14159265359;

//----------------------------------------------

void noise(in vec2 uv, inout vec4 color) {
    float a = fract(sin(dot(uv, vec2(12.9898, 78.233) * TIME)) * 438.5453) * 1.9;
    color.rgb = mix(color.rgb, vec3(a), Noise_Amount);
}

vec4 color_shift(in vec2 uv, in sampler2D image, vec2 shift_vector) {
    return texture2D(image, uv - shift_vector);
}

// -----------------------------------------------

P_COLOR vec4 COLOR = vec4(0);


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
    //----------------------------------------------
    float lineN = floor((UV.y - TIME*Speed) * float(I_Lines));
    float line_grade = abs(sin(lineN*PI/4.0));
    float smooth_line_grade = abs(sin((UV.y - TIME*Speed) * float(I_Lines)));
    
    vec4 line_color = mix(Col_1, Col_2, line_grade);
    
    // change the "240.0" literal to control line color shifting
    COLOR = color_shift(UV, TEXTURE, vec2(1.0, 0.0)*smooth_line_grade/240.0*Effect_Factor);
    
    noise(UV, COLOR);
    
    COLOR.rgb = mix(COLOR.rgb, line_color.rgb, Effect_Factor);
    COLOR.rgb *= COLOR.a;

    COLOR.a = Alpha * COLOR.a * line_color.a;

    //----------------------------------------------



    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


