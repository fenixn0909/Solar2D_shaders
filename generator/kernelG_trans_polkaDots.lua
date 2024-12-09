
--[[

  Origin Author: bobylito 
  https://gl-transitions.com/editor/PolkaDotsCurtain
  
  // Using texCoord for HQ, fragCoord for pixel
  // Using Texture or just colorPlane


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "generator"
kernel.group = "trans"
kernel.name = "polkaDots"

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

const float SQRT_2 = 1.414213562373;
float dots = 50;// = 20.0;
vec2 center = vec2(0.0,0.0);// = vec2(0, 0);
float testSpeed = 0.2;

P_COLOR vec4 coverColor = vec4(1.,0,0,1);
lowp float ratioSampler = 1; // 1: using sampler, 0: using coverPlane

float getAlpha(float x, float y) {
  return max(sign(y - x), 0.0);
}

P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  //Test
  float progress = mod( CoronaTotalTime * testSpeed, 1) ; //Reveal Scene
  float progMix = mod( CoronaTotalTime * testSpeed*1, 1) ;
  ratioSampler = progMix;
  
  //Using sampler0
  P_COLOR vec4 texColor = texture2D( CoronaSampler0, texCoord);
  texColor.rgb = mix( coverColor.rgb, texColor.rgb, ratioSampler);

  texColor.a = getAlpha( distance(fract(texCoord * dots), vec2(0.5, 0.5)) ,( progress / distance(texCoord, center)));
  texColor.rgb*= texColor.a;

  return CoronaColorScale(texColor);
}
]]

return kernel

--[[
  Origin Code:

  // author: bobylito
  // license: MIT
  const float SQRT_2 = 1.414213562373;
  uniform float dots;// = 20.0;
  uniform vec2 center;// = vec2(0, 0);

  vec4 transition(vec2 uv) {
    bool nextImage = distance(fract(uv * dots), vec2(0.5, 0.5)) < ( progress / distance(uv, center));
    return nextImage ? getToColor(uv) : getFromColor(uv);
  }
--]]


