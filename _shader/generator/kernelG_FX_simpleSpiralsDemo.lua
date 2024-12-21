
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

kernel.vertexData =
{
  { name = "Stretch",     default = 6.28, min = -20, max = 20, index = 0, },
  { name = "Thickness",   default = .3, min = 0., max = 1, index = 1, },
  { name = "Type",      default = 1, min = 1, max = 5, index = 2, },
  { name = "Tiers",      default = 4, min = 0, max = 10, index = 3, },
} 

kernel.fragment =
[[

float Stretch = CoronaVertexUserData.x;
float Thickness = CoronaVertexUserData.y;
float Type = CoronaVertexUserData.z;
float Tiers = CoronaVertexUserData.w;
//----------------------------------------------

int I_Type = int(Type); //hint_range(1,5) = 1;
uniform float Rays = 6; //hint_range(0.,20., 1) = 6;
uniform float Speed = 1.5; //hint_range(0., 20., .01) = .5;
uniform float Fade = .1; //hint_range(0., 3., .01) = .1;
//uniform float Thickness  = .3; //hint_range(0., 1., .01) = .3;


// not used by all sprials
//uniform float tiers = 4; //hint_range(0., 20., 1) = 4;
//uniform float Stretch = 6.28; //hint_range(0., 10., .1) = 6.28;

uniform vec3 color = vec3( 0.0, 1.0, 0.0 );
uniform vec3 s5color2 = vec3( 1.0, 0.0, 0.0 );

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
    COLOR.rgb = color;
    
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
        COLOR.rgb = mix(color, s5color2, Thickness*fract((2.*r-(angle+PI)/TAU)*Rays + 
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


