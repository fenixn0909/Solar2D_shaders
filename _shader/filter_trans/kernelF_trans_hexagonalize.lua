
--[[
  Origin Author: mikolalysenko
  https://gl-transitions.com/editor/hexagonalize
  License: MIT


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "hexagonalize"

kernel.vertexData =
{
  {
    name = "progress",
    default = 0.5,
    min = 0,
    max = 1,
    index = 0, 
  },
  {
    name = "horiHexagons",
    default = 20,
    min = 0,
    max = 100,
    index = 1,    
  },
  {
    name = "steps",
    default = 50,
    min = -100,
    max = 100,
    index = 2,    
  },
  {
    name = "ratio",
    default = 0.001,
    min = 0.001,
    max = 10,
    index = 3,    
  },
  
}


kernel.fragment =
[[
float progress = CoronaVertexUserData.x;
float horizontalHexagons = CoronaVertexUserData.y;
float steps = CoronaVertexUserData.z;
float ratio = CoronaVertexUserData.w;

vec4 colorBG = vec4(0,0,0,0);

//----------------------------------------------

struct Hexagon {
  float q;
  float r;
  float s;
};

Hexagon createHexagon(float q, float r){
  Hexagon hex;
  hex.q = q;
  hex.r = r;
  hex.s = -q - r;
  return hex;
}

Hexagon roundHexagon(Hexagon hex){
  
  float q = floor(hex.q + 0.5);
  float r = floor(hex.r + 0.5);
  float s = floor(hex.s + 0.5);

  float deltaQ = abs(q - hex.q);
  float deltaR = abs(r - hex.r);
  float deltaS = abs(s - hex.s);

  if (deltaQ > deltaR && deltaQ > deltaS)
    q = -r - s;
  else if (deltaR > deltaS)
    r = -q - s;
  else
    s = -q - r;

  return createHexagon(q, r);
}

Hexagon hexagonFromPoint(vec2 point, float size) {
  
  point.y /= ratio;
  point = (point - 0.5) / size;
  
  float q = (sqrt(3.0) / 3.0) * point.x + (-1.0 / 3.0) * point.y;
  float r = 0.0 * point.x + 2.0 / 3.0 * point.y;

  Hexagon hex = createHexagon(q, r);
  return roundHexagon(hex);
  
}

vec2 pointFromHexagon(Hexagon hex, float size) {
  
  float x = (sqrt(3.0) * hex.q + (sqrt(3.0) / 2.0) * hex.r) * size + 0.5;
  float y = (0.0 * hex.q + (3.0 / 2.0) * hex.r) * size + 0.5;
  
  return vec2(x, y * ratio);
}

P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  P_COLOR vec4 COLOR;
  //----------------------------------------------

  float dist = 2.0 * min(progress, 1.0 - progress);
  dist = steps > 0 ? ceil(dist * float(steps)) / float(steps) : dist;
  
  float size = (sqrt(3.0) / 3.0) * dist / horizontalHexagons;
  
  vec2 point = dist > 0.0 ? pointFromHexagon(hexagonFromPoint(UV, size), size) : UV;

  //return mix(getFromColor(point), getToColor(point), progress);
  COLOR = mix( texture2D( CoronaSampler0, point ), colorBG, progress);

  //----------------------------------------------
  
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


