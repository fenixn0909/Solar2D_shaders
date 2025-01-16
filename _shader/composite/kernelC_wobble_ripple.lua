
--[[
  
]]


local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "wobble"
kernel.name = "ripple"

kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "Strength",
    default = 0.05,
    min = 0,
    max = 5,
    index = 0,    
  },
  {
    name = "Speed",
    default = 1,
    min = -360,
    max = 360,     
    index = 1,    
  },
}


kernel.fragment =
[[

///sampler2D flowMap; // use CoronaSampler1,  Displacement map
//----------------------------------------------

float Strength = CoronaVertexUserData.x;
float Speed = CoronaVertexUserData.y;

//----------------------------------------------
vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
  mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
            vec2(cos(angle), sin(angle)));
  
  uv -= pivot;
  uv = uv * rotation;
  uv += pivot;
  return uv;
}
//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  vec2 rotated_uv = rotate(UV, vec2(0.5), CoronaTotalTime * Speed);
  vec4 offset = texture2D(CoronaSampler1, vec2(rotated_uv.x , rotated_uv.y )) * Strength; //Get offset 
  P_COLOR vec4 COLOR = texture2D(CoronaSampler0, vec2(UV.x,UV.y) + offset.xy - vec2(0.5,0.5)*Strength); //We need to remove the displacement 
  //----------------------------------------------
  return CoronaColorScale(COLOR);
}
]]

return kernel

