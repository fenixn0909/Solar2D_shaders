 
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
  {
    name = "resolutionX",
    default = 1,
    min = 1,
    max = 99,
    index = 0, 
  },
}


kernel.fragment =
[[

//----------------------------------------------

uniform float outerRadius = 2.5; // : hint_range(0.0, 5.0) = 1.0;
uniform float mainAlpha = 1.5; // : hint_range(0.0, 1.0) = 1.0;
//P_COLOR vec3 color = vec3( 1.0, 0.3, 0.2 );
P_COLOR vec3 color = vec3( 0.0 );

//----------------------------------------------

P_COLOR vec4 COLOR;
//----------------------------------------------

// -----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------
  
    float x = abs(UV.x-.5)*2.0;
    float y = abs(UV.y-.5)*2.0;
    float v = (sqrt((x*x)+(y*y))/outerRadius);
    //COLOR = vec4(0,0,0, v * mainAlpha);
    COLOR = vec4(color, v * mainAlpha);
  //----------------------------------------------
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


