
--[[
  Origin Author: yumaikas
  https://godotshaders.com/author/yumaikas/

--]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "color"
kernel.name = "corruption"

kernel.isTimeDependent = true


kernel.vertexData   = {
  {
    name = "texDiffRatioX",
    default = 1,
    min = 0,
    max = 32,  
    index = 0,    
  },
  {
    name = "texDiffRatioY",
    default = 1,
    min = 0,
    max = 32,  
    index = 1,    
  },
  
}


kernel.fragment =
[[
vec2 texDiffRatio = vec2( CoronaVertexUserData.x, CoronaVertexUserData.y );


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_UV vec2 uvTex = UV * texDiffRatio;
  float TIME = CoronaTotalTime;
  float dSampleScale = v_UserData.x * 0.5;
  //float dSampleScale = 0.1;

  vec4 main_texture = texture2D(CoronaSampler0, UV);
  float dissolve_value = mix(0.5, 0.6, sin(TIME));


  vec4 noise_texture = texture2D(CoronaSampler1, (uvTex+0.5 + vec2(0.5*sin(TIME/5.0),0.5*cos(TIME/5.0))/5.0) / dSampleScale );
  float mult = floor(dissolve_value + min(1, noise_texture.x));
  main_texture.g *= mult;
  main_texture.r -= mult - 0.1;
  main_texture.g -= mult - 0.1;
  main_texture.b -= mult - 0.1;
  P_COLOR vec4 COLOR = main_texture;

  return CoronaColorScale(COLOR);
}
]]

return kernel
