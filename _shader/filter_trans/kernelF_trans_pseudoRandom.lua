
--[[
    Origin Author: Brandon Anzaldi
    https://github.com/gl-transitions/gl-transitions/blob/master/transitions/TVStatic.glsl
    License: MIT


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "pseudoRandom"

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

uniform float offset = 0.1;

highp float noise(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy * progress, vec2(a, b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 p = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime*1));
  //progress = 0.1;
  //----------------------------------------------

  if (progress < offset) {
    //return getFromColor(p);
    COLOR = texture2D( CoronaSampler0, p);
    //COLOR += vec4(vec3(noise(p)), progress)
    //return CoronaColorScale( texture2D( CoronaSampler0, p) );
    return CoronaColorScale( COLOR );
  } else if (progress > (1.0 - offset)) {
    //return getToColor(p);
    return CoronaColorScale( colorBG );
  } else {
    //return vec4(vec3(noise(p)), 1.0);
    COLOR = vec4(vec3(noise(p)), 1-progress);
    COLOR.rgb *= COLOR.a;
    return CoronaColorScale( COLOR );
  }


  //----------------------------------------------

  
  //return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


