
--[[

  Origin Author: mackatap
  https://godotshaders.com/shader/diamond-based-screen-transition/

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "diamond"

--Test
-- kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = 1,
    min = 0,
    max = 1,
    index = 0, 
  },
}


kernel.fragment =
[[
P_DEFAULT float progress = CoronaVertexUserData.x;

//vec4 backBG = vec4(0,0,0,0);


uniform float diamondPixelSize = 10.0f; //hint(10, 75)


//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV);
  //progress = abs(sin(CoronaTotalTime));
  P_UV vec4 FRAGCOORD = gl_FragCoord;

  //----------------------------------------------
  
  float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
  float yFraction = fract(FRAGCOORD.y / diamondPixelSize);
  float xDistance = abs(xFraction - 0.5);
  float yDistance = abs(yFraction - 0.5);
  if (xDistance + yDistance + UV.x + UV.y > progress * 4.0) {
    discard;
    //COLOR.rgb = vec3(0,0,0);
  }

  //COLOR.rgb = vec3(1.0 - max(sign( (progress * 4.0) - (xDistance + yDistance + UV.x + UV.y) ), 0.0) );


  //----------------------------------------------
  
    

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


