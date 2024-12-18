
--[[
  
    Origin Author: Emil
    https://www.shadertoy.com/view/3d3XWr

    template for glowy shiny thingy
    

    #VARIATION Find the tag and tweak them for different patterns
    
--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG" 
kernel.name = "shineDramatic"


kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",         default = 1, min = 0, max = 20, index = 0, },
  { name = "Size",          default = 1, min = 0, max = 10, index = 1, },
  { name = "Shaping1",      default = 2.0, min = -15, max = 15, index = 2, },
  { name = "Shaping2",      default = 2.0, min = -15, max = 15, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Size = CoronaVertexUserData.y;
float Shaping1 = CoronaVertexUserData.z;
float Shaping2 = CoronaVertexUserData.w;

//----------------------------------------------

P_UV vec2 iResolution = vec2(1. ,1.);

//P_COLOR vec4 color_mod = vec4( 1.2, 0.6, 6.9, 1);
P_COLOR vec4 color_mod = vec4( 1.7, 1.2, .9, 1);
//P_COLOR vec4 color_mod = vec4( 1, 1, 1, 1);

//----------------------------------------------
#define PI 3.141592653

// -----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float iTime = CoronaTotalTime;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    P_UV vec2 fragCoord = ( UV.xy / iResolution );
    //P_UV vec2 fragCoord = abs(dFdx(UV)) + abs(dFdy(UV));

    //----------------------------------------------
    float newTime = iTime * Speed;
        
    // uvs from -1 to 1 in Y height
    //vec2 uv = (fragCoord-iResolution.xy*0.5)/iResolution.y;
    // Better Result!
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;

    float radial = atan(uv.x, uv.y)/(PI*2.);

    float shine1 = abs(fract((radial + newTime*0.12)*2.)-0.5)*2.0;
    float shine2 = abs(fract((radial + newTime*-0.06)*5.)-0.5)*Shaping1;    // 2.0
    float shine3 = abs(fract((radial + newTime*0.001)*11.)-0.5)*Shaping2;   // 2.0

    float shines = 0.0;
    shines += shine1*0.13;
    shines += shine2*0.23;
    shines += shine3*0.33;
    shines = smoothstep(0.2, 0.5, shines);

    float luv = length(uv)* 1/Size;

    shines =  shines * (0.12/luv);

    shines = clamp(shines, 0.0, 1.0)*smoothstep(0.03,0.25, luv);
    //shines *= 1.6;
    shines *= smoothstep(1.0, 0.0, luv);
    shines = clamp(shines, 0.0, 1.0);

    // #VARIATION: Glowing Core
    COLOR = vec4(mix(shines,1.0,smoothstep(0.4, 0.0, luv)));

    // #VARIATION: Empty Core
    //COLOR = vec4(shines);

    //----------------------------------------------

    // Color Mod
    COLOR.rgb *= color_mod.rgb;
    
    // Reduce Radius <Shorten Tails>
    //COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


