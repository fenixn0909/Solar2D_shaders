
--[[
  Origin Author: Gunnar Roth
  https://gl-transitions.com/editor/GlitchMemories
  
  based on work from natewave
  License: MIT

--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "shaky"

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

  vec2 block = floor(UV.xy / vec2(16));
  vec2 uv_noise = block / vec2(64);
  uv_noise += floor(vec2(progress) * vec2(1200.0, 3500.0)) / vec2(64);
  vec2 dist = progress > 0.0 ? (fract(uv_noise) - 0.5) * 0.3 *(1.0 -progress) : vec2(0.0);
  vec2 red = UV + dist * 0.2;
  vec2 green = UV + dist * .3;
  vec2 blue = UV + dist * .5;

  //return vec4(mix(getFromColor(red), getToColor(red), progress).r,mix(getFromColor(green), getToColor(green), progress).g,mix(getFromColor(blue), getToColor(blue), progress).b,1.0);
  
  //----------------------------------------------
  /*
  float r = mix( texture2D( CoronaSampler0, red ).r, colorBG.r, progress );
  float g = mix( texture2D( CoronaSampler0, green ).g, colorBG.g, progress );
  float b = mix( texture2D( CoronaSampler0, blue ).b, colorBG.b, progress );
  float a = texture2D( CoronaSampler0, UV ).a;
  */

  float r = texture2D( CoronaSampler0, red ).r;
  float g = texture2D( CoronaSampler0, green ).g;
  float b = texture2D( CoronaSampler0, blue ).b;
  float a = texture2D( CoronaSampler0, UV ).a;



  COLOR = vec4(r,g,b,a);
  COLOR.a *= clamp( 1-progress, 0, 1);
  COLOR.rgb *= COLOR.a;
  
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


