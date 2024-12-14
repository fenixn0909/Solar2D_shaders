
--[[
    https://godotshaders.com/shader/stepped-gradient/
    imakeshaders
    September 28, 2024


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "steppedGradient"


kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "position",
    default = 0,
    min = -2,
    max = 2,
    index = 0, 
  },
  {
    name = "stepIntensify",
    default = 1,
    min = 20,
    max = 50,
    index = 1, 
  },
}


kernel.fragment =
[[
float position = CoronaVertexUserData.x;
float stepIntensify = CoronaVertexUserData.y;

//----------------------------------------------
uniform vec4 first_color = vec4(1.0);
uniform vec4 second_color = vec4(1.0, 0, 0, .5);

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


