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
kernel.name = "motion2D"
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
varying vec2 dir = vec2( 0.05, 0.05 );
varying vec2 v_uv;

P_POSITION vec2 VertexKernel( P_POSITION vec2 position )
{
  P_POSITION vec2 VERTEX = position;
  P_UV vec2 UV = CoronaTexCoord;

  vec2 blurSize = abs(dir) * 2.0;
  VERTEX *= blurSize + 1.0;
  UV = (UV - 0.5) * (blurSize + 1.0) + 0.5;
  v_uv = UV;


  return VERTEX;
}
]]


kernel.fragment =
[[
varying vec2 dir;
varying vec2 v_uv;

int quality = int(CoronaVertexUserData.x);


float insideUnitSquare(vec2 v) {
    vec2 s = step(vec2(0.0), v) - step(vec2(1.0), v);
    return s.x * s.y;   
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  vec2 v_uvShift = v_uv;
  
  //Test
  quality = int( abs(sin(CoronaTotalTime*1)) * 5 );
  //v_uvShift.x = abs(sin(CoronaTotalTime*1) * 0.5);


  P_UV vec2 UV = v_uvShift;

  float inSquare = insideUnitSquare(UV);
  float numSamples = inSquare;
  P_COLOR vec4 COLOR = texture2D(CoronaSampler0, UV) * inSquare;
  
  vec2 stepSize = dir/(float(quality));
  vec2 uv;
  for(int i = 1; i <= quality; i++){
    uv = UV + stepSize * float(i);
    inSquare = insideUnitSquare(uv);
    numSamples += inSquare;
    COLOR += texture2D(CoronaSampler0, uv) * inSquare;
    
    uv = UV - stepSize * float(i);
    inSquare = insideUnitSquare(uv);
    numSamples += inSquare;
    COLOR += texture2D(CoronaSampler0, uv) * inSquare;
  }
  COLOR.rgb /= numSamples;
  COLOR.a /= float(quality)*2.0 + 1.0;

  return CoronaColorScale(COLOR);
}
]]

return kernel



--[[
  

--]]
