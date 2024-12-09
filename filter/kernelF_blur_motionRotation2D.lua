--[[
  Original Author : hayden
  https://godotshaders.com/author/hayden/

  Adds directional motion blur to canvas items like Sprite. 
  Direction, size, and quality of blur can be configured.

]]
--]]
local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "blur"
kernel.name = "motionRotation2D"
kernel.isTimeDependent = true


kernel.vertexData =
{
  {
    name = "quality",
    default = 1,
    min = 0,
    max = 9999,
    type = "int",
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

kernel.vertex =
[[





const float ROOT_TWO = 1.41421356237;

varying vec2 v_uv;
varying vec2 pivot = vec2(0.0, 0.0);

P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{
  P_POSITION vec2 VERTEX = position;
  P_UV vec2 UV = CoronaTexCoord;
  P_UV vec2 TEXTURE_PIXEL_SIZE = CoronaTexelSize.zw;


  vec2 vertex = TEXTURE_PIXEL_SIZE * VERTEX;
  vertex = vertex * (2.0 * length(pivot) + ROOT_TWO) + pivot;
  VERTEX = vertex / TEXTURE_PIXEL_SIZE;
  VERTEX += pivot;
  UV = (UV - 0.5) * (2.0 * length(pivot) + ROOT_TWO) + pivot + 0.5;

  v_uv = UV;

  return VERTEX;
}
]]


kernel.fragment =
[[

bool marginDebug = false;
float amount = 0.1;
int quality = 4;

varying vec2 v_uv;
varying vec2 pivot;

float insideUnitSquare(vec2 v) {
    //vec2 s = step(vec2(0.0), v) - step(vec2(1.0), v);
    vec2 s = step(vec2(0.0), v) - step(vec2(1.0), v);
    return s.x * s.y;   
}

vec2 rotate(vec2 uv, vec2 p, float angle)
{
  mat2 rotation = mat2(vec2(cos(angle), -sin(angle)),
            vec2(sin(angle), cos(angle)));

  uv -= p;
  uv = uv * rotation;
  uv += p;
  return uv;
}


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  vec2 v_uvShift = v_uv;
  vec2 v_pivot = pivot;
  
  //Test
  //quality = int( abs(sin(CoronaTotalTime*1)) * 5 );
  //amount = abs(sin(CoronaTotalTime*1)) * 5 ;
  // Angle Adjustment
  //v_pivot.x = abs(sin(CoronaTotalTime*3) * 5.5); //Verticle
  v_pivot.y = abs(sin(CoronaTotalTime*3) * 5.5);  //Horizontal

  P_UV vec2 UV = v_uvShift;

  float inSquare = insideUnitSquare(UV);
  float numSamples = inSquare;
  P_COLOR vec4 COLOR = texture2D(CoronaSampler0, UV) * inSquare;
  float stepSize = amount/(float(quality));
  vec2 uv;
  for(int i = 1; i <= quality; i++){
    uv = rotate(UV, v_pivot + 0.0, float(i)*stepSize);
    inSquare = insideUnitSquare(uv);
    numSamples += inSquare;
    COLOR += texture2D(CoronaSampler0, uv) * inSquare;
    
    uv = rotate(UV, v_pivot + 0.0, -float(i)*stepSize);
    inSquare = insideUnitSquare(uv);
    numSamples += inSquare;
    COLOR += texture2D(CoronaSampler0, uv) * inSquare;
  }
  COLOR.rgb /= numSamples;
  COLOR.a /= float(quality)*2.0 + 1.0;
  if(marginDebug) COLOR += 0.1;


  return CoronaColorScale(COLOR);
}
]]

return kernel



--[[

  

--]]
