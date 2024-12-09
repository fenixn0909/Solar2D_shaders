
--[[
  Origin Author: Fernando Kuteken
  https://gl-transitions.com/editor/rotate_scale_fade

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "rotSclFade"

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
//----------------------------------------------

#define PI 3.14159265359

uniform vec2 center = vec2(0.5, 0.5);
uniform float rotations = 4;
uniform float scale = 8;
uniform vec4 backColor = vec4(0.15, 0.15, 0.15, 1.0);


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  //progress = sin(CoronaTotalTime*1);
  //----------------------------------------------

  vec2 difference = UV - center;
  vec2 dir = normalize(difference);
  float dist = length(difference);
  
  float angle = 2.0 * PI * rotations * progress;
  
  float c = cos(angle);
  float s = sin(angle);
  
  float currentScale = mix(scale, 1.0, 2.0 * abs(progress - 0.5));
  
  vec2 rotatedDir = vec2(dir.x  * c - dir.y * s, dir.x * s + dir.y * c);
  vec2 rotatedUv = center + rotatedDir * dist / currentScale;
  
  COLOR = texture2D( CoronaSampler0, rotatedUv);

  /*
  if (rotatedUv.x < 0.0 || rotatedUv.x > 1.0 ||
      rotatedUv.y < 0.0 || rotatedUv.y > 1.0)
    COLOR = backColor;
  */

  COLOR.a *= clamp( 1-progress, 0, 1);
  COLOR.rgb *= clamp( COLOR.a, 0, 1);

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


