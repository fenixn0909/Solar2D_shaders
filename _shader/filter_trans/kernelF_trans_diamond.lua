
--[[

  Origin Author: mackatap
  https://godotshaders.com/shader/diamond-based-screen-transition/

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "diamond"


kernel.vertexData =
{
  {
    name = "progress",
    default = .5,
    min = 0,
    max = 1,
    index = 0, 
  },
  {
    name = "pixelSize",
    default = 20,
    min = 5,
    max = 250,
    index = 1, 
  },
}


kernel.fragment =
[[

float progress = CoronaVertexUserData.x;
float diamondPixelSize = CoronaVertexUserData.y;

//----------------------------------------------

float when_lt(float x, float y) { return max(sign(y - x), 0.0); }

//----------------------------------------------

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

  P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV);
  P_UV vec4 FRAGCOORD = gl_FragCoord;

  //----------------------------------------------
  
  float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
  float yFraction = fract(FRAGCOORD.y / diamondPixelSize);
  float xDistance = abs(xFraction - 0.5);
  float yDistance = abs(yFraction - 0.5);
  
  COLOR.a *=  when_lt(xDistance + yDistance + UV.x + UV.y, progress * 4.0);
  COLOR.rgb *= COLOR.a;
  
  //----------------------------------------------

  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


