
--[[
  Origin Author: mandubian
  https://gl-transitions.com/editor/ButterflyWaveScrawler

  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "waveScrawler"

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
vec4 colorBG = vec4(0,0,0,0);
//----------------------------------------------

uniform float amplitude = 2.0; // 
uniform float waves = 60.0; // 
uniform float colorSeparation = 0.3; // 
float PI = 3.14159265358979323846264;

float compute(vec2 p, float progress, vec2 center) {
  vec2 o = p*sin(progress * amplitude)-center;
  // horizontal vector
  vec2 h = vec2(1., 0.);

  // butterfly polar function (don't ask me why this one :))
  float theta = acos(dot(o, h)) * waves;
  return (exp(cos(theta)) - 2.*cos(4.*theta) + pow(sin((2.*theta - PI) / 24.), 5.)) / 10.;
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV);
  progress = abs(sin(CoronaTotalTime*0.5));
  //progress = 0.5;
  //----------------------------------------------

  vec2 p = UV.xy / vec2(1.0).xy;
  float inv = 1. - progress;
  vec2 dir = p - vec2(.5);
  float dist = length(dir);
  float disp = compute(p, progress, vec2(0.5, 0.5)) ;
  //vec4 texTo = getToColor(p + inv*disp);
  /*
  vec4 texFrom = vec4(
  getFromColor(p + progress*disp*(1.0 - colorSeparation)).r,
  getFromColor(p + progress*disp).g,
  getFromColor(p + progress*disp*(1.0 + colorSeparation)).b,
  1.0);
  return texTo*progress + texFrom*inv;
  */
  //----------------------------------------------

  vec4 texTo = colorBG;
  vec4 texFrom = vec4(
  texture2D( CoronaSampler0, p + progress*disp * ( 1.0 - colorSeparation )).r,
  texture2D( CoronaSampler0, p + progress*disp ).g,
  texture2D( CoronaSampler0, p + progress*disp * ( 1.0 + colorSeparation )).b,
  //texture2D(CoronaSampler0, UV).a
  1.0
  );

  colorBG.rgb *= colorBG.a;
  //COLOR = texTo*progress + texFrom*inv;
  COLOR = texFrom * inv;

  //COLOR.a *= m;
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


