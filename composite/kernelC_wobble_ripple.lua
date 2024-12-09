


local kernel = {}
kernel.language = "glsl"
kernel.category = "composite"
kernel.group = "wobble"
kernel.name = "ripple"

kernel.isTimeDependent = true


kernel.vertexData =
{
  {
    name = "textureRatio",
    default = 1,
    min = 0,
    max = 9999,
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

//sampler2D flowMap; // use CoronaSampler1,  Displacement map

float strength = 0.05;    //Force of the effect
float speed = 1;       //Speed of the effect

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
  mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
            vec2(cos(angle), sin(angle)));
  
  uv -= pivot;
  uv = uv * rotation;
  uv += pivot;
  return uv;
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;

  vec2 rotated_uv = rotate(UV, vec2(0.5), CoronaTotalTime);
  vec4 offset = texture2D(CoronaSampler1, vec2(rotated_uv.x , rotated_uv.y )) * strength; //Get offset 
  P_COLOR vec4 COLOR = texture2D(CoronaSampler0, vec2(UV.x,UV.y) + offset.xy - vec2(0.5,0.5)*strength); //We need to remove the displacement 
  
  return CoronaColorScale(COLOR);
}
]]

return kernel

