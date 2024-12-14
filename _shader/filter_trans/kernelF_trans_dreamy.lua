
--[[
  Origin Author: mikolalysenko
  https://gl-transitions.com/editor/Dreamy
  License: MIT


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "dreamy"

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
vec4 colorBG = vec4(0.0, 0.0, 0, 0);

vec2 offset(float progress, float x, float theta) {
  float phase = progress*progress + progress + theta;
  float shifty = 0.03*progress*cos(10.0*(progress+x));
  return vec2(0, shifty);
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 p = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------

  //return mix(getFromColor(p + offset(progress, p.x, 0.0)), getToColor(p + offset(1.0-progress, p.x, 3.14)), progress);

  vec4 fromColor = texture2D(CoronaSampler0, p + offset( progress, p.x, 0.0 ) );
  vec4 toColor = colorBG;

  COLOR = mix( fromColor, toColor, progress);

  //COLOR.a = 1-progress; // Inversion
  //COLOR.rgb *= COLOR.a;

  //----------------------------------------------

  
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


