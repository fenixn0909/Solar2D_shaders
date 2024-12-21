
--[[
  Origin Author: hayden
  https://godotshaders.com/author/hayden/
  
  Adjustable chromatic abberation.

  levels determines the level of detail.

  spread determines the intensity of the effect.

  
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "blur"
kernel.name = "aberration"

kernel.isTimeDependent = true

kernel.vertexData =
{
  { name = "Spread",     default = 0, min = -2, max = 2, index = 0, },
  { name = "Levels",     default = 7, min = 1, max = 50, index = 1, },
} 

kernel.fragment =
[[

float Spread = CoronaVertexUserData.x;
float Levels = CoronaVertexUserData.y;
//----------------------------------------------

//----------------------------------------------
vec3 chromatic_slice(float t){
  vec3 res = vec3(1.0-t, 1.0 - abs(t - 1.0), t - 1.0);
  return max(res, 0.0);
}
//----------------------------------------------

P_COLOR vec4 COLOR = vec4(0);

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  
  //----------------------------------------------
  //Test 
  //Spread = abs(sin(CoronaTotalTime)*1) * 1;

  vec3 sum;
  COLOR.rgb = vec3(0);
  vec2 offset = (UV - vec2(0.5))*vec2(1,-1);
  for(int i = 0; i < Levels; i++){
    float t = 2.0*float(i)/float(Levels-1); // range 0.0->2.0
    vec3 slice = vec3(1.0-t, 1.0 - abs(t - 1.0), t - 1.0);
    slice = max(slice, 0.0);
    sum += slice;
    vec2 slice_offset = (t-1.0)*Spread*offset;
    COLOR.rgb += slice * texture2D(CoronaSampler0, UV + slice_offset).rgb;
  }
  COLOR.rgb /= sum;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


