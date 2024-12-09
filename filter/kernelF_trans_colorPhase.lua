
--[[

  Origin Author: gre
  https://gl-transitions.com/editor/colorphase
  License: MIT

  Message:
  // Usage: fromStep and toStep must be in [0.0, 1.0] range 
  // and all(fromStep) must be < all(toStep)

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "colorPhase"

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
uniform vec4 fromStep = vec4(0.0, 0.2, 0.4, 0.0); //
uniform vec4 toStep = vec4(0.6, 0.8, 1.0, 1.0); //

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 uv = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime));
  //----------------------------------------------
  
  //vec4 a = getFromColor(uv);
  //vec4 b = getToColor(uv);
  //return mix(a, b, smoothstep(fromStep, toStep, vec4(progress)));

  //----------------------------------------------
  vec4 a = texture2D( CoronaSampler0, uv );
  vec4 b = colorBG;

  COLOR = mix(a, b, smoothstep(fromStep, toStep, vec4(progress)));
  
  return CoronaColorScale( COLOR );
}
]]

return kernel

--[[

--]]


