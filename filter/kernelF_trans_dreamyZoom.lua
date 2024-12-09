
--[[
  Origin Author: Zeh Fernando
  https://gl-transitions.com/editor/DreamyZoom
  License: MIT
  
--]]



local kernel = {}
kernel.language = "glsl"
kernel.category = "filter"
kernel.group = "trans"
kernel.name = "dreamyZoom"

--Test
-- kernel.isTimeDependent = true

kernel.vertexData =
{
  {
    name = "progress",
    default = 1,
    min = 0,
    max = 1,
    index = 0, 
  },
  {
    name = "texRatioWH",
    default = 1,
    min = 1,
    max = 100,
    index = 1, 
  },
}


kernel.fragment =
[[
P_DEFAULT float progress = CoronaVertexUserData.x;
vec4 colorBG = vec4(0,0,0,0);
float ratio = CoronaVertexUserData.y;

//----------------------------------------------

// Definitions --------
#define DEG2RAD 0.03926990816987241548078304229099 // 1/180*PI


// Transition parameters --------

// In degrees
uniform float rotation = 6; // 

// Multiplier
uniform float scale = 1.2; // 


P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
  P_UV vec2 UV = texCoord;
  P_COLOR vec4 COLOR;
  //progress = abs(sin(CoronaTotalTime*1));
  //progress = 0;
  //----------------------------------------------

  // Massage parameters
    float phase = progress < 0.5 ? progress * 2.0 : (progress - 0.5) * 2.0;
    float angleOffset = progress < 0.5 ? mix(0.0, rotation * DEG2RAD, phase) : mix(-rotation * DEG2RAD, 0.0, phase);
    float newScale = progress < 0.5 ? mix(1.0, scale, phase) : mix(scale, 1.0, phase);
    
    vec2 center = vec2(0, 0);

    // Calculate the source point
    vec2 assumedCenter = vec2(0.5, 0.5);
    vec2 p = (UV.xy - vec2(0.5, 0.5)) / newScale * vec2(ratio, 1.0);

    // This can probably be optimized (with distance())
    float angle = atan(p.y, p.x) + angleOffset;
    float dist = distance(center, p);
    p.x = cos(angle) * dist / ratio + 0.5;
    p.y = sin(angle) * dist + 0.5;

    vec4 cFrom = texture2D( CoronaSampler0, p);
    vec4 cTo = colorBG;
    vec4 c = progress < 0.5 ? cFrom : cTo;

    //vec4 c = progress < 0.5 ? getFromColor(p) : getToColor(p);
    // Finally, apply the color
    // return c + (progress < 0.5 ? mix(0.0, 1.0, phase) : mix(1.0, 0.0, phase));

  //----------------------------------------------

  COLOR = c + (progress < 0.5 ? mix(0.0, 1.0, phase) : mix(1.0, 0.0, phase));
  return CoronaColorScale(COLOR);
}
]]

return kernel

--[[

--]]


