
--[[

  Origin Author: Sergey Kosarevsky ( http://www.linderdaum.com )
  https://gl-transitions.com/editor/Swirl
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "swirl"

--Test
-- kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = .5,
    min = 0,
    max = 1,
    index = 0, 
  },
}


kernel.fragment =
[[
P_DEFAULT float progress = CoronaVertexUserData.x;
vec4 colorBG = vec4(0,0,0,0);
//----------------------------------------------


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  float Radius = 1.0;

  float T = progress;

  UV -= vec2( 0.5, 0.5 );

  float Dist = length(UV);

  if ( Dist < Radius )
  {
    float Percent = (Radius - Dist) / Radius;
    float A = ( T <= 0.5 ) ? mix( 0.0, 1.0, T/0.5 ) : mix( 1.0, 0.0, (T-0.5)/0.5 );
    float Theta = Percent * Percent * A * 8.0 * 3.14159;
    float S = sin( Theta );
    float C = cos( Theta );
    UV = vec2( dot(UV, vec2(C, -S)), dot(UV, vec2(S, C)) );
  }
  UV += vec2( 0.5, 0.5 );

  //vec4 C0 = getFromColor(UV);
  //vec4 C1 = getToColor(UV);

  vec4 C0 = texture2D( CoronaSampler0, UV );
  vec4 C1 = colorBG;
  
  
  //return mix( C0, C1, T );

  //----------------------------------------------
  

  return CoronaColorScale( mix( C0, C1, T ) );
}
]]

return kernel

--[[

--]]


