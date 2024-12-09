
--[[
  Origin Author: snesmocha
  https://godotshaders.com/author/snesmocha/
  
  tutorial followed from here:
  https://www.youtube.com/watch?v=BZp8DwPdj4s

--]]



local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "deform"
kernel.name = "skew"

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



--]]





