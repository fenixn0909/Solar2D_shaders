
--[[
  Origin Author: snesmocha
  https://godotshaders.com/author/snesmocha/
  
  --Not Done Yet

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "color"
kernel.name = "rgbOffset"

--Test
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


kernel.vertex =
[[



vec2 deformation = vec2(0.0, 0.0);
float sideWaysDeformationFactor = 5.0;
float knockbackFactor = 0.4;


P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{
  P_POSITION vec2 VERTEX = position;

  //sideWaysDeformationFactor = sin(CoronaTotalTime * 1) * 5;
  deformation.y = sin(CoronaTotalTime * 1) * 0.5;
  knockbackFactor = sin(CoronaTotalTime * 0.5) * 0.5;

  vec2 deformationStrength = abs(deformation);
  float sideWaysDeformation = min(deformationStrength.x, deformationStrength.y);
  float spriteWidth = abs(VERTEX.x);
  if (sign(VERTEX.y) != sign(deformation.y)) {
    VERTEX.x += sideWaysDeformation * sideWaysDeformationFactor * spriteWidth * sign(deformation.x);
  }
  vec2 scale = 1.0 - deformationStrength;
  
  VERTEX.x *= scale.x / scale.y;
  VERTEX.y *= scale.y / scale.x;
  VERTEX.xy += deformation * spriteWidth * knockbackFactor;


  return VERTEX;
}

]]

return kernel


--[[

shader_type canvas_item;
render_mode unshaded;

uniform sampler2D displace : hint_albedo;
uniform float dispAmt: hint_range(0,0.1);
uniform vec2 abberationAmtXR = vec2(0,0);
uniform vec2 abberationAmtXG =  vec2(0,0);
uniform vec2 abberationAmtXB =  vec2(0,0);

uniform float dispSize: hint_range(0.1, 2.0);
uniform float maxAlpha : hint_range(0.1,1.0);

void fragment()
{
    //displace effect
    vec4 disp = texture(displace, SCREEN_UV * dispSize);
    vec2 newUV = SCREEN_UV + disp.xy * dispAmt;
    //abberation
    COLOR.r = texture(SCREEN_TEXTURE, newUV - abberationAmtXR).r; 
    COLOR.g = texture(SCREEN_TEXTURE, newUV + abberationAmtXG).g; 
    COLOR.b = texture(SCREEN_TEXTURE, newUV + abberationAmtXB).b;
    COLOR.a = texture(SCREEN_TEXTURE, newUV).a * maxAlpha;
    }

--]]





