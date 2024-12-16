
--[[
    https://godotshaders.com/shader/hyper-space-speed-effect/
    llyrric
    February 24, 2024
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FX"
kernel.name = "hyperSpaceSpeed"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Speed",     default = 1, min = -5, max = 5, index = 0, },
  { name = "Pattern",   default = 0.0, min = -7, max = 7, index = 1, },
  { name = "PanX",      default = 800., min = -2000, max = 20000, index = 2, },
  { name = "PanY",      default = 800., min = -2000, max = 20000, index = 3, },
} 

kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Pattern = CoronaVertexUserData.y;
float PanX = CoronaVertexUserData.z;
float PanY = CoronaVertexUserData.w;
//----------------------------------------------
float Bright = 0.0;
bool enabled = true;

//----------------------------------------------

P_COLOR vec4 COLOR;
P_UV vec2 SCREEN_PIXEL_SIZE = CoronaTexelSize.zw;
P_DEFAULT float TIME = CoronaTotalTime * Speed; // * speed

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    //vec4 FRAGCOORD = gl_FragCoord; 
    vec2 FRAGCOORD = UV ; 
    FRAGCOORD.x *= PanX;
    FRAGCOORD.y *= PanY;

    //----------------------------------------------

    // Called for every pixel the material is visible on.
    
    if (enabled){
        float s = Pattern, v = Bright;
        vec2 ires = 1.0 / SCREEN_PIXEL_SIZE;
        vec2 uv = (FRAGCOORD.xy/ ires) * 2.0 - 1.;
        //vec2 uv = (UV.xy/ ires) * 2.0 - 1.;
        //vec2 uv = ( CoronaTexelSize.xy / ires) * 2.0 - 1.;
        
        float itime = (TIME-2.0)*58.0;
        vec3 col = vec3(0);
        vec3 init = vec3(sin(itime * .0032)*.3, .35 - cos(itime * .005)*.3, itime * 0.002);
        for (int r = 0; r < 100; r++) 
        {
            vec3 p = init + s * vec3(uv, 0.05);
            p.z = fract(p.z);
            // Thanks to Kali's little chaotic loop...
            for (int i=0; i < 10; i++)  p = abs(p * 2.04) / dot(p, p) - .9;
            v += pow(dot(p, p), .7) * .06;
            col +=  vec3(v * 0.2+.4, 12.-s*2., .1 + v * 1.) * v * 0.00003;
            s += .025;
        }
        COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
    }

    //----------------------------------------------


    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


