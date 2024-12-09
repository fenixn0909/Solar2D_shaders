
--[[
  Origin Author: snesmocha
  https://godotshaders.com/author/snesmocha/
  
  tutorial followed from here:
  https://www.youtube.com/watch?v=SCHdglr35pk

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "deform"
kernel.name = "impact"
kernel.isTimeDependent = true

-- Expose effect parameters using vertex data
kernel.vertexData   = {
  {
    name = "intensity",
    default = 0.65, 
    min = 0,
    max = 1,
    index = 0,  -- This corresponds to "CoronaVertexUserData.x"
  },
  {
    name = "size",
    default = 0.1, 
    min = 0,
    max = 1,
    index = 1,  -- This corresponds to "CoronaVertexUserData.y"
  },
  {
    name = "tilt",
    default = 0.2, 
    min = 0.0,
    max = 2.0,
    index = 2,  -- This corresponds to "CoronaVertexUserData.z"
  },
  {
    name = "speed",
    default = 1.0, 
    min = 0.1,
    max = 10.0,
    index = 3,  -- This corresponds to "CoronaVertexUserData.w"
  },
}


kernel.fragment =
[[

vec2 center;
float force;
float size;
float thickness;

float screenHeight = 320;
float screenWidth = 480;

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  //vec2 SCREEN_UV = vec2( texCoord.x/screenHeight, texCoord.y/screenWidth);
  vec2 SCREEN_UV = texCoord;


  float ratio = CoronaTexelSize.z / CoronaTexelSize.w;
  vec2 scaledUV = (SCREEN_UV - vec2(0.5,0.0)) / vec2(ratio, 1) + vec2(0.5,0.0);
  float mask = (1.0 - smoothstep(size-0.1,size, length(scaledUV - center))) * 
  smoothstep(size-thickness-0.1,size-thickness, length(scaledUV - center));
  vec2 disp = normalize(scaledUV - center) * force * mask;

  P_COLOR vec4 texColor = texture2D( CoronaSampler0, SCREEN_UV - disp);
  //texColor.rgb = vec3(mask);
  

  //COLOR = texture(SCREEN_TEXTURE,SCREEN_UV - disp);
  //COLOR.rgb = vec3(mask);
      
    
  return CoronaColorScale( texColor );
}
]]

return kernel


--[[



--]]





