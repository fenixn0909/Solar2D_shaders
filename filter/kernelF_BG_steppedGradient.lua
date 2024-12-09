
--[[
    https://godotshaders.com/shader/stepped-gradient/
    imakeshaders
    September 28, 2024
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "BG"
kernel.name = "steppedGradient"


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
  {
    name = "resolutionY",
    default = 1,
    min = 1,
    max = 99,
    index = 1, 
  },
}


kernel.fragment =
[[
P_DEFAULT float resolutionX = CoronaVertexUserData.x;
P_DEFAULT float resolutionY = CoronaVertexUserData.y;

//----------------------------------------------

uniform vec4 first_color = vec4(1.0);
uniform vec4 second_color = vec4(1.0, 0, 0, .5);
uniform float position = 0.5; //: hint_range(-2, 2) 
uniform int stepIntensify = 60; //: hint_range(1, 50) 

//----------------------------------------------

float round( float value){
    return floor( value + float(0.5) );
}

//-----------------------------------------------
P_COLOR vec4 COLOR;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------
    float pos = round(smoothstep(0,1,(position + UV.y) / 2.0) * float(stepIntensify));
    COLOR = mix(first_color,second_color,pos/float(stepIntensify)); 
  //----------------------------------------------
  COLOR.rgb *= COLOR.a;


  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


