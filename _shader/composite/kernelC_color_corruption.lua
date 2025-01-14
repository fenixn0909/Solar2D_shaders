
--[[
  Origin Author: yumaikas
  https://godotshaders.com/shader/corruption/

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "color"
kernel.name = "corruption"

kernel.isTimeDependent = true
kernel.textureWrap = 'repeat'

kernel.vertexData =
{
  { name = "Speed",   default = 3, min = -10, max = 10, index = 0, },
  { name = "Reduce",  default = .14, min = -1, max = 1.25, index = 1, },
  { name = "Scale",  default = .25, min = 0, max = 5, index = 2, },
  { name = "Fade",  default = 8, min = 0, max = 75, index = 3, },
} 



kernel.fragment =
[[

float Speed = CoronaVertexUserData.x;
float Reduce = CoronaVertexUserData.y;
float Scale = CoronaVertexUserData.z;
float Fade = CoronaVertexUserData.w;

//----------------------------------------------
float when_gt(float x, float y) { //greater than return 1
  return max(sign(x - y), 0.0);
}
//----------------------------------------------

float TIME = CoronaTotalTime * Speed;

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  P_UV vec2 uvTex = UV;
  
  vec4 main_texture = texture2D(CoronaSampler0, UV);
  float dissolve_value = mix(0.5, 0.6, sin(TIME));

  vec4 noise_texture = texture2D(CoronaSampler1, (uvTex+0.5 + vec2(0.5*sin(TIME/5.0),0.5*cos(TIME/5.0))/5.0) / Scale );
  float mult = floor(dissolve_value + min(1, noise_texture.x));
  main_texture.g *= mult;
  main_texture.rgb -= mult - Reduce;

  //----------------------------------------------
  P_COLOR vec4 COLOR = main_texture;
  float avg = (COLOR.r + COLOR.g + COLOR.b) * .3333;
  COLOR.a *= when_gt( avg, Fade * 0.01 );
  COLOR.rgb *= COLOR.a;

  return CoronaColorScale(COLOR);
}
]]

return kernel
