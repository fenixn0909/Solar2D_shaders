
--[[
  Godot Shader Snippet
  
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "BG"
kernel.name = "spiralColored"

--Test
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

uniform vec4 color = vec4 (1, 0, 0, 1);// hint

//----------------------------------------------

float f_swirl(vec2 uv, float size, int arms)
{
  float angle = atan(-uv.y + 0.5, uv.x - 0.5) ;
  float len = length(uv - vec2(0.5, 0.5));
  
  return sin(len * size + angle * float(arms));
}

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
  mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
            vec2(cos(angle), sin(angle)));
  
  uv -= pivot;
  uv = uv * rotation;
  uv += pivot;
  return uv;
}


P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{

  
    P_COLOR vec4 COLOR = vec4(color.rgb,color.a);

    int arms = 10;
    float _size = -abs(sin(CoronaTotalTime*0.5) * 20);
    //float _size = 10;
    //float swirl = f_swirl(UV, _size, arms);

    vec2 rotated_uv = rotate(UV, vec2(0.5), CoronaTotalTime);
    float swirl = f_swirl(rotated_uv, _size, arms);

    COLOR += vec4(vec3(swirl), 1.0); //Swirl
    //----------------------------------------------

    COLOR.rgb *= COLOR.a;



    return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


