 
--[[
    https://www.shadertoy.com/view/lsKSWR

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "Lit"
kernel.name = "vignette2"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Intensity",     default = 15.0, min = 0, max = 200, index = 0, },
  { name = "Extend",        default = 0.5, min = 0, max = 20, index = 1, },
} 

kernel.fragment =
[[

float Intensity = CoronaVertexUserData.x;
float Extend = CoronaVertexUserData.y;
//----------------------------------------------
P_COLOR vec3 color = vec3( .2, 0.0, 0.0 );

//----------------------------------------------

P_COLOR vec4 COLOR = vec4(0);
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
    //----------------------------------------------
    vec2 uv = UV;
    uv *= 1.0 - uv.yx;   //vec2(1.0)- uv.yx; -> 1.-u.yx; Thanks FabriceNeyret !
    float vig = uv.x*uv.y * Intensity; // multiply with sth for intensity
    vig = pow(vig, Extend); // change pow for modifying the extend of the  vignette
    
    COLOR = vec4(1-vig); 
    COLOR.rgb = color;
    //----------------------------------------------
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


