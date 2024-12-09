
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
  {
    name = "textPxW",
    default = 600,
    min = 0,
    max = 9999,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "textPxH",
    default = 2000,
    min = 1,
    max = 9999,     
    index = 1,    -- v_UserData.y
  },
}




kernel.fragment =
[[

float textPxW = CoronaVertexUserData.x;
float textPxH = CoronaVertexUserData.y;

P_UV vec2 SCREEN_PIXEL_SIZE = 1/vec2( textPxW, textPxH );
//P_UV vec2 SCREEN_PIXEL_SIZE = 1/vec2( 200, 200 );

//----------------------------------------------

//uniform bool enabled = false;
uniform bool enabled = true;

//----------------------------------------------


//----------------------------------------------

P_COLOR vec4 COLOR;
P_DEFAULT float TIME = CoronaTotalTime; // * speed

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
    vec4 FRAGCOORD = gl_FragCoord; 
    //----------------------------------------------

    // Called for every pixel the material is visible on.
    
    if (enabled){
        float s = 0.0, v = 0.0;
        //vec2 ires = 1.0 / SCREEN_PIXEL_SIZE;
        vec2 ires = 1.0 / CoronaTexelSize.zw;
        //vec2 uv = (FRAGCOORD.xy/ ires) * 2.0 - 1.;
        vec2 uv = (UV.xy/ ires) * 2.0 - 1.;
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


