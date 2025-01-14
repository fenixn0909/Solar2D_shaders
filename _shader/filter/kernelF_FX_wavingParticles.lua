--[[
    https://godotshaders.com/shader/waving-particles/
    Steampunkdemon
    July 22, 2023

]]
--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "FX"
kernel.name = "wavingParticles"
kernel.isTimeDependent = true


kernel.uniformData =
{
    {
        index = 0, 
        type = "mat4",  -- vec4 x 4
        name = "uniSetting",
        paramName = {
            'Wave_Speed','Wave_Rot','Wave_Min','Wave_Max',
            'Scroll_V','Scroll_H','Size_Min','Size_Max',
            'Rows','Columns','','',
            '','','','',
        },
        default = {
            .5, 1., .1, 1.,
            .5, .1, .3, .7,
            20., 5., 0, 0,
            0, 0, 0, 0,
        },
        min = {
            0, -1, 0, 0,
            -1,-1,.1,.1,
            1,1,0,0,
            0,0,0,0,
        },
        max = {
            2,1,1,1,
            1,1,1,1,
            50,50,0,0,
            0,0,0,0,
        },
    },

}



kernel.fragment =
[[

uniform sampler2D particle_texture;

uniform mat4 u_UserData0; // uniSetting

float Wave_Speed = u_UserData0[0][0];
float Wave_Rot = u_UserData0[0][1];
float Wave_Min = u_UserData0[0][2];
float Wave_Max = u_UserData0[0][3];
float Scroll_V = u_UserData0[1][0];
float Scroll_H = u_UserData0[1][1];
float Size_Min = u_UserData0[1][2];
float Size_Max = u_UserData0[1][3];
float Rows = u_UserData0[2][0];
float Columns = u_UserData0[2][1];


//----------------------------------------------

vec2 Dimensions = 1.0 / CoronaTexelSize.zw; // Resolution of ColorRect in pixels

// Replace the below references to 'source_color' with 'hint_color' if you are using a version of Godot before 4:
vec4 Col_Far = vec4(0.5, 0.5, 0.5, 1.0);  //source_color
vec4 Col_Near = vec4(1.0, 1.0, 1.0, 1.0);     //source_color

float PI = 3.14159265359;

//----------------------------------------------

float greater_than(float x, float y) {
    return max(sign(x - y), 0.0);
}

//----------------------------------------------

float TIME = CoronaTotalTime ;
P_COLOR vec4 COLOR = vec4(0);


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------
    // You can comment out the below line and add a new uniform above as:
    // uniform float time = 10000.0;
    // You can then update the time uniform from your _physics_process function by adding or subtracting delta. You can also pause the particles' motion by not changing the time uniform.
    float time = 10000.0 + TIME;

    float row_rn = fract(sin(floor((UV.y - Scroll_V * time) * Rows)));
    float column_rn = fract(sin(floor((UV.x + row_rn - Scroll_H * time) * Columns)));
    float wave = sin(Wave_Speed * time + column_rn * 90.0);
    vec2 uv = (vec2(fract((UV.x + row_rn - Scroll_H * time + (wave * (Wave_Min + (Wave_Max - Wave_Min) * column_rn) / Columns / 2.0)) * Columns), fract((UV.y - Scroll_V * time) * Rows)) * 2.0 - 1.0) * vec2(Dimensions.x / Dimensions.y * Rows / Columns, 1.0);
    float size = Size_Min + (Size_Max - Size_Min) * column_rn;
    vec4 color = mix(Col_Far, Col_Near, column_rn);
    
    // Comment out the below two lines if you do not need or want the particles to rotate:
    float a = ((column_rn + wave) * Wave_Rot) * PI;
    uv *= mat2(vec2(sin(a), -cos(a)), vec2(cos(a), sin(a)));

    // Render particles as circles with soft edges:
    //  COLOR.rgb = mix(COLOR.rgb, color.rgb, max((size - length(uv)) / size, 0.0) * color.a);

    // Render particles as circles with hard edges:
    //  COLOR.rgb = mix(COLOR.rgb, color.rgb, greater_than(size, length(uv)) * color.a);

    // Render particles as crosses with soft edges:
    //  COLOR.rgb = mix(COLOR.rgb, color.rgb, max((size - length(uv)) / size, 0.0) * (max(greater_than(size / 10.0, abs(uv.x)), greater_than(size / 10.0, abs(uv.y)))) * color.a);

    // Render particles as crosses with hard edges:
    //  COLOR.rgb = mix(COLOR.rgb, color.rgb, max(greater_than(size / 5.0, abs(uv.x)) * greater_than(size, abs(uv.y)), greater_than(size / 5.0, abs(uv.y)) * greater_than(size, abs(uv.x))) * color.a);

    // Render particles as squares:
    //  COLOR.rgb = mix(COLOR.rgb, color.rgb, greater_than(size, abs(uv.x)) * greater_than(size, abs(uv.y)) * color.a);

    // Render particles as diamonds:
    //  COLOR.rgb = mix(COLOR.rgb, color.rgb, greater_than(size, abs(uv.y) + abs(uv.x)) * color.a);

    // Render particles using the 'particle_texture':
    // The texture should have a border of blank transparent pixels.
    vec4 particle_texture_pixel = texture2D(particle_texture, (uv / size + 1.0) / 2.0) * color;
    COLOR.rgb = mix(COLOR.rgb, particle_texture_pixel.rgb, particle_texture_pixel.a);
    
    //----------------------------------------------
    return CoronaColorScale(COLOR);
}
]]

return kernel



--[[

--]]
