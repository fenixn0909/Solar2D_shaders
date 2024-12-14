
--[[
  Origin Author: Mr Speaker
  https://gl-transitions.com/editor/pinwheel
  License: MIT
  
  

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "pinwheel"

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
uniform float speed = 2.0;

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 uv = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime*1));
  //progress = 0;
  //----------------------------------------------

  vec2 p = uv.xy / vec2(1.0).xy;
    
  float circPos = atan(p.y - 0.5, p.x - 0.5) + progress * speed;
  float modPos = mod(circPos, 3.1415 / 4.);
  float signed = sign(progress - modPos);
  
  //return mix(getToColor(p), getFromColor(p), step(signed, 0.5));
  //----------------------------------------------

  vec4 cFrom = texture2D( CoronaSampler0, p);
  vec4 cTo = colorBG;
  COLOR = mix( cFrom, cTo, step(signed, 0.5) );
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


