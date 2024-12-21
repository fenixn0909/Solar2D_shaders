
--[[
    https://godotshaders.com/shader/simple-spirals-demo/
    sturm_trouper
    July 11, 2024

    Spiral 1 creates a standard spiral with one hard edge and one soft edge.
    Spiral 2 is also a standard spiral but with both edges softer.
    Spiral 3 was a happy accident. I hadn’t lined up my radius and angle properly for the basic spiral, and in effort to fix it I went in the wrong (but a good) direction and came up with some nice “tiered” spirals that have interesting radial discontinuities. (Can get pretty close to a nice “fan”-like effect with right parameters. E.g., Fade=1.25, Thickness=0.3, tiers=3, Stretch=3.)
    Spiral 4 is another happy accident which gets another look. (To emphasize the difference in both, look at them both with a smaller tier value.
    Spiral 5 shows how you can use the same formulas to make a two-color spiral by mixing, instead of changing the alpha.

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FX"
kernel.name = "simpleSpiralsDemo"

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
            'Stretch','Thickness','Type','Tiers',
            'Speed','Rays','Fade','none',
            'Col_1_R','Col_1_G','Col_1_B','Col_1_A',
            'Col_2_R','Col_2_G','Col_2_B','Col_2_A',
        },
        default = {
            6.28, .3, 1, 4,
            1.5, 6., .1, 0.,       
            0.5, 1.5, 0.5, 0.0,      
            1.0, 0.5, 0.5, 0.0,
        },
        min = {
            -20., 0., 1., 0.,
            -20., 0., 0., 0.,
            0., 0., 0., 0.,
            0., 0., 0., 0.,
        },
        max = {
            20., 1., 5., 10.,
            20., 20., 3., 0.,
            2.0, 2.0, 2.0, 2.0,
            2.0, 2.0, 2.0, 2.0,
        },
    },
}

kernel.fragment =
[[

uniform mat4 u_UserData0;
//uniform mat4 u_UserData1;
//----------------------------------------------
float Stretch = u_UserData0[0].x;
float Thickness = u_UserData0[0].y;
float Type = u_UserData0[0].z;
float Tiers = u_UserData0[0].w;

float Speed = u_UserData0[1].x;
float Rays = u_UserData0[1].y;
float Fade = u_UserData0[1].z;

//vec3 Col_1 = vec3( 0.5, 1.5, 0.5 );
//vec3 Col_2 = vec3( 1.0, 0.5, 0.5 );

vec3 Col_1 = u_UserData0[2].rgb;
vec3 Col_2 = u_UserData0[3].rgb;

//----------------------------------------------

int I_Type = int(Type); //hint_range(1,5) = 1;

const float PI = 3.14159265359;
const float TAU =  6.283185307179586;

// (clockwise?1.:-1.)

//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime * Speed; // * speed

P_UV vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;
P_UV vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

    //----------------------------------------------

    float r = length(.5 - UV);
    float angle = atan(UV.y-.5, UV.x-.5);
    COLOR.rgb = Col_1;
    
    if (I_Type == 1)
        COLOR.a = 1. - smoothstep(-.1, .1, fract((2.*r-(angle+PI)/TAU)*Rays + 
                                        1 * TIME)-Thickness);
    if (I_Type == 2)
        COLOR.a = 1. - smoothstep(0., Thickness, abs(.5 - fract((2.*r-(angle+PI)/TAU)*Rays + 1 * TIME) ) );
    if (I_Type == 3)
        COLOR.a *= 1. - smoothstep(0.0, Thickness, fract(Tiers*(2.*r))/Tiers - mod(Tiers*(angle+PI)- 1 *TIME,TAU)/(Stretch*Tiers) );
    if (I_Type == 4)
        COLOR.a *= 1. - smoothstep(0.0, Thickness, abs(fract(Tiers*(2.*r))/Tiers - mod(Tiers*(angle+PI)- 1 *TIME,TAU)/(Stretch*Tiers)) );
    if (I_Type == 5)
        COLOR.rgb = mix(Col_1, Col_2, Thickness*fract((2.*r-(angle+PI)/TAU)*Rays + 
                                        1 * TIME) );
    
    COLOR.a *= pow(2.*(.5 - r), Fade*4.);

    //----------------------------------------------
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


