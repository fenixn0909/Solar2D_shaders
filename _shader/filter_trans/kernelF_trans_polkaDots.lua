
--[[

    Origin Author: bobylito 
    https://gl-transitions.com/editor/PolkaDotsCurtain

    // Using Texture or just colorPlane


--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "polkaDots"


kernel.vertexData =
{
  {
    name = "progress",
    default = .5,
    min = 0,
    max = 1,
    index = 0, 
  },
  -- {
  --   name = "ratioSampler",
  --   default = .5,
  --   min = 0,
  --   max = 1,
  --   index = 1, 
  -- },
  {
    name = "dots",
    default = 20,
    min = 0,
    max = 90,
    index = 1, 
  },
  {
    name = "centerX",
    default = 0,
    min = -1,
    max = 2,
    index = 2, 
  },
  {
    name = "centerY",
    default = 0,
    min = -1,
    max = 2,
    index = 3, 
  },
  
}


kernel.fragment =
[[

float progress = CoronaVertexUserData.x;
//float ratioSampler = CoronaVertexUserData.y;
float dots = CoronaVertexUserData.y;
float centerX = CoronaVertexUserData.z;
float centerY = CoronaVertexUserData.w;


float ratioSampler = 0.5;

//----------------------------------------------

//vec2 center = vec2( 0.5, 0.5 ); // Fading Direction
vec2 center = vec2( centerX, centerY ); // Fading Direction

const float SQRT_2 = 1.414213562373;

//----------------------------------------------

P_COLOR vec4 CoverColor = vec4( 0.0, 0.0, 0.0, 1);

float getAlpha(float x, float y) {
  return max(sign(y - x), 0.0);
}
//----------------------------------------------
P_COLOR vec4 FragmentKernel( P_UV vec2 UV )
{
  // Reverion
  progress = 1-progress;

  P_COLOR vec4 COLOR;
  //P_COLOR vec4 COLOR = texture2D( CoronaSampler0, UV);
  P_COLOR vec4 col_text = texture2D( CoronaSampler0, UV);
  //COLOR.rgb = mix( CoverColor.rgb, COLOR.rgb, ratioSampler);
  //----------------------------------------------
  COLOR.rgb = mix( CoverColor.rgb, col_text.rgb, ratioSampler);
  //COLOR.rgb*= COLOR.a;

  COLOR.a = getAlpha( distance(fract(UV * dots), vec2(0.5, 0.5)) ,( progress / distance(UV, center)));
  COLOR.rgb*= COLOR.a;

  //----------------------------------------------
  return CoronaColorScale( COLOR );
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


