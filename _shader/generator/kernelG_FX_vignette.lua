 
--[[
    https://godotshaders.com/shader/vignette-2/
    imakeshaders
    September 29, 2024

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "FX"
kernel.name = "vignette"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "OutRad",     default = 1.25, min = 0, max = 5, index = 0, },
  { name = "Alpha",      default = 0.5, min = 0, max = 2, index = 1, },
} 

kernel.fragment =
[[

float OutRad = CoronaVertexUserData.x;
float Alpha = CoronaVertexUserData.y;
//----------------------------------------------
P_COLOR vec3 color = vec3( 0.0 );

//----------------------------------------------

P_COLOR vec4 COLOR;
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------
    float x = abs(UV.x-.5)*2.0;
    float y = abs(UV.y-.5)*2.0;
    float v = (sqrt((x*x)+(y*y))/OutRad);
    COLOR = vec4(color, v * Alpha);
  //----------------------------------------------
    COLOR.rgb *= COLOR.a;

    return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


