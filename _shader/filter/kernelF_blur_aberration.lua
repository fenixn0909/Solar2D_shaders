
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

--Test
kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "gridAmount",
    default = 3,
    min = 1,
    max = 24,
    index = 0,    -- v_UserData.x;  use a_UserData.x if #kernel.vertexData == 1 ?
  },
  {
    name = "paletteRowCols",
    default = 4,
    min = 1,
    max = 16,     -- 16x16->256
    index = 1,    -- v_UserData.y
  },
}


kernel.fragment =
[[


int levels = 12; // Skialith layers
float spread = 0.1; // Strech X

vec3 chromatic_slice(float t){
  vec3 res = vec3(1.0-t, 1.0 - abs(t - 1.0), t - 1.0);
  return max(res, 0.0);
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  //SCREEN_TEXTURE = CoronaSampler0;
  P_COLOR vec4 COLOR;
  
  P_UV vec2 UV = texCoord;
  P_UV vec2 SCREEN_UV = UV*1;

  //Test 
  spread = abs(sin(CoronaTotalTime)*1) * 1;

  vec3 sum;
  COLOR.rgb = vec3(0);
  vec2 offset = (UV - vec2(0.5))*vec2(1,-1);
  for(int i = 0; i < levels; i++){
    float t = 2.0*float(i)/float(levels-1); // range 0.0->2.0
    vec3 slice = vec3(1.0-t, 1.0 - abs(t - 1.0), t - 1.0);
    slice = max(slice, 0.0);
    sum += slice;
    vec2 slice_offset = (t-1.0)*spread*offset;
    COLOR.rgb += slice * texture2D(CoronaSampler0, SCREEN_UV + slice_offset).rgb;
  }
  COLOR.rgb /= sum;

  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


